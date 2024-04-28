#!/bin/sh


# Creating 2 virtual queues in Router 1.
echo ' ---------------------------------------------- '
echo '*** Creating 2 slices of 5 Gbps ...'
echo 'Router1:'
sudo ovs-vsctl -- \
set port r1-eth1 qos=@newqos -- \
--id=@newqos create QoS type=linux-htb \
other-config:max-rate=1G \
queues:1=@1q \
queues:2=@2q -- \
--id=@1q create queue other-config:min-rate=1M other-config:max-rate=5G -- \
--id=@2q create queue other-config:min-rate=1M other-config:max-rate=5G

echo ' '

# Creating 2 virtual queues in Router 2.
echo 'Router2:'
sudo ovs-vsctl -- \
set port r2-eth1 qos=@newqos -- \
set port r2-eth2 qos=@newqos -- \
--id=@newqos create QoS type=linux-htb \
other-config:max-rate=1G \
queues:1=@1q \
queues:2=@2q -- \
--id=@1q create queue other-config:min-rate=1M other-config:max-rate=5G -- \
--id=@2q create queue other-config:min-rate=1M other-config:max-rate=5G

echo ' '

# Creating 2 virtual queues in Router 3.
echo 'Router3:'
sudo ovs-vsctl -- \
set port r3-eth1 qos=@newqos -- \
--id=@newqos create QoS type=linux-htb \
other-config:max-rate=1M0 \
queues:1=@1q \
queues:2=@2q -- \
--id=@1q create queue other-config:min-rate=1M other-config:max-rate=5M -- \
--id=@2q create queue other-config:min-rate=1M other-config:max-rate=5M

echo '*** End of Creating the Slices ...'
echo ' ---------------------------------------------- '


# Mapping the r1 virtual queues to hosts:
# (h1, h6) --> queue1, (h1, h7) --> queue1
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_src=10.0.0.1,nw_dst=10.0.0.6,idle_timeout=0,actions=set_queue:1,normal
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_src=10.0.0.1,nw_dst=10.0.0.7,idle_timeout=0,actions=set_queue:2,normal
# (h2, h4) --> queue2
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_src=10.0.0.2,nw_dst=10.0.0.4,idle_timeout=0,actions=set_queue:2,normal
# Block other hosts:
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_src=10.0.0.1,nw_dst=10.0.0.2,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_src=10.0.0.1,nw_dst=10.0.0.3,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_src=10.0.0.1,nw_dst=10.0.0.4,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_src=10.0.0.1,nw_dst=10.0.0.5,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_src=10.0.0.2,nw_dst=10.0.0.1,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_src=10.0.0.2,nw_dst=10.0.0.3,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_src=10.0.0.2,nw_dst=10.0.0.5,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_src=10.0.0.2,nw_dst=10.0.0.6,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_src=10.0.0.2,nw_dst=10.0.0.7,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_src=10.0.0.3,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_dst=10.0.0.3,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_dst=10.0.0.5,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_dst=10.0.0.8,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_dst=10.0.0.9,idle_timeout=0,actions=drop

# Mapping the r2 virtual queues to hosts:
# (h2, h4) --> queue1
sudo ovs-ofctl add-flow r2 ip,priority=65500,nw_src=10.0.0.4,nw_dst=10.0.0.2,idle_timeout=0,actions=set_queue:2,normal
# (h4, h10) --> queue1
sudo ovs-ofctl add-flow r2 ip,priority=65500,nw_src=10.0.0.4,nw_dst=10.0.0.10,idle_timeout=0,actions=set_queue:2,normal
# Block other hosts:
sudo ovs-ofctl add-flow r2 ip,priority=65500,nw_src=10.0.0.4,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r2 ip,priority=65500,nw_src=10.0.0.5,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r2 ip,priority=65500,nw_dst=10.0.0.5,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r2 ip,priority=65500,nw_dst=10.0.0.8,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r2 ip,priority=65500,nw_dst=10.0.0.9,idle_timeout=0,actions=drop

# Mapping the r3 virtual queues to hosts:
# (h1, h6) --> queue1
sudo ovs-ofctl add-flow r2 ip,priority=65500,nw_src=10.0.0.6,nw_dst=10.0.0.1,idle_timeout=0,actions=set_queue:1,normal
# (h6, h7) --> queue1
sudo ovs-ofctl add-flow r2 ip,priority=65500,nw_src=10.0.0.7,nw_dst=10.0.0.6,idle_timeout=0,actions=set_queue:1,normal
# Block other hosts:
sudo ovs-ofctl add-flow r3 ip,priority=65500,nw_dst=10.0.0.4,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r3 ip,priority=65500,nw_dst=10.0.0.5,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r3 ip,priority=65500,nw_dst=10.0.0.8,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r3 ip,priority=65500,nw_dst=10.0.0.9,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r3 ip,priority=65500,nw_dst=10.0.0.10,idle_timeout=0,actions=drop

# Mapping the r4 virtual queues to hosts:
# (h4, h10) --> queue1
sudo ovs-ofctl add-flow r4 ip,priority=65500,nw_src=10.0.0.10,nw_dst=10.0.0.4,idle_timeout=0,actions=set_queue:1,normal
# Block other hosts:
sudo ovs-ofctl add-flow r4 ip,priority=65500,nw_src=10.0.0.8,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r4 ip,priority=65500,nw_src=10.0.0.9,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r4 ip,priority=65500,nw_dst=10.0.0.8,idle_timeout=0,actions=drop
sudo ovs-ofctl add-flow r4 ip,priority=65500,nw_dst=10.0.0.9,idle_timeout=0,actions=drop