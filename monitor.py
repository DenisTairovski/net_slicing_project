import time
from operator import attrgetter

from ryu.controller import ofp_event
from ryu.controller.handler import MAIN_DISPATCHER, DEAD_DISPATCHER
from ryu.controller.handler import set_ev_cls
from ryu.lib import hub

from network_slicing import Slicing
from port_bandwidth import PortBandwidth
from router_bandwidth import RouterManager


class SimpleMonitor(Slicing):
    def __init__(self, *args, **kwargs):
        super(SimpleMonitor, self).__init__(*args, **kwargs)
        # router id -> port no -> [byte, sec, bw]
        self.servers_bw = {
            # for this simple scenario we only consider the router 4
            4: RouterManager(4, 5, [1, 2])
        }
        self.sleep_time = 10
        self.monitor_thread = hub.spawn(self._monitor)

    @set_ev_cls(ofp_event.EventOFPStateChange,
                [MAIN_DISPATCHER, DEAD_DISPATCHER])
    def _state_change_handler(self, ev):
        datapath = ev.datapath
        if ev.state == MAIN_DISPATCHER:
            if datapath.id not in self.datapaths:
                self.logger.debug('register datapath: %016x', datapath.id)
                self.datapaths[datapath.id] = datapath
        elif ev.state == DEAD_DISPATCHER:
            if datapath.id in self.datapaths:
                self.logger.debug('unregister datapath: %016x', datapath.id)
                del self.datapaths[datapath.id]

    def _monitor(self):
        while True:
            # perform monitoring every [sleep_time] seconds
            hub.sleep(self.sleep_time)

            for dp in self.datapaths.values():
                if dp.id == 4:
                    self._request_stats(dp)
            # wait 1 second to let other routers reply with their information
            hub.sleep(1)

            # current router id
            r_id = 4
            # check if the given router has active ports
            if len(self.servers_bw[r_id]) != 0:
                # Calculate actual bandwidth
                sum_bw = 0
                for port in self.servers_bw[r_id].ports:
                    sum_bw += port.bandwidth
                self.logger.info("Total router <{}> bandwidth: {:0.3f} B/s\n".format(r_id, sum_bw))

                # for simplicity, we check only the port 4 because we only ping on it
                p1_id = 4
                p2_id = self.servers_bw[r_id].secondary_port

                p1_bw = self.servers_bw[r_id][p1_id].bandwidth
                p2_bw = self.servers_bw[r_id][p2_id].bandwidth

                # check for bandwidth demands
                # perform transition only if the previous state is different (avoid redundant actions)
                if p1_bw > 600 and not self.servers_bw[r_id].load_balancing:
                    self.logger.info("Link usage to high! Apply load balancing with secondary server...")
                    self.mac_to_port[r_id]["00:00:00:00:00:09"] = [p1_id, p2_id]
                    self.servers_bw[r_id].load_balancing = True
                elif (p1_bw + p2_bw) < 500 and self.servers_bw[r_id].load_balancing:
                    self.logger.info("Link below threshold! Deactivating secondary server...")
                    self.mac_to_port[r_id]["00:00:00:00:00:09"] = p1_id
                    self.servers_bw[r_id].load_balancing = False

    def _request_stats(self, datapath):
        self.logger.debug('send stats request: %016x', datapath.id)
        ofproto = datapath.ofproto
        parser = datapath.ofproto_parser

        req = parser.OFPFlowStatsRequest(datapath)
        datapath.send_msg(req)

        req = parser.OFPPortStatsRequest(datapath, 0, ofproto.OFPP_ANY)
        datapath.send_msg(req)

    @set_ev_cls(ofp_event.EventOFPPortStatsReply, MAIN_DISPATCHER)
    def _port_stats_reply_handler(self, ev):
        body = ev.msg.body

        now = time.time()
        elapsed = now - self.checkpoint
        self.checkpoint = now

        r_id = ev.msg.datapath.id
        if r_id == 4:
            self.logger.info('datapath         port     '
                             'rx-pkts  rx-bytes rx-error '
                             'tx-pkts  tx-bytes tx-error')
            self.logger.info('---------------- -------- '
                             '-------- -------- -------- '
                             '-------- -------- --------')
            for stat in sorted(body, key=attrgetter('port_no')):
                # set max port to 100 in order to skip fffffffe port
                if stat.port_no < 100 and stat.port_no not in self.servers_bw[r_id].ignored:
                    self.logger.info('%016x %8x %8d %8d %8d %8d %8d %8d',
                                     r_id, stat.port_no,
                                     stat.rx_packets, stat.rx_bytes, stat.rx_errors,
                                     stat.tx_packets, stat.tx_bytes, stat.tx_errors)

                    # update collected data for each port
                    try:
                        port = self.servers_bw[r_id][stat.port_no]
                        port.sec = elapsed
                    except:
                        port = PortBandwidth(stat.port_no, 0, elapsed)
                        pass

                    port.tot_bytes = stat.tx_bytes
                    self.logger.info(port)

                    self.servers_bw[r_id][port.port_id] = port
