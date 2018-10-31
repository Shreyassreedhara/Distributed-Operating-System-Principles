##################################################################
# Authors: Nirali Patel, Shreyas Gaadikere Sreedhara
# University of Florida
# Distributed Operating System Principles
##################################################################

defmodule Chord_node do

###############################################################
# These functions setup the node. Each node is a Genserver.
# init is called by default when GenServer.start_link is called
###############################################################
    
    use GenServer

    def start_link(selfID, numNodes, numRequests, m, fingerTable, lookUpTable) when is_integer(selfID) do
        GenServer.start_link(__MODULE__, [selfID, numNodes, numRequests, m, fingerTable, lookUpTable], name: register_node(selfID))
    end

    defp register_node(selfID) do
         {:via, Registry, {:node_manager, selfID}}
    end

    @impl true
    def init([selfID, numNodes, numRequests, m, fingerTable, lookUpTable]) do
        lookUpTable = fillLookUpTable(numNodes, lookUpTable, m)
        sendDone(selfID)
        {:ok, [selfID, numNodes, numRequests, m, fingerTable, lookUpTable]}
    end

##########################################################################################
# This function helps to fill the lookup table that will be used to fill the Finger Table
# Input: numNodes, lookUpTable, m
# calls: getHashedID
##########################################################################################

    def fillLookUpTable(numNodes, lookUpTable, m) do
        lookUpTable = 
        for i <- 1..numNodes do
            node = getHashedID(i, m)
            lookUpTable ++ node
        end
        lookUpTable = Enum.sort(lookUpTable)
    end

########################################################################################
# This function receives the command from the master to start filling up its fingerTable
# Input: :fixFingerTable, state
# Calls: fixFingerTable, sendDone
########################################################################################     

    def handle_info({_, :fixFingerTable}, state) do
        [selfID, numNodes, numRequests, m, fingerTable, lookUpTable] = state
        [lowNode, highNode] = findInfo(lookUpTable)
        fingerTable = fixFingerTable(selfID, numRequests, m, fingerTable, lookUpTable, lowNode, highNode, m)
        sendDone(selfID)
        state = List.replace_at(state, 4, fingerTable)
        {:noreply, state}
    end

##############################################################################
# This function returns back the lowest node and the highest node in the table
# Input: lookUpTable
# Calls: None
##############################################################################

    def findInfo(lookUpTable) do
        [lowNode | _] = lookUpTable
        lookUpTable = Enum.reverse(lookUpTable)
        [highNode | _] = lookUpTable
        [lowNode, highNode]
    end

###################################################################################
# This function fills the finger table of the node by referring the lookUpTable
# Input: selfID, numRequests, m, fingerTable, lookUpTable, lowNode, highNode, count
# calls: itself
###################################################################################

    def fixFingerTable(selfID, numRequests, m, fingerTable, lookUpTable, lowNode, highNode, count) when count <= 1 do
        num = rem((selfID + Kernel.trunc(:math.pow(2,m-count))), Kernel.trunc(:math.pow(2,m)))
        fingerTable =
        if(num > highNode) do
            temp = Enum.filter(lookUpTable, fn(z) -> Kernel.trunc(:math.pow(2,m)) + z - num >= 0 end)
            [head | _] = temp
            Map.put(fingerTable, m-count, head)
        else
            temp = Enum.filter(lookUpTable, fn(z) -> (z - num) > 0 end )
            [head | _] = temp
            if Enum.member?(lookUpTable, num) do
                Map.put(fingerTable, m-count, num)
            else
                Map.put(fingerTable, m-count, head)
            end
        end
        fingerTable
    end

    def fixFingerTable(selfID, numRequests, m, fingerTable, lookUpTable, lowNode, highNode, count) do
        num = rem((selfID + Kernel.trunc(:math.pow(2,m-count))), Kernel.trunc(:math.pow(2,m)))
        fingerTable =
        if(num > highNode) do
            temp = Enum.filter(lookUpTable, fn(z) -> Kernel.trunc(:math.pow(2,m)) + z - num >= 0 end)
            [head | _] = temp
            Map.put(fingerTable, m-count, head)
        else
            temp = Enum.filter(lookUpTable, fn(z) -> (z - num) > 0 end )
            [head | _] = temp
            if Enum.member?(lookUpTable, num) do
                Map.put(fingerTable, m-count, num)
            else
                Map.put(fingerTable, m-count, head)
            end
        end
        fixFingerTable(selfID, numRequests, m, fingerTable, lookUpTable, lowNode, highNode, count-1)
    end

###########################################################################
# This function waits for the command from the master to start the requests
# Input: :wait_for_startrequest, state
# Calls: startRequests
###########################################################################

    @impl true
    def handle_info({:wait_for_startrequest}, state) do
        [selfID, numNodes, numRequests, m, fingerTable, lookUpTable] = state
        startRequests(selfID, numNodes, numRequests, m, fingerTable, lookUpTable)
        {:noreply, state}
    end

