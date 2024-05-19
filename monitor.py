import time
from operator import attrgetter

from ryu.controller import ofp_event
from ryu.controller.handler import MAIN_DISPATCHER, DEAD_DISPATCHER
from ryu.controller.handler import set_ev_cls
from ryu.lib import hub

from network_slicing import Slicing


class SimpleMonitor(Slicing):
    def __init__(self, *args, **kwargs):
        super(SimpleMonitor, self).__init__(*args, **kwargs)
        # self.datapaths = {}
        # router id -> port no -> [byte, sec, bw]
        self.servers_bw = {
            4: {
                1: [0, 0, 0],
            },
        }
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
            hub.sleep(10)
            for port_no in self.servers_bw[4].keys():
                self.servers_bw[4][port_no] = [0, 0, 0].copy()

            for dp in self.datapaths.values():
                self._request_stats(dp)
            hub.sleep(1)

            B = 0
            for port in self.servers_bw[4].values():
                B += port[0]
            # B = reduce((lambda x, y: x[0] + y[0]), self.servers_bw[4].values())
            sec = self.servers_bw[4][1][1]
            self.logger.debug("After {}B {}s".format(B, sec))

            for port_no in self.servers_bw[4].keys():
                self.servers_bw[4][port_no][2] = self.servers_bw[4][port_no][0] / self.servers_bw[4][port_no][1]
            if sec != 0:
                # Calculate actual bandwidth
                self.logger.info("<{}> bandwidth: {}B/s".format(4, B / sec))
                # self.delete_flows()
                if any(port[2] > 500 for port in self.servers_bw[4].values()):
                    self.logger.info("Link usage to high! Apply load balancing with secondary server...")
                    self.mac_to_port[4]["00:00:00:00:00:09"] = [4, 5]
                elif any(port[2] > 400 for port in self.servers_bw[4].values()):
                    self.logger.info("Link below threshold! Deactivating secondary server...")
                    self.mac_to_port[4]["00:00:00:00:00:09"] = 4

            hub.sleep(10)

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

        tmp_t = time.time()
        elapsed = tmp_t - self.checkpoint
        if ev.msg.datapath.id == 4:
            self.logger.info('datapath         port     '
                             'rx-pkts  rx-bytes rx-error '
                             'tx-pkts  tx-bytes tx-error')
            self.logger.info('---------------- -------- '
                             '-------- -------- -------- '
                             '-------- -------- --------')
            for stat in sorted(body, key=attrgetter('port_no')):
                self.logger.info('%016x %8x %8d %8d %8d %8d %8d %8d',
                                 ev.msg.datapath.id, stat.port_no,
                                 stat.rx_packets, stat.rx_bytes, stat.rx_errors,
                                 stat.tx_packets, stat.tx_bytes, stat.tx_errors)
                self.logger.info("Port {} bandwidth: {}B/s".format(stat.port_no,
                                                                   stat.tx_bytes / elapsed))

                if stat.port_no not in self.servers_bw[ev.msg.datapath.id]:
                    self.servers_bw[ev.msg.datapath.id][stat.port_no] = [0, 0, 0].copy()
                self.servers_bw[ev.msg.datapath.id][stat.port_no][0] += stat.tx_bytes
                self.servers_bw[ev.msg.datapath.id][stat.port_no][1] = elapsed
        self.checkpoint = tmp_t
