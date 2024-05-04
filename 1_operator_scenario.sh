#!/bin/sh

#sudo ovs-vsctl set interface r3-eth1 admin_state=down
sudo ovs-vsctl set interface r2-eth3 admin_state=down
sudo ovs-vsctl set interface r4-eth1 admin_state=down
# Creating 1 virtual queues in Router 1.
echo ' ---------------------------------------------- '
echo '*** Creating 1 slices of 5 Gbps ...'
echo 'Router1:'
sudo ovs-vsctl -- \
set port r1-eth1 qos=@newqos -- \
--id=@newqos create QoS type=linux-htb \
other-config:max-rate=10G \
queues:1=@1q -- \
--id=@1q create queue other-config:min-rate=1M other-config:max-rate=10G

echo ' '

# Creating 2 virtual queues in Router 2.
echo 'Router2:'
sudo ovs-vsctl -- \
set port r2-eth1 qos=@newqos -- \
set port r2-eth2 qos=@newqos -- \
--id=@newqos create QoS type=linux-htb \
other-config:max-rate=10G \
queues:1=@1q -- \
--id=@1q create queue other-config:min-rate=1M other-config:max-rate=10G

echo ' '

# Creating 2 virtual queues in Router 3.
echo 'Router3:'
sudo ovs-vsctl -- \
set port r3-eth1 qos=@newqos -- \
set port r3-eth2 qos=@newqos -- \
--id=@newqos create QoS type=linux-htb \
other-config:max-rate=10G \
queues:1=@1q -- \
--id=@1q create queue other-config:min-rate=1M other-config:max-rate=10G

# Creating 2 virtual queues in Router 4.
echo 'Router4:'
sudo ovs-vsctl -- \
set port r4-eth2 qos=@newqos -- \
--id=@newqos create QoS type=linux-htb \
other-config:max-rate=10G \
queues:1=@1q -- \
--id=@1q create queue other-config:min-rate=1M other-config:max-rate=10G

echo '*** End of Creating the Slices ...'
echo ' ---------------------------------------------- '


# Mapping the r1 virtual queues to hosts:
# (h1, h4) --> queue1, (h1, h5) --> queue1, (h1, h9) --> queue1
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_src=10.0.0.1,nw_dst=10.0.0.4,idle_timeout=0,actions=set_queue:1,normal
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_src=10.0.0.1,nw_dst=10.0.0.5,idle_timeout=0,actions=set_queue:1,normal
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_src=10.0.0.1,nw_dst=10.0.0.9,idle_timeout=0,actions=set_queue:1,normal
# (h4, h5) --> queue1, (h4, h9) --> queue1
sudo ovs-ofctl add-flow r2 ip,priority=65500,nw_src=10.0.0.4,nw_dst=10.0.0.5,idle_timeout=0,actions=set_queue:1,normal
sudo ovs-ofctl add-flow r2 ip,priority=65500,nw_src=10.0.0.4,nw_dst=10.0.0.9,idle_timeout=0,actions=set_queue:1,normal
# (h5, h9) --> queue1
sudo ovs-ofctl add-flow r2 ip,priority=65500,nw_src=10.0.0.5,nw_dst=10.0.0.9,idle_timeout=0,actions=set_queue:1,normal

# Block other hosts:
# h2
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_dst=10.0.0.2,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r2 ip,priority=65500,nw_dst=10.0.0.2,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r3 ip,priority=65500,nw_dst=10.0.0.2,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r4 ip,priority=65500,nw_dst=10.0.0.2,idle_timeout=0,actions=drop
# h3
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_dst=10.0.0.3,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r2 ip,priority=65500,nw_dst=10.0.0.3,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r3 ip,priority=65500,nw_dst=10.0.0.3,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r4 ip,priority=65500,nw_dst=10.0.0.3,idle_timeout=0,actions=drop
# h6
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_dst=10.0.0.6,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r2 ip,priority=65500,nw_dst=10.0.0.6,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r3 ip,priority=65500,nw_dst=10.0.0.6,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r4 ip,priority=65500,nw_dst=10.0.0.6,idle_timeout=0,actions=drop
# h7
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_dst=10.0.0.7,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r2 ip,priority=65500,nw_dst=10.0.0.7,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r3 ip,priority=65500,nw_dst=10.0.0.7,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r4 ip,priority=65500,nw_dst=10.0.0.7,idle_timeout=0,actions=drop
# h8
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_dst=10.0.0.8,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r2 ip,priority=65500,nw_dst=10.0.0.8,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r3 ip,priority=65500,nw_dst=10.0.0.8,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r4 ip,priority=65500,nw_dst=10.0.0.8,idle_timeout=0,actions=drop
# h10
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_dst=10.0.0.10,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r2 ip,priority=65500,nw_dst=10.0.0.10,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r3 ip,priority=65500,nw_dst=10.0.0.10,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r4 ip,priority=65500,nw_dst=10.0.0.10,idle_timeout=0,actions=drop