####################################################################################
# This function returns the successor and predecessor for the node that is passed in
# input: selfID, lookUpTable, lowNode, highNode
# calls: none
####################################################################################

    def findSucPred(selfID, lookUpTable, lowNode, highNode) do
        [successor, predecessor] = 
        cond do
            selfID == highNode -> temp = Enum.filter(lookUpTable, fn(z) -> z < selfID end)
                                  temp1 = Enum.reverse(temp)
                                  [head| _] = temp1
                                  [lowNode, head]
            selfID == lowNode ->  temp = Enum.filter(lookUpTable, fn(z) -> z > selfID end)
                                  [head | _] = temp
                                  [head, highNode]
            true -> temp = Enum.filter(lookUpTable, fn(z) -> z > selfID end)
                    [head | _] = temp
                    temp1 = Enum.filter(lookUpTable, fn(z) -> z < selfID end)
                    temp2 = Enum.reverse(temp1)
                    [head1| _] = temp2
                    [head, head1] 
        end
    end

###################################################################
# This function starts the nodes requests to other nodes
# input: selfID, numNodes, numRequests, m, fingerTable, lookUpTable
# calls: findInfo, findSucPred, getHashedID, sendDone, itself
###################################################################

    def startRequests(selfID, numNodes, numRequests, m, fingerTable, lookUpTable) when numRequests <= 1 do
        # IO.inspect fingerTable, label: "Node #{selfID}'s FT:"
        # IO.inspect lookUpTable, label: "Node #{selfID}'s LT:"
        [lowNode, highNode] = findInfo(lookUpTable)
        [successor, predecessor] = findSucPred(selfID, lookUpTable, lowNode, highNode)
        rand_node = :rand.uniform(Kernel.trunc(:math.pow(2,m)))
        # IO.puts "node: #{selfID} -> random node: #{rand_node}"
        inRange =
        cond do
            selfID == lowNode -> if rand_node > highNode || rand_node <= lowNode do
                                    1
                                 else
                                    0
                                 end 
            true -> if rand_node > predecessor && rand_node <= selfID do
                        1
                    else
                        0
                    end
        end
        if inRange == 1 do
            # IO.puts "#{rand_node} is in range of #{selfID}, sending done"
            sendDone(selfID)
            # startRequests(selfID, numNodes, numRequests-1, m, fingerTable, lookUpTable)
        else
            node_pid =
            cond do
                Map.values(fingerTable) |> Enum.member?(rand_node) -> # IO.puts "node #{rand_node} found in FingerTable for node #{selfID}"
                                                                      Chord_node.whereis(rand_node)
                Map.values(fingerTable) |> Enum.any?(fn(z) -> z < rand_node end) && Enum.filter(lookUpTable, fn(z) -> z < rand_node end) |> Enum.any?(fn(z) -> z > selfID end) -> temp = Map.values(fingerTable) |> Enum.sort() |>Enum.filter(fn(z) -> z - rand_node < 0 end)
                                                                                                                                                                                  temp1 = Enum.reverse(temp)
                                                                                                                                                                                  [head | _] = temp1
                                                                                                                                                                                  # IO.puts "node #{rand_node} in range of FingerTable for node #{selfID}, should forward request to #{head}"
                                                                                                                                                                                  Chord_node.whereis(head)
                true -> # IO.puts "node #{rand_node} is out of the range of FingerTable for node #{selfID}, passing it to successor #{successor}"
                        Chord.whereis(successor)   
            end
            :ets.update_counter(:counter, "counter", {2,1}) 
            GenServer.cast(node_pid, {:find_this_node, rand_node})
        end
    end

    def startRequests(selfID, numNodes, numRequests, m, fingerTable, lookUpTable) do
        # IO.inspect fingerTable, label: "Node #{selfID}'s FT:"
        # IO.inspect lookUpTable, label: "Node #{selfID}'s LT:"
        [lowNode, highNode] = findInfo(lookUpTable)
        [successor, predecessor] = findSucPred(selfID, lookUpTable, lowNode, highNode)
        rand_node = :rand.uniform(Kernel.trunc(:math.pow(2,m)))
        # IO.puts "node: #{selfID} -> random node: #{rand_node}"
        inRange =
        cond do
            selfID == lowNode -> if rand_node > highNode || rand_node <= lowNode do
                                    1
                                 else
                                    0
                                 end 
            true -> if rand_node > predecessor && rand_node <= selfID do
                        1
                    else
                        0
                    end
        end
        if inRange == 1 do
            # IO.puts "#{rand_node} is in range of #{selfID}, sending done and starting a new request"
            sendDone(selfID)
            startRequests(selfID, numNodes, numRequests-1, m, fingerTable, lookUpTable)
        else
            # IO.puts "#{rand_node} not in the range of node #{selfID}"
            node_pid =
            cond do
                Map.values(fingerTable) |> Enum.member?(rand_node) -> # IO.puts "node #{rand_node} found in FingerTable for node #{selfID}"
                                                                      Chord_node.whereis(rand_node)
                Map.values(fingerTable) |> Enum.any?(fn(z) -> z < rand_node end) && Enum.filter(lookUpTable, fn(z) -> z < rand_node end) |> Enum.any?(fn(z) -> z > selfID end)-> temp = Map.values(fingerTable) |> Enum.sort() |> Enum.filter(fn(z) -> z - rand_node < 0 end)
                                                                                                                                                                                 temp1 = Enum.reverse(temp)
                                                                                                                                                                                 [head| _] = temp1
                                                                                                                                                                                 # IO.puts "node #{rand_node} in range of FingerTable for node #{selfID}, should forward request to #{head}"
                                                                                                                                                                                 Chord_node.whereis(head)
                true -> # IO.puts "node #{rand_node} is out of the range of FingerTable for node #{selfID}, passing it to successor #{successor}"
                        Chord.whereis(successor)   
            end
            :ets.update_counter(:counter, "counter", {2,1})
            GenServer.cast(node_pid, {:find_this_node, rand_node}) 
            startRequests(selfID, numNodes, numRequests-1, m, fingerTable, lookUpTable)
        end
    end

