#!/usr/bin/python3

from mininet.topo import Topo
from mininet.net import Mininet
from mininet.node import OVSKernelSwitch, RemoteController
from mininet.cli import CLI
from mininet.link import TCLink
import subprocess


class Topology(Topo):
    def __init__(self):
        # Initialize topology
        Topo.__init__(self)

        # Create template host, switch, and link
        host_config = dict(inNamespace=True)
        link_config = dict()  # Total Capacity of the link ~ 10Mbps
        host_link_config = dict()

        # Create 4 router nodes
        for i in range(4):
            sconfig = {"dpid": "%016x" % (i + 1)}
            self.addSwitch("r%d" % (i + 1), **sconfig)

        # Create 10 host nodes
        for i in range(10):
            self.addHost("h%d" % (i + 1), **host_config) # We choose 'h' because 'c' is the controller
            


        # Add router link
        self.addLink("r1", "r2", **link_config)
        self.addLink("r2", "r3", **link_config)
        self.addLink("r3", "r4", **link_config)

        # Add clients-router1 links
        self.addLink("h1", "r1", **host_link_config)
        self.addLink("h2", "r1", **host_link_config)
        self.addLink("h3", "r1", **host_link_config)

        # Add clients-router2 links
        self.addLink("h4", "r2", **host_link_config)
        self.addLink("h5", "r2", **host_link_config)

        # # Add clients-router3 links
        self.addLink("h6", "r3", **host_link_config)
        self.addLink("h7", "r3", **host_link_config)

        # # Add clients-router4 links
        self.addLink("h8", "r4", **host_link_config)
        self.addLink("h9", "r4", **host_link_config)
        self.addLink("h10", "r4", **host_link_config)




topos = {"topology": (lambda: Topology())}

if __name__ == "__main__":
    topology = Topology()
    net = Mininet(
        topo=topology,
        controller=RemoteController( 'c0', ip='127.0.0.1'), 
        switch=OVSKernelSwitch,
        build=False,
        autoSetMacs=True,
        autoStaticArp=True,
        link=TCLink,
    )
    
    net.build()
    net.start()

    # subprocess.call("./all_scenario.sh")
    # subprocess.call("./2_operator_scenario.sh")

    CLI(net)
    net.stop()
