# LogicCrowd-Netlogo
LogicCrowd - Simulation Model

WHAT IS IT?
In our work, the mobile crowdsourcing simulator has been developed in Netlogo which is a multi-agent modeling language that provides a programmable environment for simulating natural and social phenomena. This model demonstrates the crowd task propagation through a mobile opportunistic network. 

HOW IT WORKS?
Each node represents a mobile device connected with nearby neighbors in communication distances given by the RADIUS chooser. Then the nodes are linked together in the large network. Each time step (tick), a source node (colored red) attempts to distribute the task to neighbors within its connection range. The neighbors that might be the mediator (colored green) or the terminal (colored yellow) will respond with a probability given by the PROBABILITY-PEER-RESPONSES slider. The probability represents the probability of a peer responding to the task for the whole network. 
Before the task will spread through the network, the crowd’s conditions given by WAITING-PERIOD slider, ENERGY-BUDGET slider, DATA-SIZE slider and CONNECTION-MODE chooser have been imposed. Moreover, the FORWORD and BACKGROUND switchers have been given. The FORWARD switcher is an option for turning on or off in order to forward the task to other nodes whereas the BACKGROUND switcher is to switch the display mode (running programing in background or foreground) in a mobile device for estimating the energy during propagation.
During propagation the message, a mediator node is able to reply the message to the source and also forward such task to its neighbors whereas a terminal node is able to only return the answer to the source without forwarding that task to the others. The total number of returned messages to a source and the battery level of a source has been plotted and displayed in the graphs.
 HOW TO USE IT?
Using the sliders, choose the NUMBER-OF-SOURCES, NUMBER-OF-MEDIATORS and NUMBER-OF-TERMINALS.
The network is created based on the peer-to-peer network communication distance given by RADIUS. A node is randomly chosen and connected to the nearest node within the setting distance. This process is repeated until all nodes connected and the links of the nodes is based on the CONNECTIVITY-DENSITY chooser.
Then press SETUP to create the network. Press GO to run the model. The model will stop running once all sources have completely propagated the tasks and received the returned messages from neighbor nodes. Press GO FOREVER to keep running the model over and over again, until whether it is the expiry and no enough battery level of each device to propagate task or the user presses the button again to stop it.
The PROBABILITY-PEER-RESPONSES, WAITING-PERIOD, DATA-SIZE, ENERGY-BUDGET, CONNECTION_MODE, FORWORD, and BACKGROUND (discussed in "How it Works" above) can be adjusted before pressing GO, or while the model is running.
The RETURNED MESSAGES plot shows the total number of peer responses to a source in each round. While, the ENERGY CONSUMPTION plot shows the battery level of a source during propagation the task in each round.
