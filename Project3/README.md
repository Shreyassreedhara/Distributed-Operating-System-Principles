# Chord Network Protocol

The aim of this project was to implement a Chord Network Protocol. Chord is based on consistent hashing, which assigns hash keys to nodes in a way that doesn't need to change much as nodes join and leave the system. The chord system doesn't itself store keys and values, but provides primitives that allow higher-layer software to build a wide variety of storage system. Each machine acting as a Chord server has a unique 160-bit Chord node identifier, produced by a simple hashing algorithm(SHA) hash of the node's IP address. In this project, since all the nodes are present on a single system, I have used numbers starting from 1 and ranging till number of nodes specified as the IP addresses of the nodes.

Given a file, the same SHA algorithm can be applied on it and can be converted to a 160 bit identifier. Based on the this identifier and the node identifier the decision will be taken as to on which node this file has to stored. Similarly requesting a file from a node, the node will decide which node to contact, if it doesn't have the file, based on the SHA value of the file requested.

This is a brief of how the chord network works. For detailed explanation [read here](https://en.wikipedia.org/wiki/Chord_(peer-to-peer)) 

## Steps to run the project

I have used [Visual studio code](https://code.visualstudio.com/download) as editor while coding for this project. It has an built support for syntax and filling suggestion for Elixir. This can be got by installing an [additional package](https://marketplace.visualstudio.com/items?itemName=mjmcloug.vscode-elixir) along with Visual studio code.

You should have [Elixir](https://elixir-lang.org/install.html) installed on your system to run the following project on your system. Clone this repository into your system and run the following commands

`mix new somefilename`

Once you run this command a new mix project will be created. Go into the new directory created and inside it you will find a lib directory. Go into the lib directory and delete the files in there. Then copy and paste all the files that you have downloaded that is related to the Project3 inside it. Then open the mix.exs file and add the following line inside the def project do [] and save it

`escript: [main_module: Chord],`

Once that is done, from the directory where mix.exs is present, run the following commands

```
mix escript.build
./project3 numNodes numRequests
```
An example for the above shown command is `./project3 100 10`

You can refer this page for more information on [mix](https://elixir-lang.org/getting-started/mix-otp/introduction-to-mix.html)

## Author Information
1. Shreyas Gaadikere Sreedhara, Email - shreyasgaadikere@ufl.edu
2. Nirali Patel, Email - niralipatel@ufl.edu
