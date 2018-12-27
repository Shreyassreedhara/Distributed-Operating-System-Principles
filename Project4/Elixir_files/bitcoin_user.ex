##################################################################
# Authors: Nirali Patel, Shreyas Gaadikere Sreedhara
# University of Florida
# Distributed Operating System Principles
##################################################################

defmodule Bitcoin_user do

#########################################################################
# These functions setup the user in the network. Each user is a Genserver
# init is called by default when GenServer.start_link is called
#########################################################################
    
    use GenServer

    def start_link(selfID, blockchain, bitcoinBalance, privateKey) when is_integer(selfID) do
        GenServer.start_link(__MODULE__, [selfID, blockchain, bitcoinBalance, privateKey], name: register_user(selfID))
    end

    defp register_user(selfID) do
         {:via, Registry, {:users_data, selfID}}
    end

    @impl true
    def init([selfID, blockchain, bitcoinBalance, privateKey]) do
        sendDone(selfID)
        {:ok, [selfID, blockchain, bitcoinBalance, privateKey]}
    end

########################################################
# This function sends the 'done' signal back to the main
# Input: selfID
# Calls: :global.whereis_name
########################################################

    def sendDone(selfID) do
        send(:global.whereis_name(:main), {:done,selfID})
    end

############################################################################################
# This function receives the command from the main to start one transaction with random user
# Input: :startTransact, total users in the network, state
# Calls: pickRandomUser, signTransaction, sendDone, whereis
############################################################################################

    @impl true
    def handle_info({:startTransact, tot_users}, state) do
        [selfID, blockchain, bitcoinBalance, privateKey] = state
        randomNode = pickRandomUser(selfID, tot_users)
        IO.puts "TRANSACTION: User #{selfID} ----- 1 BTC ------> User #{randomNode}"
        message = Integer.to_string(selfID, 10) <> "-" <> Integer.to_string(randomNode, 10) <> "-" <> "1"
        IO.puts "Message to User #{randomNode} from #{selfID}: #{message} [sender, receiver, number of BTC]"
        signature = signTransaction(message, privateKey)
        sendDone(selfID)
        GenServer.cast(Bitcoin.whereis(randomNode), {:transDetails, selfID, message, signature})
        {:noreply, [selfID, blockchain, bitcoinBalance-1, privateKey]}
    end

##########################################################################################################
# This function processes the payments made by the other users and puts it in unverified transactions list
# Input: :transDetails, senderID, message, signature, state
# Calls: getPublicKey, sendDone
##########################################################################################################     

    @impl true
    def handle_cast({:transDetails, senderID, message, signature}, state) do
        [selfID, blockchain, bitcoinBalance, privateKey] = state
        # IO.puts "User #{selfID} received 1 BTC from User #{senderID}"
        publicKey = getPublicKey(senderID)
        truthOfTransaction = :crypto.verify(:ecdsa, :sha256, message, signature, [publicKey, :secp256k1])
        if truthOfTransaction == true do
            IO.puts "Signature sent by user #{senderID} to user #{selfID} has been verified as correct; pending verification; added to unverified list"
            #:ets.insert_new(:unverifiedTransList, {selfID, message})
            send(:global.whereis_name(:updater), {selfID, message})
        else
            IO.puts "Signature sent doesn't pass the verification process with user's public key"
        end
        sendDone(selfID)
        {:noreply, [selfID, blockchain, bitcoinBalance + 1, privateKey]}
    end

######################################################
# Updates the blockchain if a new block has been mined
# Input: :updateBlockchain, minedBlock, state
# Calls: none
######################################################

    @impl true
    def handle_call({:updateBlockchain, minedBlock}, _from, state) do
        [selfID, blockchain, bitcoinBalance, privateKey] = state
        blockchain = blockchain ++ [minedBlock]
        {:reply, :ok, [selfID, blockchain, bitcoinBalance, privateKey]}
    end

##############################################################################################
# This function picks a random user from the total users in the network, avoids picking itself
# Input: selfID, total users in the system
# Calls: itself
##############################################################################################

    def pickRandomUser(selfID, tot_users) do
        randUser = :rand.uniform(tot_users)
        if randUser != selfID do
            randUser
        else
            pickRandomUser(selfID, tot_users)
        end
    end

########################################################################################################
# This function signs the transaction so that the recepient is sure about who is transferring the rights 
# Input: message, privateKey
# Calls: none
#######################################################################################################

    def signTransaction(message, privateKey) do
        :crypto.sign(:ecdsa, :sha256, message, [privateKey, :secp256k1])
    end

###########################################################
# This function returns the public key of the input UserID
# Input: senderID
# Calls: none
###########################################################

    def getPublicKey(senderID) do
        result = :ets.lookup(:publicKeyLedger, senderID)
        [head | _] = result
        {_, publicKey} = head
        publicKey
    end

#####################################################################################
# Creates a bitcoin address from the private/public key pair to be used in validation
# Input: none
# Calls: base58encode
#####################################################################################

    def bitcoinaddress do
        {publicKey, _} = :crypto.generate_key(:ecdh, :secp256k1)
        publicKey = publicKey |> Base.encode16
        publicKeyHashPreset = :crypto.hash(:sha256,publicKey)
        publicKeyHash = :crypto.hash(:ripemd160, publicKeyHashPreset)
        trailer = :crypto.hash(:sha256,publicKeyHash)
        trailer = :crypto.hash(:sha256,trailer)
        trailer = String.slice(trailer,0,8)
        publicKeyHash = publicKeyHash <> trailer
        publicKeyHash = <<0x00>> <> publicKeyHash
        publicKeyHash = :binary.decode_unsigned(publicKeyHash)
        answer = base58encode(publicKeyHash,"")
        String.reverse(answer)
    end

############################################################################################
# Creates a base58 encoding of the publicKeyHash. The resultant string is easy to copy-paste
# and also easy to write down without making a mistake
# Input: none
# Calls: itself
############################################################################################

    def base58encode(publicKeyHash, answer) when publicKeyHash <= 58 do
        code_string = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
        publicKeyHash = div(publicKeyHash,58)
        remainder = rem(publicKeyHash,58)
        answer = answer <> String.at(code_string,remainder)
        answer
    end

    def base58encode(publicKeyHash, answer) do
        code_string = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
        publicKeyHash = div(publicKeyHash,58)
        remainder = rem(publicKeyHash,58)
        answer = answer <> String.at(code_string,remainder)
        base58encode(publicKeyHash,answer)
    end

end