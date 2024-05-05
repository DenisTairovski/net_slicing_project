#!/bin/sh

# Create mapping for the topology with the recovery links
sudo ovs-vsctl set interface r3-eth1 admin_state=down
sudo ovs-vsctl set interface r2-eth2 admin_state=down
# Creating 2 virtual queues in Router 1.
echo ' ---------------------------------------------- '
echo '*** Creating 2 slices of 5 Gbps ...'
echo 'Router1:'
sudo ovs-vsctl -- \
set port r1-eth1 qos=@newqos -- \
--id=@newqos create QoS type=linux-htb \
other-config:max-rate=10G \
queues:1=@1q \
queues:2=@2q \
queues:3=@3q -- \
--id=@1q create queue other-config:min-rate=1M other-config:max-rate=5G -- \
--id=@2q create queue other-config:min-rate=1M other-config:max-rate=5G

echo ' '

# Creating 2 virtual queues in Router 2.
echo 'Router2:'
sudo ovs-vsctl -- \
set port r2-eth1 qos=@newqos -- \
set port r2-eth3 qos=@newqos -- \
--id=@newqos create QoS type=linux-htb \
other-config:max-rate=10G \
queues:1=@1q \
queues:2=@2q \
queues:3=@3q -- \
--id=@1q create queue other-config:min-rate=1M other-config:max-rate=5G -- \
--id=@2q create queue other-config:min-rate=1M other-config:max-rate=5G

echo ' '

# Creating 2 virtual queues in Router 3.
echo 'Router3:'
sudo ovs-vsctl -- \
set port r3-eth2 qos=@newqos -- \
--id=@newqos create QoS type=linux-htb \
other-config:max-rate=10G \
queues:1=@1q \
queues:2=@2q \
queues:3=@3q -- \
--id=@1q create queue other-config:min-rate=1M other-config:max-rate=5G -- \
--id=@2q create queue other-config:min-rate=1M other-config:max-rate=5G

echo ' '

echo 'Router4:'
sudo ovs-vsctl -- \
set port r4-eth2 qos=@newqos -- \
set port r4-eth1 qos=@newqos -- \
--id=@newqos create QoS type=linux-htb \
other-config:max-rate=10G \
queues:1=@1q \
queues:2=@2q \
queues:3=@3q -- \
--id=@1q create queue other-config:min-rate=1M other-config:max-rate=5G -- \
--id=@2q create queue other-config:min-rate=1M other-config:max-rate=5G

echo ' '

echo '*** End of Creating the Slices ...'
echo ' ---------------------------------------------- '

# Mapping the r1 virtual queues to hosts:
# ------------------------------------------
# First operator
# (h1, h4) --> queue1
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_src=10.0.0.1,nw_dst=10.0.0.4,idle_timeout=0,actions=set_queue:1,normal
# (h1, h5) --> queue1
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_src=10.0.0.1,nw_dst=10.0.0.5,idle_timeout=0,actions=set_queue:1,normal
# (h1, h9) --> queue1
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_src=10.0.0.1,nw_dst=10.0.0.9,idle_timeout=0,actions=set_queue:1,normal
# (h4, h9) --> queue1
sudo ovs-ofctl add-flow r2 ip,priority=65500,nw_src=10.0.0.4,nw_dst=10.0.0.9,idle_timeout=0,actions=set_queue:1,normal
# (h4, h5) --> queue1
sudo ovs-ofctl add-flow r2 ip,priority=65500,nw_src=10.0.0.4,nw_dst=10.0.0.5,idle_timeout=0,actions=set_queue:1,normal
# (h5, h9) --> queue1
sudo ovs-ofctl add-flow r2 ip,priority=65500,nw_src=10.0.0.5,nw_dst=10.0.0.9,idle_timeout=0,actions=set_queue:1,normal

