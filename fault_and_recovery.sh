#!/bin/sh

# disable 'broken' link
sudo ovs-vsctl del-port r4-eth1

# enable recovery link and re-set forwarding rules for hosts where necessary
#sudo ovs-vsctl del-port r4-eth1
