# Network Slicing Project#

## Short Introduction ##
This is the project #1 for Networking 2 Course held by Fabrizio Granelli. The objective is to implement by demonstration a network slicing strategy, which is able to adapt in case of an emergency situation within the Comnetsemu environment. The Comnetsemu source code can be found [here](https://git.comnets.net/public-repo/comnetsemu.git). 

*First you should follow all the respective instructions indicated in the [README.md](https://git.comnets.net/public-repo/comnetsemu/-/blob/master/README.md) file of the aforementioned link in order to build and install comnetsemu environment.*

In this repo is presented our implementation.


A multi-hop technology has been used for this emulation, i.e., we assume that there are X hosts (h1-hX) and Y routers (r1-rY) in the network:

(mettere immagine)

## Project Description: Emergency Network Slicing ##
(da modificare)

```text
The flow of the project is the following:
**Step 1:** The initial network is built where the (h1, h4) and (h2, h5) communications are enabled. The first link is shared for these communications leading to equal slices. 

**Step 2:** After K seconds the emergency scenario is activated and as a result the other hosts are also enabled. One additional slice is automatically created in the first link, whereas the initial two slices are dynamically reduced.

**Step 3:** After K seconds, the emergency situation is over and as a result the third slice is deleted, and everything is back to the *Step 1* situation (where only 2 slices exist).

*Note:* This process takes place in an automatic iterative manner. 
```

This folder contains the following files:
1. my_network.py: Python script to build a network with X hosts, Y routers and the respective links.

2. common_scenario.sh: Bash script that automatically build virtual queues in the routers for the non-emergency situation.

3. sos_scenario.sh: Bash script that automatically build a third virtual queue/slice in the routers for the emergency communication. 

4. emergency_slicing.py: Application that utilizes the aforementioned scripts in an automatic manner, in order to dynamically implement the network slicing strategy for the emergency communication.

### How to Run ###
You can simply run the emulation application with the following commands within the /home/vagrant/comnetsemu/app/net_slicing_project.

1. Enabling Ryu controller to load the application and to run in the background:
```bash
$ ryu-manager emergency_slicing.py &
```

2. Starting the network with Mininet: 
```bash
$ sudo python3 my_network.py
```

*Note 1:* Please stop the running Ryu controller before starting a new Ryu controller. For example, type `htop` in the terminal to show all running processes, press the key `F4` to look for the process *ryu-manager*, then press the key `F9` to stop the process, with the key `F10` to quite `htop`.

*Note 2:* When you want to stop the mininet, please delete the topology as follows:
```bash
mininet> exit
$ sudo mn -c
```

## How to Verify ##
There are four modes to verify the slices in the non-emergency and the emergency situation:

1. ping mode: verifying connecitvity, e.g.:
*Case 1: Non-Emergency Scenario* 
(da aggiungere)

*Case 2: Emergency Scenario* 
(da aggiungere)


2. iperf mode: verifying slices' bandwidth, e.g. (in both emergency/non-emergency situations):
*Case 1: Non-Emergency Scenario* 
(da aggiungere)


*Case 2: Emergency Scenario* 
(da aggiungere)


3. iperf mode: verifying slices' bandwidth, e.g. (in both emergency/non-emergency situations):
Start listening on the h4 as server and use h1 as client:
(da aggiungere)

Start listening on the h5 as server and use h2 as client:
(da aggiungere)

Start listening on the h6 as server and use h3 as client:
(da aggiungere)


4. client mode: verifying flows in each router and check the virtual queues/slices, e.g.:
(da aggiungere)

(da aggiungere)

## Implementation Details ##
(da aggiungere)

### [FAQ](./doc/faq.md)

### [Useful Links](./doc/ref_links.md)

### Contributing

The Contributors of this project are the following:
- Michele Zucchelli: michele.zucchelli-1@studenti.unitn.it
- Samuele Trainotti: samuele.trainotti@studenti.unitn.it
- Denis Tairovski  : denis.tairovski@studenti.unitn.it


### Contact

Project main maintainers:

- Michele Zucchelli: michele.zucchelli-1@studenti.unitn.it
- Samuele Trainotti: samuele.trainotti@studenti.unitn.it
- Denis Tairovski  : denis.tairovski@studenti.unitn.it