##################################################################
# Authors: Nirali Patel, Shreyas Gaadikere Sreedhara
# University of Florida
# Distributed Operating System Principles
##################################################################

defmodule Bitcoin do
  
####################################################################################################
# takes input from command line and creates registers to keep information about the users and miners
# Input: Number of users that have to be in the network
# Calls: createUsers, wait_for_all_nodes, createMiners, bitcoinDemo
####################################################################################################

  def main(args) do
    {_,input,_} = OptionParser.parse(args, strict: [limit: :integer])
    [tot_users | tail] = input
    [scenario | _] = tail
    tot_users = String.to_integer(tot_users)
    if tot_users < 2 do
      raise ArgumentError, message: "The number of users in the network have to be greater than one"
    end
    IO.puts "\n"
    tot_miners = 
    cond do
      scenario == "1" -> IO.puts "SCENARIO 1: There are more users who are transacting than users who are mining"
                         div(tot_users, 2)
      scenario == "2" -> IO.puts "SCENARIO 2: There are more users who are mining than the users who are transacting"
                         tot_users * 2
      scenario == "3" -> IO.puts "SCENARIO 3: There are equal number of users who are transacting and mining in the network"
                         tot_users
    end
    IO.puts "\n"
    IO.puts "Total users in the network #{tot_users}"
    IO.puts "Total miners in the network #{tot_miners}"
    :global.register_name(:main, self())
    Registry.start_link(keys: :unique, name: :users_data)
    Registry.start_link(keys: :unique, name: :miners_data)
    :ets.new(:publicKeyLedger, [:set, :public, :named_table])
    :ets.new(:unverifiedTransList, [:set, :public, :named_table])
    genesisBlock = %Bitcoin_block{}
    IO.inspect genesisBlock, label: "Genesis block"
    blockchain = [] ++ [genesisBlock]
    IO.puts "Each user is given 10 bitcoins to start with"
    initialBitcoins = 10
    createUsers(tot_users, blockchain, initialBitcoins)
    wait_for_all_nodes(tot_users)
    createMiners(blockchain, tot_miners, tot_miners, tot_users)
    wait_for_all_nodes(tot_miners)
    bitcoinDemo(tot_users, tot_miners)
    deleteEts()
    IO.puts "------------------ EXITING -----------------"
  end

###########################################################################################
# Issue command to users to start transactions and update wallets and miners to mine
# Input: Number of users that have to be in the network
# Calls: startTransaction, startMining
###########################################################################################

  def bitcoinDemo(tot_users, tot_miners) do
    updater = Task.async(fn -> transactionUpdater(tot_users) end)
    :global.register_name(:updater, updater.pid)
    transStartTime = DateTime.utc_now |> DateTime.to_string()
    IO.puts "\n"
    IO.puts "Transactions started at #{transStartTime}"
    IO.puts "\n"
    startTimeForTrans = :os.system_time(:millisecond) 
    startTransaction(tot_users, tot_users)
    wait_for_all_nodes(tot_users)
    transStopTime = DateTime.utc_now |> DateTime.to_string()
    IO.puts "\n"
    IO.puts "Transactions finished at #{transStopTime}"
    IO.puts "\n"
    stopTimeForTrans = :os.system_time(:millisecond)
    totalTimeTaken = stopTimeForTrans - startTimeForTrans
    IO.puts "\n"
    IO.puts "Total time taken for all the users to finish transaction is #{totalTimeTaken} milliseconds"
    IO.puts "\n"
    Process.sleep(1000)
    # printUnverifiedList(tot_users)
    mineStartTime = DateTime.utc_now |> DateTime.to_string()
    IO.puts "\n"
    IO.puts "Mining started at #{mineStartTime}"
    IO.puts "\n"
    startTimeForMine = :os.system_time(:millisecond)
    startMining(tot_miners)
    wait_for_miners(1)
    mineStopTime = DateTime.utc_now |> DateTime.to_string()
    IO.puts "\n"
    IO.puts "Mining finished at #{mineStopTime}"
    IO.puts "\n"
    stopTimeForMine = :os.system_time(:millisecond)
    totalTimeTakenMine = stopTimeForMine - startTimeForMine
    IO.puts "\n"
    IO.puts "Total time taken for the block to be mined is #{totalTimeTakenMine} milliseconds"
    IO.puts "\n"
  end

############################################################################################
# Creates as many users in the network as is specified by the command line argument and also 
# creates public and private key for their wallet
# Input: Number of users that have to be in the network, blockchain and the initial BTC 
# Calls: itself
############################################################################################

  def createUsers(tot_users, blockchain, initialBitcoins) when tot_users <= 1 do
    {publicKey, privateKey} = :crypto.generate_key(:ecdh, :secp256k1)
    :ets.insert_new(:publicKeyLedger, {tot_users, publicKey})
    spawn(fn -> Bitcoin_user.start_link(tot_users, blockchain, initialBitcoins, privateKey) end)
  end

  def createUsers(tot_users, blockchain, initialBitcoins) do
    {publicKey, privateKey} = :crypto.generate_key(:ecdh, :secp256k1)
    :ets.insert_new(:publicKeyLedger, {tot_users, publicKey})
    spawn(fn -> Bitcoin_user.start_link(tot_users, blockchain, initialBitcoins, privateKey) end)
    createUsers(tot_users-1, blockchain, initialBitcoins)
  end

