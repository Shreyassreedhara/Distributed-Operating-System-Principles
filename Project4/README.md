# Bitcoin network

The aim of this project is to design and simulate a network in which the participants transact bitcoins like in the real world. Although the project doesn't address all the requirements, it surely covers the trivial parts of the bitcoin network. It is necessary to first understand what a bitcoin is and the technology on which the bitcoin has been developed. Following are few links that can be followed to gain an insight of this mysterious and often misunderstood cryptocurrency.

1. [What is a bitcoin?](https://www.youtube.com/watch?v=Um63OQz3bjo)
2. [Which is the driving technology of a bitcoin?](https://www.youtube.com/watch?v=SSo_EIwHSd4)
3. [How do I transact using a bitcoin?](https://www.youtube.com/watch?v=Em8nJN8IEes)

## Steps to run the project

I have used Visual studio code as editor while coding for this project. It has an built in support for syntax and filling suggestion for Elixir. This can be got by installing an additional package along with Visual studio code.

You should have [Elixir](https://elixir-lang.org/install.html) and [Phoenix framework](https://hexdocs.pm/phoenix/installation.html) installed on your system to run the following project on your system. Clone this repository into your system and run the following commands

`mix phx.new somefilename`

This will create a phoenix project for you with the name somefilename. It will already have many files inside it. Now you will need to add some files in some folders and replace some files in order to run this project.

First, copy all the files in elixir folder from the downloaded folder and paste it inside the lib folder inside your somefilename project. The files inside the elixir folder are [bitcoin_main.ex](Elixir_files/bitcoin_main.ex), [bitcoin_user.ex](Elixir_files/bitcoin_user.ex), [bitcoin_miner.ex](Elixir_files/bitcoin_miner.ex), [bitcoin_miningtask.ex](Elixir_files/bitcoin_miningtask.ex), [bitcoin_block.ex](Elixir_files/bitcoin_block.ex).

You can refer this page for more information on [mix](https://elixir-lang.org/getting-started/mix-otp/introduction-to-mix.html)

## Design of the project

The project can be mainly divided into the frontend and backend portion. The backend is written in Elixir and the frontend is written using html and javascript libraries like chart.js in phoenix framework.

The users who does the transaction and the 

Backend files:

1. [bitcoin_main.ex](Elixir_files/bitcoin_main.ex):
    This is the main file. This file contains the logic to do all the work done by the network. The creation of all the users and miners is initiated by this file.

2. [bitcoin_user.ex](Elixir_files/bitcoin_user.ex):

3. [bitcoin_miner.ex](Elixir_files/bitcoin_miner.ex):

4. [bitcoin_miningtask.ex](Elixir_files/bitcoin_miningtask.ex): 
    This file contains the logic for the actual work of the miner. The difficulty level for mining a bitcoin is set here. Also, this file is resposible for the miner to send the newly created block to all the users and miners.

5. [bitcoin_block.ex](Elixir_files/bitcoin_block.ex): 
    This file defines the structure of the block in the bitcoin blockchain network. The fields to be present in the blocks are mentioned here. The default values for the fields are hardcoded to aid in the creation of a genesis block. These fields will be overwritten while creating subsequent blocks in the blockchain. 

Refer the comments in the above files for a detailed explanation of the design.

## Author Information
1. Shreyas Gaadikere Sreedhara, Email - shreyasgaadikere@ufl.edu
2. Nirali Patel, Email - niralipatel@ufl.edu