############################################################################################
# This function handles the request from other nodes to find the selected nodes. It looks up
# its finger Table and routes the request accordingly while incrementing the hop count
# Input: :find_this_node, rand_node, state
# calls: findInfo, findSucPred, whereis
############################################################################################
    @impl true
    def handle_cast({:find_this_node, rand_node}, state) do
        [selfID, numNodes, numRequests, m, fingerTable, lookUpTable] = state
        # IO.puts "Node #{selfID} has received request to find node #{rand_node}"
        [lowNode, highNode] = findInfo(lookUpTable)
        [successor, predecessor] = findSucPred(selfID, lookUpTable, lowNode, highNode)
        inRange =
        cond do
            selfID == lowNode -> if rand_node > highNode || rand_node <= lowNode do
                                    1
                                 else
                                    0
                                 end 
            true -> if rand_node > predecessor && rand_node <= selfID do
                        1
                    else
                        0
                    end
        end
        if inRange == 1 do
            # IO.puts "node #{rand_node} is in range of node #{selfID}, sending done"
            sendDone(selfID)
        else
            node_pid =
            cond do
                Map.values(fingerTable) |> Enum.member?(rand_node) -> # IO.puts "node #{rand_node} found in FingerTable for node #{selfID}"
                                                                      Chord_node.whereis(rand_node)
                Map.values(fingerTable) |> Enum.any?(fn(z) -> z < rand_node end) && Enum.filter(lookUpTable, fn(z) -> z < rand_node end) |> Enum.any?(fn(z) -> z > selfID end) -> temp = Map.values(fingerTable) |> Enum.sort() |> Enum.filter(fn(z) -> z - rand_node < 0 end)
                                                                                                                                                                                  temp1 = Enum.reverse(temp)
                                                                                                                                                                                  [head | _] = temp1
                                                                                                                                                                                  # IO.puts "node #{rand_node} in range of FingerTable for node #{selfID}, should forward request to #{head}"
                                                                                                                                                                                  Chord_node.whereis(head)
                true -> Chord.whereis(successor)   
            end
            :ets.update_counter(:counter, "counter", {2,1})
            GenServer.cast(node_pid, {:find_this_node, rand_node}) 
        end
        {:noreply, state}
    end

########################################################
# This function sends the done signal back to the master
# Input: selfID
# Calls: :global.whereis_name
########################################################

   def sendDone(selfID) do
       send(:global.whereis_name(:master), {:done,selfID})
   end

################################################################################################
# This function gives hashed value for a number passed in using the simple hashing algorithm 512
# The output of sha will be converted into integer and truncated to length 2^m
# input: i, m
# calls: none
################################################################################################

  def getHashedID(i,m) do
    keyGen = Integer.to_string(i)
    :crypto.hash(:sha512, keyGen) |> Base.encode16 |> Integer.parse(16) |> elem(0) |> rem(Kernel.trunc(:math.pow(2,m)))
  end

###################################################################################################
# This function looks up the registry where the nodes will already have registered their ID and pid
# input: any node ID
# calls: none
###################################################################################################

  def whereis(this_node) do
    case Registry.lookup(:node_manager, this_node) do
      [{pid, _}] -> pid
      [] -> nil
    end
  end     
end