##########################################################
# Creates miners and passes the copy of blockchain to them
# Input: Number of users that have to be in the network
# Calls: Bitcoin_miner.start_link
##########################################################

   def createMiners(blockchain, tot_miners, count, tot_users) when count <= 1 do
    spawn(fn -> Bitcoin_miner.start_link(count, blockchain, tot_miners, tot_users, 10) end)
  end
  
  def createMiners(blockchain, tot_miners, count, tot_users) do
    spawn(fn -> Bitcoin_miner.start_link(count, blockchain, tot_miners, tot_users, 10) end)
    createMiners(blockchain, tot_miners, count-1, tot_users)
  end

####################################################################################################
# command the miner to validate all the unconfirmed transactions that has been registered in network
# Input: num of users, num of miners
# Calls: itself
####################################################################################################

  def startMining(count) when count <= 1 do
    send(Bitcoin.whereisMiner(count), {:startMining})
  end

  def startMining(count) do
    send(Bitcoin.whereisMiner(count), {:startMining})
    startMining(count-1)
  end

####################################################################################
# Waits for all the users in the network to send the 'done' signal before proceeding
# Input: Number of users that have to be in the network
# Calls: itself
####################################################################################

  def wait_for_all_nodes(tot_users) when tot_users <= 1 do
    receive do
      {:done,_} -> nil
    end
  end

  def wait_for_all_nodes(tot_users) do
    receive do
      {:done,_} -> nil
    end
    wait_for_all_nodes(tot_users-1)
  end

#####################################################################
# This function tells the users to start transacting among themselves
# input: total users in the network
# calls: itself, Bitcoin.whereis
#####################################################################

  def startTransaction(tot_users, num_of_users) when tot_users <= 1 do
    send(Bitcoin.whereis(tot_users), {:startTransact, num_of_users})
  end

  def startTransaction(tot_users, num_of_users) do
    send(Bitcoin.whereis(tot_users), {:startTransact, num_of_users})
    startTransaction(tot_users-1, num_of_users)
  end

######################################################################################################
# This function looks up the registry where the users will already have registered their names and pid
# input: any node ID
# calls: none
######################################################################################################

  def whereis(this_node) do
    case Registry.lookup(:users_data, this_node) do
      [{pid, _}] -> pid
      [] -> nil
    end
  end

#######################################################################################################
# This function looks up the registry where the miners will already have registered their names and pid
# input: any node ID
# calls: none
#######################################################################################################

  def whereisMiner(this_node) do
    case Registry.lookup(:miners_data, this_node) do
      [{pid, _}] -> pid
      [] -> nil
    end
  end

#############################################################################################################################
# This function waits for the miners to send the ':newBlock' signal when it has created a new block and prints the blockchain
# input: tot_users
# calls: itself
#############################################################################################################################

  def wait_for_miners(tot_users) when tot_users <= 1 do
    receive do
      {:newBlock, newBlock, blockchain, selfID} ->  IO.puts "Miner #{selfID} has verified the transactions and created a new block. It is awarded one BTC"
                                                    [genesisBlock | _] = blockchain
                                                    IO.puts "\n" 
                                                    IO.puts "THE UPDATED BLOCKCHAIN IS ..."
                                                    IO.inspect genesisBlock
                                                    IO.puts "\t \t ~"
                                                    IO.puts "\t \t |"
                                                    IO.puts "\t \t |"
                                                    IO.puts "\t \t |"
                                                    IO.puts "\t \t ~"
                                                    IO.inspect newBlock
    end
  end

  def wait_for_miners(tot_users) do
    receive do
      {:newBlock, newBlock, blockchain, selfID} ->  IO.puts "Miner #{selfID} has verified the transactions and created a new block. It is awarded one BTC"
                                                    [genesisBlock | _] = blockchain
                                                    IO.puts "\n" 
                                                    IO.puts "THE UPDATED BLOCKCHAIN IS ..."
                                                    IO.inspect genesisBlock
                                                    IO.puts "\t \t ~"
                                                    IO.puts "\t \t |"
                                                    IO.puts "\t \t |"
                                                    IO.puts "\t \t |"
                                                    IO.puts "\t \t ~"
                                                    IO.inspect newBlock
      wait_for_miners(tot_users-1)
    end
  end

#####################################################################################################
# This function adds the transactions to the unverified transaction list to be verified by the miners
# input: tot_users
# calls: itself
#####################################################################################################

  def transactionUpdater(tot_users) when tot_users <= 1 do
    receive do
      {_, message} -> :ets.insert_new(:unverifiedTransList, {tot_users, message})
    end
  end

  def transactionUpdater(tot_users) do
    receive do
      {_, message} -> :ets.insert_new(:unverifiedTransList, {tot_users, message})
                      transactionUpdater(tot_users - 1)
    end
  end

#########################################################################################################
# This function prints all the transactions that are unverified and waiting for the miners to verify them
# Input: count, tot_users
# Calls: itself
#########################################################################################################

    def printUnverifiedList(tot_users) when tot_users <= 1 do
        temp = :ets.lookup(:unverifiedTransList, tot_users)
        [head | _] = temp
        {_, message} = head
        IO.puts message
    end

    def printUnverifiedList(tot_users) do
        temp = :ets.lookup(:unverifiedTransList, tot_users)
        [head | _] = temp
        {_, message} = head
        IO.puts message
        printUnverifiedList(tot_users-1)
    end

###########################################################################################
# This function deletes all the declared erlang term storages before the main function dies 
# Input: none
# Calls: none
###########################################################################################

    def deleteEts do
      :ets.delete(:publicKeyLedger)
      :ets.delete(:unverifiedTransList)
    end
end
