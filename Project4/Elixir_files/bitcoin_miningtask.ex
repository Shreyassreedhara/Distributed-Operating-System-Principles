##################################################################
# Authors: Nirali Patel, Shreyas Gaadikere Sreedhara
# University of Florida
# Distributed Operating System Principles
##################################################################

defmodule Bitcoin_miningtask do
    
#####################################################################################
# tries to find nonce such that the block's hash satisfies the difficulty level
# Input: selfID
# Calls: :global.whereis_name, generator, messageEveryUser, messageEveryMiner, itself
#####################################################################################

    def mining(tot_users, blockchain, selfID, tot_miners) do
        prevBlock = List.last(blockchain)
        prevHash = prevBlock.hash
        data = getTransactions(tot_users, "")
        blockId = prevBlock.blockID + 1
        blockID = Integer.to_string(blockId)
        timeStamp = DateTime.utc_now |> DateTime.to_string()
        reqNonce = "sgaadikere" <> generator(9) 
        reqBlock = prevHash <> blockID <> reqNonce
        blockHash = :crypto.hash(:sha256, reqBlock) |> Base.encode16 |> String.downcase
        if(String.slice(blockHash,0,4) === String.duplicate("0",4)) do
            newBlock = %Bitcoin_block{blockID: blockId, hashOfPrev: prevHash, timeStamp: timeStamp, data: data, nonce: reqNonce, hash: blockHash}
            messageOtherMiners(newBlock, tot_miners, selfID)
            messageEveryUser(newBlock, tot_users)
            send(:global.whereis_name(:main), {:newBlock, newBlock, blockchain, selfID})
            messageMyMaster(selfID, newBlock)
        else
           mining(tot_users, blockchain, selfID, tot_miners) 
        end
    end

########################################################################################################
# This function returns a string consisting of all the transactions that are to be verified by the miner
# Input: count, tot_users
# Calls: itself
########################################################################################################

    def getTransactions(tot_users, str) when tot_users <= 1 do
        # IO.puts "tot_users: #{tot_users}"
        temp = :ets.lookup(:unverifiedTransList, tot_users)
        # IO.inspect temp, label: "temp"
        [head | _] = temp
        {_, trans} = head
        str <> trans
    end

    def getTransactions(tot_users, str) do
        # IO.puts "tot_users: #{tot_users}"
        temp = :ets.lookup(:unverifiedTransList, tot_users)
        # IO.inspect temp, label: "temp"
        [head | _] = temp
        {_, trans} = head
        str = str <> trans <> "-"
        getTransactions(tot_users-1, str)
    end

###########################################################################
# generates the random string of length that will be used to create a nonce
# Input: length of string 
# Calls: none
###########################################################################
    
    def generator(length) do
      :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length) |> String.downcase
    end

#############################################################################################################
# Messages every miner to stop mining for that transaction and add newly mined block to their blockchain copy 
# Input: minedBlock, tot_miners
# Calls: Bitcoin.whereis, itself
#############################################################################################################

    def messageOtherMiners(minedBlock, tot_miners, selfID) when tot_miners <= 1 do
        if !(selfID == tot_miners) do
            GenServer.cast(Bitcoin.whereisMiner(tot_miners), {:updateBlockchain, minedBlock, selfID})
        end
    end

    def messageOtherMiners(minedBlock, tot_miners, selfID) do
        if !(selfID == tot_miners) do
            GenServer.cast(Bitcoin.whereisMiner(tot_miners), {:updateBlockchain, minedBlock, selfID})
            messageOtherMiners(minedBlock, tot_miners-1, selfID)
        else
            messageOtherMiners(minedBlock, tot_miners-1, selfID)
        end
    end

#######################################################################
# Messages every user to add newly mined block to their blockchain copy 
# Input: minedBlock, tot_users
# Calls: Bitcoin.whereis, itself
#######################################################################

    def messageEveryUser(minedBlock, tot_users) when tot_users <= 1 do
        GenServer.call(Bitcoin.whereis(tot_users), {:updateBlockchain, minedBlock})
    end

    def messageEveryUser(minedBlock, tot_users) do
        GenServer.call(Bitcoin.whereis(tot_users), {:updateBlockchain, minedBlock})
        messageEveryUser(minedBlock, tot_users-1)
    end

#######################################################################
# Message the master to shutdown the task and award itself one bitcoin 
# Input: selfID
# Calls: Bitcoin.whereis, itself
#######################################################################

    def messageMyMaster(selfID, minedBlock) do
        GenServer.cast(Bitcoin.whereis(selfID), {:updateMyBlockchain, minedBlock, selfID})
    end

end