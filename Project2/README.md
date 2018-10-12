# Gossip and Push-Sum communication protocol

The aim of this project was to implement the Gossip and Push-Sum algorithms. These communication protocols are implied on various topologies such as Full, 3D grid, Random 2D grid, Torus, Line and Imperfect 2D. Based on these topologies, the neighbors of nodes are decided for spreading message. According to the observed time of conevergence i.e., dissemination speed of Gossip protocols/Push-Sum protocols, comparisons were made.

## Contents
The main file [Server.ex](Server.ex) has the logic for the running of the server. The server is responsible for the creation of nodes in the network and pass the neighbor nodes information to the nodes in the network. Based on the input from the user, the number of nodes in the network will be decided. Also, based on the input for the algorithm, corresponding file will be called while creating the nodes in the network. Server is also responsible for starting the gossip/pushsum and keeping track of the total nodes that have converged.

[Gossip_Worker.ex](Gossip_Worker.ex) will be called by the server to create the nodes in the network when the communication protocol is specified as Gossip by the user. This file has the logic to continue the gossip until the nodes converge and then send the converged message back to the Server.

[PushSum_Worker.ex](PushSum_Worker.ex) will be called by the server to create the nodes in the network when the communication protocol is specified as Push-Sum by the user. This file has the logic to perform the push sum protocol, wait till the ratio of sum to weight ratio doesn't change more than (10)^-10 times three consecutive times, and then inform the Server that the node has converged.

## Steps to run the project

You should have [Elixir](https://elixir-lang.org/install.html) installed on your system to run the following project on your system. Clone this repository into your system and run the following commands

`mix new somefilename`

Once you run this command a new mix project will be created. Go into the new directory created and inside it you will find a lib directory. Go into the lib directory and delete the files in there. Then copy and paste all the files that you have downloaded that is related to the Project2 inside it. Then open the mix.exs file and add the following line inside the def project do [] and save it

`escript: [main_module: Server],`

Once that is done, from the directory where mix.exs is present, run the following commands

```
mix escript.build
./project numNodes topology algorithm
```
An example for the above shown command is `./project 1000 full gossip`

Different options available for topology are: full, line, imp2D, rand2D, torus and 3D. Different options available for algorithm are: gossip, pushsum

You can refer this page for more information on [mix](https://elixir-lang.org/getting-started/mix-otp/introduction-to-mix.html)

## Author Information
1. Shreyas Gaadikere Sreedhara, Email - shreyasgaadikere@ufl.edu
2. Nirali Patel, Email - niralipatel@ufl.edu
