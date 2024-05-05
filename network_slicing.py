import random

from ryu.base import app_manager
from ryu.controller import ofp_event
from ryu.controller.handler import CONFIG_DISPATCHER, MAIN_DISPATCHER
from ryu.controller.handler import set_ev_cls
from ryu.ofproto import ofproto_v1_3
from ryu.lib.packet import packet
from ryu.lib.packet import ethernet
from ryu.lib.packet import ether_types
from ryu.lib.packet import udp
from ryu.lib.packet import tcp
from ryu.lib.packet import icmp
import subprocess
import time
import threading

from enum_scenario import Scenario


class Slicing(app_manager.RyuApp):
    OFP_VERSIONS = [ofproto_v1_3.OFP_VERSION]

    def __init__(self, *args, **kwargs):
        super(Slicing, self).__init__(*args, **kwargs)

        # Destination Mapping for each router a dict is provided, with the associations of each MAC address and the
        # corresponding output port
        self.mac_to_port = {
            1: {"00:00:00:00:00:01": 2, "00:00:00:00:00:02": 3, "00:00:00:00:00:03": 4,
                "00:00:00:00:00:04": 1, "00:00:00:00:00:05": 1,
                "00:00:00:00:00:06": 1, "00:00:00:00:00:07": 1,
                "00:00:00:00:00:08": 1, "00:00:00:00:00:09": 1, "00:00:00:00:00:0a": 1
                },
            2: {"00:00:00:00:00:01": 1, "00:00:00:00:00:02": 1, "00:00:00:00:00:03": 1,
                "00:00:00:00:00:04": 4, "00:00:00:00:00:05": 5,
                "00:00:00:00:00:06": 2, "00:00:00:00:00:07": 2,
                "00:00:00:00:00:08": 2, "00:00:00:00:00:09": 2, "00:00:00:00:00:0a": 2
                },
            3: {"00:00:00:00:00:01": 1, "00:00:00:00:00:02": 1, "00:00:00:00:00:03": 1,
                "00:00:00:00:00:04": 1, "00:00:00:00:00:05": 1,
                "00:00:00:00:00:06": 3, "00:00:00:00:00:07": 4,
                "00:00:00:00:00:08": 2, "00:00:00:00:00:09": 2, "00:00:00:00:00:0a": 2
                },
            4: {"00:00:00:00:00:01": 1, "00:00:00:00:00:02": 1, "00:00:00:00:00:03": 1,
                "00:00:00:00:00:04": 1, "00:00:00:00:00:05": 1,
                "00:00:00:00:00:06": 1, "00:00:00:00:00:07": 1,
                "00:00:00:00:00:08": 3, "00:00:00:00:00:09": 4, "00:00:00:00:00:0a": 5},
        }

        self.emergency = 0  # Boolean that indicates the presence of an emergency scenario
        self.time = time.time()  # Timer that keeps track of time for an emergency scenario

        self.print_flag = 0  # Helper variable that helps us with printing/output

        # Creation of an additional thread that automates the process for Emergecy Scenario and Normal Scenario!
        # Listens to the timer() function.
        self.threadd = threading.Thread(target=self.timer, args=())
        self.threadd.daemon = True
        self.threadd.start()

        self.end_switches = [1, 4]

    @set_ev_cls(ofp_event.EventOFPSwitchFeatures, CONFIG_DISPATCHER)
    def switch_features_handler(self, ev):
        datapath = ev.msg.datapath
        ofproto = datapath.ofproto
        parser = datapath.ofproto_parser

        # install the table-miss flow entry.
        match = parser.OFPMatch()
        actions = [
            parser.OFPActionOutput(ofproto.OFPP_CONTROLLER, ofproto.OFPCML_NO_BUFFER)
        ]
        self.add_flow(datapath, 0, match, actions)

    def add_flow(self, datapath, priority, match, actions):
        ofproto = datapath.ofproto
        parser = datapath.ofproto_parser

        # construct flow_mod message and send it.
        inst = [parser.OFPInstructionActions(ofproto.OFPIT_APPLY_ACTIONS, actions)]
        mod = parser.OFPFlowMod(
            datapath=datapath, priority=priority, match=match, instructions=inst
        )
        datapath.send_msg(mod)

    def _send_package(self, msg, datapath, in_port, actions):
        data = None
        ofproto = datapath.ofproto
        if msg.buffer_id == ofproto.OFP_NO_BUFFER:
            data = msg.data

        out = datapath.ofproto_parser.OFPPacketOut(
            datapath=datapath,
            buffer_id=msg.buffer_id,
            in_port=in_port,
            actions=actions,
            data=data,
        )
        datapath.send_msg(out)

    @set_ev_cls(ofp_event.EventOFPPacketIn, MAIN_DISPATCHER)
    def _packet_in_handler(self, ev):
        msg = ev.msg
        datapath = msg.datapath
        ofproto = datapath.ofproto
        in_port = msg.match["in_port"]

        pkt = packet.Packet(msg.data)
        eth = pkt.get_protocol(ethernet.ethernet)
        if eth.ethertype == ether_types.ETH_TYPE_LLDP:
            # ignore lldp packet
            return

        dst = eth.dst
        src = eth.src

        dpid = datapath.id

        if dpid in self.mac_to_port:
            if (self.emergency == 1):  # Emergency Scenario - Create New Topology

                if dst in self.mac_to_port[dpid]:
                    out_port = self.mac_to_port[dpid][dst]
                    actions = [datapath.ofproto_parser.OFPActionOutput(out_port)]
                    match = datapath.ofproto_parser.OFPMatch(eth_dst=dst)
                    self.add_flow(datapath, 1, match, actions)
                    self._send_package(msg, datapath, in_port, actions)



            else:
                if dst in self.mac_to_port[dpid]:
                    out_port = self.mac_to_port[dpid][dst]
                    actions = [datapath.ofproto_parser.OFPActionOutput(out_port)]
                    match = datapath.ofproto_parser.OFPMatch(eth_dst=dst)
                    self.add_flow(datapath, 1, match, actions)
                    self._send_package(msg, datapath, in_port, actions)

    # Function that automates the alternation between Emergency and Non-Emergency Scenario
    def timer(self):
        while True:
            self.change_scenario(
                random.choice(list(Scenario))
                #Scenario.EMERGENCY
            )
            # Random call for the simulate fault recovery scenario
            if random.randint(0, 10) == 1: (
                self.simulate_fault_recovery(Scenario)
            )
            time.sleep(120)
            print(' ')
            self.time = time.time()

    def change_scenario(self, scenario):
        print()

        if scenario == Scenario.EMERGENCY:
            print('********** EMERGENCY **********')
            subprocess.call("./all_scenario.sh")

        if scenario == Scenario.ONE_OP:
            print('********** 1 OPERATOR **********')
            subprocess.call("./1_operator_scenario.sh")

        if scenario == Scenario.TWO_OP:
            print('********** 2 OPERATOR **********')
            subprocess.call("./2_operator_scenario.sh")

        if scenario == Scenario.THREE_OP:
            print('********** 3 OPERATOR **********')
            subprocess.call("./3_operator_scenario.sh")

        print('---------- CONFIGURED ----------')

    def simulate_fault_recovery(self, scenario):
        print()
        print('++++++++++ BROKEN LINK ++++++++++')
        # Change address mapping to accomodate the fault link scenario
        self.mac_to_port = {
            1: {"00:00:00:00:00:01": 2, "00:00:00:00:00:02": 3, "00:00:00:00:00:03": 4,
                "00:00:00:00:00:04": 1, "00:00:00:00:00:05": 1,
                "00:00:00:00:00:06": 1, "00:00:00:00:00:07": 1,
                "00:00:00:00:00:08": 1, "00:00:00:00:00:09": 1, "00:00:00:00:00:0a": 1
                },
            2: {"00:00:00:00:00:01": 1, "00:00:00:00:00:02": 1, "00:00:00:00:00:03": 1,
                "00:00:00:00:00:04": 4, "00:00:00:00:00:05": 5,
                "00:00:00:00:00:06": 3, "00:00:00:00:00:07": 3,
                "00:00:00:00:00:08": 3, "00:00:00:00:00:09": 3, "00:00:00:00:00:0a": 3
                },
            3: {"00:00:00:00:00:01": 2, "00:00:00:00:00:02": 2, "00:00:00:00:00:03": 2,
                "00:00:00:00:00:04": 2, "00:00:00:00:00:05": 2,
                "00:00:00:00:00:06": 3, "00:00:00:00:00:07": 4,
                "00:00:00:00:00:08": 2, "00:00:00:00:00:09": 2, "00:00:00:00:00:0a": 2
                },
            4: {"00:00:00:00:00:01": 1, "00:00:00:00:00:02": 1, "00:00:00:00:00:03": 1,
                "00:00:00:00:00:04": 1, "00:00:00:00:00:05": 1,
                "00:00:00:00:00:06": 2, "00:00:00:00:00:07": 2,
                "00:00:00:00:00:08": 3, "00:00:00:00:00:09": 4, "00:00:00:00:00:0a": 5},
        }
        self.end_switches = [1, 3]
        print("Simulate link fault by disabling connection between router r2 and r3")
        print("Restore network functionality by activating alternative links between r2 and r4...")

        if scenario == Scenario.EMERGENCY:
            print('********** EMERGENCY RECOVERY **********')
            subprocess.call("./EM_op_fault_and_recovery.sh")

        if scenario == Scenario.ONE_OP:
            print('********** 1 OPERATOR RECOVERY **********')
            subprocess.call("./1_op_fault_and_recovery.sh")

        if scenario == Scenario.TWO_OP:
            print('********** 2 OPERATOR RECOVERY **********')
            subprocess.call("./2_op_fault_and_recovery.sh")

        if scenario == Scenario.THREE_OP:
            print('********** 3 OPERATOR RECOVERY**********')
            subprocess.call("./3_op_fault_and_recovery.sh")

        # change the mac_to port and/or the port_to_port matrix
        # to reflect new forwarding rules
        print("++++++++++ RECOVERY COMPLETED ++++++++++")

