The aim of this project was to implement the Gossip and Push-Sum algorithms. These communication protocols are implied on various topologies such as Full, 3D grid, Random 2D grid, Torus, Line and Imperfect 2D. Based on these topologies, the neighbors of nodes are decided for spreading message. According to the observed time of conevergence i.e., dissemination speed of Gossip protocols/Push-Sum protocols, comparisons were made.

# Contents

The main file [Server.ex](Server.ex) has the logic for the running of the server. The server is responsible for the creation of nodes in the network and pass the neighbor nodes information to the nodes in the network. Based on the input from the user, the number of nodes in the network will be decided. Also, based on the input for the algorithm, corresponding file will be called while creating the nodes in the network. Server is also responsible for starting the gossip/pushsum and keeping track of the total nodes that have converged.

[Gossip_Worker.ex](Gossip_Worker.ex) will be called by the server to create the nodes in the network when the communication protocol is specified as Gossip by the user. This file has the logic to continue the gossip until the nodes converge and then send the converged message back to the Server.

[PushSum_Worker.ex](PushSum_Worker.ex) will be called by the server to create the nodes in the network when the communication protocol is specified as Push-Sum by the user. This file has the logic to perform the push sum protocol, wait till the ratio of sum to weight ratio doesn't change more than (10)^-10 times three consecutive times, and then inform the Server that the node has converged.

# Author Information

1. Shreyas Gaadikere Sreedhara, Email - shreyasgaadikere@ufl.edu
2. Nirali Patel, Email - niralipatel@ufl.edu