# ---------------------------------------
# Second operator
# (h3, h6) --> queue2
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_src=10.0.0.3,nw_dst=10.0.0.6,idle_timeout=0,actions=set_queue:2,normal
# --------------------------------------
# Block other hosts:
# First operator
# h1 - Source
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_src=10.0.0.1,nw_dst=10.0.0.2,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_src=10.0.0.1,nw_dst=10.0.0.3,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_src=10.0.0.1,nw_dst=10.0.0.6,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_src=10.0.0.1,nw_dst=10.0.0.7,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_src=10.0.0.1,nw_dst=10.0.0.10,idle_timeout=0,actions=drop
# h4
sudo ovs-ofctl add-flow r2 ip,priority=65500,nw_src=10.0.0.4,nw_dst=10.0.0.2,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r2 ip,priority=65500,nw_src=10.0.0.4,nw_dst=10.0.0.3,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r2 ip,priority=65500,nw_src=10.0.0.4,nw_dst=10.0.0.6,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r2 ip,priority=65500,nw_src=10.0.0.4,nw_dst=10.0.0.7,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r2 ip,priority=65500,nw_src=10.0.0.4,nw_dst=10.0.0.10,idle_timeout=0,actions=drop
# h5
sudo ovs-ofctl add-flow r2 ip,priority=65500,nw_src=10.0.0.5,nw_dst=10.0.0.2,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r2 ip,priority=65500,nw_src=10.0.0.5,nw_dst=10.0.0.3,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r2 ip,priority=65500,nw_src=10.0.0.5,nw_dst=10.0.0.5,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r2 ip,priority=65500,nw_src=10.0.0.5,nw_dst=10.0.0.6,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r2 ip,priority=65500,nw_src=10.0.0.5,nw_dst=10.0.0.7,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r2 ip,priority=65500,nw_src=10.0.0.5,nw_dst=10.0.0.10,idle_timeout=0,actions=drop
# h9
sudo ovs-ofctl add-flow r4 ip,priority=65500,nw_src=10.0.0.9,nw_dst=10.0.0.2,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r4 ip,priority=65500,nw_src=10.0.0.9,nw_dst=10.0.0.3,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r4 ip,priority=65500,nw_src=10.0.0.9,nw_dst=10.0.0.6,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r4 ip,priority=65500,nw_src=10.0.0.9,nw_dst=10.0.0.7,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r4 ip,priority=65500,nw_src=10.0.0.9,nw_dst=10.0.0.10,idle_timeout=0,actions=drop
# Second Operator
# h3
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_src=10.0.0.3,nw_dst=10.0.0.1,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_src=10.0.0.3,nw_dst=10.0.0.2,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_src=10.0.0.3,nw_dst=10.0.0.4,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_src=10.0.0.3,nw_dst=10.0.0.5,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_src=10.0.0.3,nw_dst=10.0.0.7,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_src=10.0.0.3,nw_dst=10.0.0.9,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_src=10.0.0.3,nw_dst=10.0.0.10,idle_timeout=0,actions=drop
# h6
sudo ovs-ofctl add-flow r3 ip,priority=65500,nw_src=10.0.0.6,nw_dst=10.0.0.1,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r3 ip,priority=65500,nw_src=10.0.0.6,nw_dst=10.0.0.2,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r3 ip,priority=65500,nw_src=10.0.0.6,nw_dst=10.0.0.4,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r3 ip,priority=65500,nw_src=10.0.0.6,nw_dst=10.0.0.5,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r3 ip,priority=65500,nw_src=10.0.0.6,nw_dst=10.0.0.7,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r3 ip,priority=65500,nw_src=10.0.0.6,nw_dst=10.0.0.9,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r3 ip,priority=65500,nw_src=10.0.0.6,nw_dst=10.0.0.10,idle_timeout=0,actions=drop
# h8 is not communicating with no one
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_dst=10.0.0.8,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r2 ip,priority=65500,nw_dst=10.0.0.8,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r3 ip,priority=65500,nw_dst=10.0.0.8,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r4 ip,priority=65500,nw_dst=10.0.0.8,idle_timeout=0,actions=drop
# h2 is not communicating with no one
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_dst=10.0.0.2,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r2 ip,priority=65500,nw_dst=10.0.0.2,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r3 ip,priority=65500,nw_dst=10.0.0.2,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r4 ip,priority=65500,nw_dst=10.0.0.2,idle_timeout=0,actions=drop
# h2 is not communicating with no one
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_dst=10.0.0.7,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r2 ip,priority=65500,nw_dst=10.0.0.7,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r3 ip,priority=65500,nw_dst=10.0.0.7,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r4 ip,priority=65500,nw_dst=10.0.0.7,idle_timeout=0,actions=drop
# h2 is not communicating with no one
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_dst=10.0.0.10,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r2 ip,priority=65500,nw_dst=10.0.0.10,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r3 ip,priority=65500,nw_dst=10.0.0.10,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r4 ip,priority=65500,nw_dst=10.0.0.10,idle_timeout=0,actions=drop
