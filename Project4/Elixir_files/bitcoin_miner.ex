##################################################################
# Authors: Nirali Patel, Shreyas Gaadikere Sreedhara
# University of Florida
# Distributed Operating System Principles
##################################################################

defmodule Bitcoin_miner do

###########################################################################
# These functions setup the miner in the network. Each miner is a Genserver
# init is called by default when GenServer.start_link is called
###########################################################################
    
    use GenServer

    def start_link(selfID, blockchain, tot_miners, tot_users, bitcoinBalance) when is_integer(selfID) do
        GenServer.start_link(__MODULE__, [selfID, blockchain, tot_miners, tot_users, bitcoinBalance], name: register_miner(selfID))
    end

    defp register_miner(selfID) do
         {:via, Registry, {:miners_data, selfID}}
    end

    @impl true
    def init([selfID, blockchain, tot_miners, tot_users, bitcoinBalance]) do
        sendDone(selfID)
        {:ok, [selfID, blockchain, tot_miners, tot_users, bitcoinBalance]}
    end

########################################################
# This function sends the 'done' signal back to the main
# Input: selfID
# Calls: :global.whereis_name
########################################################

    def sendDone(selfID) do
        send(:global.whereis_name(:main), {:done,selfID})
    end

##########################################################################################
# receives command from main to start the mining and validate the unconfirmed transactions
# Input: :startMiniing, state
# Calls: Bitcoin_miningtask.mining
##########################################################################################

    @impl true
    def handle_info({:startMining}, state) do
        [selfID, blockchain, tot_miners, tot_users, bitcoinBalance] = state
        # printUnverifiedList(tot_users)
        minerTask = Task.async(fn -> Bitcoin_miningtask.mining(tot_users, blockchain, selfID, tot_miners) end)
        {:noreply, [selfID, blockchain, tot_miners, tot_users, bitcoinBalance, minerTask]}
    end

#########################################################################################################################
# receives stop command from the other task if the block has been solved, shuts down the task it had created to mine
# If the stop command is received from the task it created, it increments its bitcoin balance along with killing the task 
# Input: senderID, minedBlock
# Calls: :global.whereis_name
#########################################################################################################################

    @impl true
    def handle_cast({:updateBlockchain, minedBlock, senderID}, state) do
        [selfID, blockchain, tot_miners, tot_users, bitcoinBalance, minerTask] = state
        Task.shutdown(minerTask)
        blockchain = blockchain ++ [minedBlock]
        balance_map = %{sender: "Sender:" <> Integer.to_string(selfID),balance: "Bitcoin balance:" <> Integer.to_string(bitcoinBalance)}
        TestWeb.Endpoint.broadcast!("room:lobby", "balance", balance_map)
        IO.puts "Miner #{selfID} lost the race since #{senderID} has mined the block. So, nothing awarded to it" 
        {:noreply, [selfID, blockchain, tot_miners, tot_users, bitcoinBalance, minerTask]}
    end

#########################################################################################################################
# receives stop command from the other task if the block has been solved, shuts down the task it had created to mine
# If the stop command is received from the task it created, it increments its bitcoin balance along with killing the task 
# Input: senderID, minedBlock
# Calls: :global.whereis_name
#########################################################################################################################

    @impl true
    def handle_cast({:updateMyBlockchain, minedBlock, senderID}, state) do
        [selfID, blockchain, tot_miners, tot_users, bitcoinBalance, minerTask] = state
        Task.shutdown(minerTask)
        blockchain = blockchain ++ [minedBlock]
        bitcoinBalance = bitcoinBalance + 10
        IO.puts "Miner #{senderID} has successfully generated a block and has been awarded 10 BTC" 
        {:noreply, [selfID, blockchain, tot_miners, tot_users, bitcoinBalance, minerTask]}
    end

#########################################################################################################
# This function prints all the transactions that are unverified and waiting for the miners to verify them
# Input: tot_users
# Calls: itself
#########################################################################################################

    def printUnverifiedList(tot_users) when tot_users <= 1 do
        temp = :ets.lookup(:unverifiedTransList, tot_users)
        IO.inspect temp, label: "temp"
        [head | _] = temp
        {_, message} = head
        IO.puts message
    end

    def printUnverifiedList(tot_users) do
        temp = :ets.lookup(:unverifiedTransList, tot_users)
        IO.inspect temp, label: "temp"
        [head | _] = temp
        {_, message} = head
        IO.puts message
        printUnverifiedList(tot_users-1)
    end

end
