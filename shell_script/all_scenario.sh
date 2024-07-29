#!/bin/sh

sudo ovs-vsctl set interface r2-eth3 admin_state=down
sudo ovs-vsctl set interface r4-eth1 admin_state=down
# 1 slice, 1 virtual queue, assigned to multiple host
# Creating 1 virtual queue in Router 1.
echo ' ---------------------------------------------- '
echo '*** Network Slicing: Creating 1 common slice ~ Emergency Scenario ...'
echo 'Router1:'
sudo ovs-vsctl -- \
set port r1-eth1 qos=@newqos -- \
--id=@newqos create QoS type=linux-htb \
other-config:max-rate=10G \
queues:1=@1q -- \
--id=@1q create queue other-config:min-rate=1M other-config:max-rate=5G

echo ' '

# 1 slice, 1 virtual queue, assigned to multiple host
# Creating 1 virtual queue in Router 2.
echo 'Router2:'
sudo ovs-vsctl -- \
set port r2-eth1 qos=@newqos -- \
set port r2-eth2 qos=@newqos -- \
--id=@newqos create QoS type=linux-htb \
other-config:max-rate=10G \
queues:1=@1q -- \
--id=@1q create queue other-config:min-rate=1M other-config:max-rate=5G

echo ' '

echo 'Router3:'
sudo ovs-vsctl -- \
set port r3-eth1 qos=@newqos -- \
set port r3-eth2 qos=@newqos -- \
--id=@newqos create QoS type=linux-htb \
other-config:max-rate=10G \
queues:1=@1q -- \
--id=@1q create queue other-config:min-rate=1M other-config:max-rate=5G

echo ' '

echo 'Router4:'
sudo ovs-vsctl -- \
set port r4-eth2 qos=@newqos -- \
--id=@newqos create QoS type=linux-htb \
other-config:max-rate=10G \
queues:1=@1q -- \
--id=@1q create queue other-config:min-rate=1M other-config:max-rate=5G

echo '*** End of Creating the Slice ...'
echo ' ---------------------------------------------- '
#TX
sudo ovs-ofctl add-flow r1 ip,priority=65500,nw_src=10.0.0.1,idle_timeout=0,actions=flood
