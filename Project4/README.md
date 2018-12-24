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

First, copy all the files in elixir folder from the downloaded folder and paste it inside the lib folder inside your somefilename project. The files inside the elixir folder are [bitcoin_main.ex](https://github.com/Shreyassreedhara/Distributed-Operating-System-Principles/blob/master/Project4/Elixir%20files/bitcoin_main.ex), [bitcoin_user.ex](https://github.com/Shreyassreedhara/Distributed-Operating-System-Principles/blob/master/Project4/Elixir%20files/bitcoin_user.ex), [bitcoin_miner.ex](https://github.com/Shreyassreedhara/Distributed-Operating-System-Principles/blob/master/Project4/Elixir%20files/bitcoin_miner.ex), [bitcoin_miningtask.ex](https://github.com/Shreyassreedhara/Distributed-Operating-System-Principles/blob/master/Project4/Elixir%20files/bitcoin_miningtask.ex), [bitcoin_block.ex](https://github.com/Shreyassreedhara/Distributed-Operating-System-Principles/blob/master/Project4/Elixir%20files/bitcoin_block.ex).

You can refer this page for more information on [mix](https://elixir-lang.org/getting-started/mix-otp/introduction-to-mix.html)

## Author Information
1. Shreyas Gaadikere Sreedhara, Email - shreyasgaadikere@ufl.edu
2. Nirali Patel, Email - niralipatel@ufl.edu