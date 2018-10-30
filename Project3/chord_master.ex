##################################################################
# Authors: Nirali Patel, Shreyas Gaadikere Sreedhara
# University of Florida
# Distributed Operating System Principles
##################################################################

defmodule Chord do

###################################################################################################
# takes input from command line. Create a registry, counter for keeping track of the number of hops
# Input: numNodes, numRequests
# Calls: createNodes
###################################################################################################
  
  def main(args) do
    {_,input,_} = OptionParser.parse(args)
    if length(input) == 2 do
      numNodes = String.to_integer(List.first(input))
      numRequests = String.to_integer(List.last(input))
      if numNodes < 1 do
        raise ArgumentError, message: "The number of nodes has to be atleast one"
      else
        IO.puts "numNodes is #{numNodes} and numRequests is #{numRequests}"
        if numNodes == 1 do
          IO.puts "Total average hops for the whole network is 0"
        else
          if numRequests < 1 do
            IO.puts "Total average hops for the whole network is 0"
          else
            m = 128
            :global.register_name(:master,self())
            Registry.start_link(keys: :unique, name: :node_manager)
            :ets.new(:counter, [:set, :public, :named_table])
            :ets.insert(:counter,{"counter", 0})
            createNodes(numNodes, numNodes, numRequests, m)
            chord_logic(numNodes, m, numRequests)
          end
        end
      end
    else
      raise ArgumentError, message: "Enter two arguments, Ex: ./project3 10 10"
    end
  end

#########################################################################################
# This function creates the nodes in the network after getting the hashed value of number
# Input: count, numNodes, numRequests, m
# calls: getHashedID, fixFinger
#########################################################################################

  def createNodes(count, numNodes, numRequests, m) when count <= 1 do
    selfID = getHashedID(count, m)
    spawn(fn -> Chord_node.start_link(selfID, numNodes, numRequests, m, %{}, []) end)
  end

  def createNodes(count, numNodes, numRequests, m) do
    selfID = getHashedID(count, m)
    spawn(fn -> Chord_node.start_link(selfID, numNodes, numRequests, m, %{}, []) end)
    createNodes(count-1, numNodes, numRequests, m)
  end

####################################################################################
# This function schedules the various task sequentially that the node has to perform
# Input: numNodes, m, numRequests
# Calls: fixFinger, startRequests, calculateAvgHops, wait_for_all_nodes
####################################################################################

  def chord_logic(numNodes, m, numRequests) do
    wait_for_all_nodes(numNodes)
    fixFinger(numNodes, m)
    wait_for_all_nodes(numNodes)
    startRequests(m, numNodes)
    times_received = numNodes*numRequests
    wait_for_all_nodes(times_received) 
    calculateAvgHops(numNodes, numRequests)
    IO.puts "-------- EXITING ---------"
  end

####################################################################
# This function makes the master wait till all the nodes send 'done'
# Input: numNodes
# calls: None
####################################################################

  def wait_for_all_nodes(numNodes) when numNodes <= 1 do
    receive do
      {:done,_} -> nil
    end
  end

  def wait_for_all_nodes(numNodes) do
    receive do
      {:done,_} -> nil
    end
    wait_for_all_nodes(numNodes-1)
  end

################################################################################################
# This function gives hashed value for a number passed in using the simple hashing algorithm 512
# The final output of this function is a positive unique integer
# input: i, m
# calls: none
################################################################################################

  def getHashedID(i,m) do
    keyGen = Integer.to_string(i)
    :crypto.hash(:sha512, keyGen) |> Base.encode16 |> Integer.parse(16) |> elem(0) |> rem(Kernel.trunc(:math.pow(2,m)))
  end

##########################################################################
# This function gives the command to the nodes to fill their finger tables
# input: numNodes, m
# calls: getHashedID
##########################################################################

  def fixFinger(numNodes, m) when numNodes <= 1 do
    nodeID = getHashedID(numNodes, m)
    node_pid = Chord.whereis(nodeID)
    send(node_pid, {node_pid, :fixFingerTable})
  end

  def fixFinger(numNodes, m) do
    node_ID = getHashedID(numNodes, m)
    node_pid = Chord.whereis(node_ID)
    send(node_pid, {node_pid, :fixFingerTable})
    fixFinger(numNodes-1, m)
  end

######################################################################################################
# This function looks up the registry where the nodes will already have registered their names and pid
# input: any node ID
# calls: none
######################################################################################################

  def whereis(this_node) do
    case Registry.lookup(:node_manager, this_node) do
      [{pid, _}] -> pid
      [] -> nil
    end
  end

####################################################################################
# This function issues message to the nodes to start sending requests to other nodes
# input: m, numNodes
# calls: getHashedID
####################################################################################

  def startRequests(m, numNodes) when numNodes <= 1 do
    nodeID = getHashedID(numNodes, m)
    node_pid = Chord.whereis(nodeID)
    send(node_pid, {:wait_for_startrequest})
  end

  def startRequests(m, numNodes) do
    nodeID = getHashedID(numNodes, m)
    node_pid = Chord.whereis(nodeID)
    send(node_pid, {:wait_for_startrequest})
    startRequests(m, numNodes-1)
  end

#################################################################################################################
# This function takes the total hops value from the counter and calculates the average hops for the whole network 
# Input: numNodes, numRequests
# calls: none
#################################################################################################################

  def calculateAvgHops(numNodes, numRequests) do
    IO.puts "calculating the average hops for the whole network"
    val = :ets.match(:counter, {:"$1", :"$2"})
    [head | _] = val
    [_, count] = head
    totAvgHop = count/(numNodes*numRequests)
    IO.puts "The total average hops taken by all the nodes in the network is #{totAvgHop}"
  end
end