#################################################### 
# Authors: Nirali Patel, Shreyas Gaadikere Sreedhara
# University of Florida
# Distributed Operating System Principles
####################################################

##############################################################################################
## Takes input from the Server.ex file. The actors in the network run this program to converge
## input: SelfID, neighborList
##############################################################################################

defmodule Gossip_worker do

    use GenServer

    def start_link(selfID, neighborList) when is_integer(selfID) do
        GenServer.start_link(__MODULE__, [selfID, neighborList], name: register_node(selfID))
    end

##############################################################################
## Function to register the nodes in the registry
## Key: selfID, value: corresponding pid
##############################################################################

    defp register_node(selfID), do: {:via, Registry, {:node_directory, selfID}}

    def init([selfID, neighborList]) do
            receive do
                {_, rumor} -> rumoringProcess = Task.start fn -> gossiper(selfID,neighborList,rumor) end
                              gossipListner(1, rumoringProcess, selfID)
            end
            {:ok, selfID}    
    end

############################################################################
## Function to listen to rumor being sent. Decides when convergence is done
## input: count and rumoringProcess
## calls: gossiper
############################################################################

    def gossipListner(count, rumoringProcess, selfID) do
        if(count < 10) do
            receive do
                {:chinesewhisper, rumor} -> gossipListner(count+1, rumoringProcess, selfID)
            end
        else
            IO.puts "Node #{selfID} has converged"
            send(:global.whereis_name(:listner), {:converged, self()})
            Task.shutdown(rumoringProcess, :brutal_kill)
        end
    end

#########################################################################################
## Function to send rumor to neighbors in intervals
## input: selfID, neighborList and rumor
## calls: itself 
#########################################################################################

    def gossiper(selfID,neighborList,rumor) do
        index = :rand.uniform(length(neighborList))-1
        selected_node = Enum.at(neighborList, index)
        case selected_node do
            selfID -> if index == length(neighborList)-1 do
                    index - 1
                else
                    index + 1
                end
                selected_node = Enum.at(neighborList,index)
            _ -> nil
        end
        sel_node_addr = whereis(selected_node)
        if sel_node_addr != nil do
            send(sel_node_addr,{:chinesewhisper, rumor})
        end
        Process.sleep(55)
        gossiper(selfID,neighborList,rumor)
    end

######################################################################################
## Returns pid of the node by accessing the registry
######################################################################################

    def whereis(thisNode) do
        case Registry.lookup(:node_directory, thisNode) do
            [{pid, _}] -> pid
            [] -> nil
        end
    end
end
