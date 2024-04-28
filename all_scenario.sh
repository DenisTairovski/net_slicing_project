#!/bin/sh

# 1 slice, 1 virtual queue, assigned to multiple host
# Creating 1 virtual queue in Router 1.
echo ' ---------------------------------------------- '
echo '*** Network Slicing: Creating 1 common slice ~ Emergency Scenario ...'
echo 'Router1:'
sudo ovs-vsctl set port r1-eth1 qos=@newqos -- \
--id=@newqos create QoS type=linux-htb \
other-config:max-rate=10000000 \
queues:1=@1q -- \
--id=@1q create queue other-config:min-rate=100 other-config:max-rate=1000


echo ' '

# 1 slice, 1 virtual queue, assigned to multiple host
# Creating 1 virtual queue in Router 2.
echo 'Router2:'
sudo ovs-vsctl -- \
set port r2-eth1 qos=@newqos -- \
set port r2-eth2 qos=@newqos -- \
--id=@newqos create QoS type=linux-htb \
other-config:max-rate=10000000 \
queues:1=@1q -- \
--id=@1q create queue other-config:min-rate=100 other-config:max-rate=1000

echo ' '

echo 'Router3:'
sudo ovs-vsctl -- \
set port r3-eth1 qos=@newqos -- \
set port r3-eth2 qos=@newqos -- \
--id=@newqos create QoS type=linux-htb \
other-config:max-rate=10000000 \
queues:1=@1q -- \
--id=@1q create queue other-config:min-rate=100 other-config:max-rate=1000

echo ' '

echo 'Router4:'
sudo ovs-vsctl -- \
set port r4-eth1 qos=@newqos -- \
--id=@newqos create QoS type=linux-htb \
other-config:max-rate=10000000 \
queues:1=@1q -- \
--id=@1q create queue other-config:min-rate=100 other-config:max-rate=1000

echo '*** End of Creating the Slice ...'
echo ' ---------------------------------------------- '

# Mapping the r1 virtual queues to hosts: (h1, h4) - (h1, h6) - (h2, h5) - (h2, h3) - (h3, h4) - (h3, h6)
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_src=10.0.0.1,nw_dst=10.0.0.4,idle_timeout=0,actions=set_queue:123,normal
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_src=10.0.0.2,nw_dst=10.0.0.5,idle_timeout=0,actions=set_queue:123,normal
#sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_src=10.0.0.3,nw_dst=10.0.0.6,idle_timeout=0,actions=set_queue:123,normal
#sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_src=10.0.0.1,nw_dst=10.0.0.6,idle_timeout=0,actions=set_queue:123,normal
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_src=10.0.0.2,nw_dst=10.0.0.3,idle_timeout=0,actions=set_queue:123,normal
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_src=10.0.0.3,nw_dst=10.0.0.4,idle_timeout=0,actions=set_queue:123,normal

