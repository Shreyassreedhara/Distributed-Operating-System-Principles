######################################################                                              
# Authors: Nirali Patel, Shreyas Gaadikere Sreedhara 
# University of Florida								 
# Distributed Operating System Principles		     		
######################################################


#########################################
## Take inputs from the command line
## Input: numNodes, topology, algorithm
## Calls: createActors
#########################################

defmodule Server do
    def main(args) do
        {_,input,_} = OptionParser.parse(args)
        if length(input) == 3 do
            numNodes = String.to_integer(List.first(input))
            algorithm = List.last(input)
            {topology,_} = List.pop_at(input,1)
            Registry.start_link(keys: :unique, name: :node_directory)
            if algorithm == "gossip" || algorithm == "pushsum" do
                createActors(numNodes, topology, algorithm)
            else
                raise ArgumentError, message: "Invalid algorithm name"
            end
        else
			raise ArgumentError, message: "Enter 3 arguments, Ex: ./project 100 full gossip"
        end
    end

####################################################################
## Create actors in the topology and passes its neighbor list to it
## Input: numNodes, topology, algorithm
## Calls: neighborSel, startGossip, startPushSum, killSelf,converged
####################################################################	

    def createActors(numNodes, topology, algorithm) do

	## The gossip algorithm implementation starts from here ##
        if algorithm == "gossip" do
            if topology == "full" do
                neighborList = Enum.to_list 1..numNodes
                for i <- 1..numNodes do
                    pid = spawn(fn -> Gossip_worker.start_link(i,neighborList) end)
                    Process.monitor(pid)
                end
                listner = Task.async(fn -> converged(numNodes) end)
                :global.register_name(:listner, listner.pid)
                :global.register_name(:server, self())
                start_time = System.system_time(:millisecond)
                IO.puts "Start gossip at #{start_time} milliseconds"
                startGossip(numNodes)
                killSelf(numNodes)
                Task.await(listner, :infinity)
                stop_time = System.system_time(:millisecond)
                IO.puts "Network converged at #{stop_time} milliseconds"
                time_diff = stop_time - start_time
                IO.puts "Time taken to achieve convergence is #{time_diff} milliseconds"    
            end

            if topology == "rand2D" do
                :ets.new(:node_table,[:set, :public, :named_table])
				for i <- 1..numNodes do
					:ets.insert(:node_table, {i,:rand.uniform,:rand.uniform})
				end
				for i <- 1..numNodes do
					neighborList = neighborSel(numNodes,i,1,[])
					pid = spawn(fn -> Gossip_worker.start_link(i, neighborList) end)
					Process.monitor(pid)
				end
				listner = Task.async(fn -> converged(numNodes) end)
				:global.register_name(:listner, listner.pid)
				:global.register_name(:server, self())
				start_time = System.system_time(:millisecond)
				IO.puts "Start gossip at #{start_time} millisecond"
				startGossip(numNodes)
				killSelf(numNodes)
				Task.await(listner, :infinity)
				stop_time = System.system_time(:millisecond)
				IO.puts "Network converged at #{stop_time} milliseconds"
				time_diff = stop_time - start_time
				IO.puts "Time taken to achieve convergence is #{time_diff} milliseconds"
				:ets.delete(:node_table)
            end

            if topology == "line" do
				for i <- 1..numNodes do
					neighborList = cond do
								i == 1 ->  [i+1]
								i == numNodes -> [i-1]
								true -> [i-1,i+1]
							end
					pid = spawn(fn -> Gossip_worker.start_link(i,neighborList) end)
					Process.monitor(pid)
				end
				listner = Task.async(fn -> converged(numNodes) end)
				:global.register_name(:listner, listner.pid)
				:global.register_name(:server, self())
				start_time = System.system_time(:millisecond)
				IO.puts "Start gossip at #{start_time} milliseconds"
				startGossip(numNodes)
				killSelf(numNodes)
				Task.await(listner, :infinity)
				stop_time = System.system_time(:millisecond)
				IO.puts "Network converged at #{stop_time} milliseconds"
				time_diff = stop_time - start_time
				IO.puts "Time taken to achieve convergence is #{time_diff} milliseconds"
			end

	    	if topology == "imp2D" do
				for i <- 1..numNodes do
					randNum = :rand.uniform(numNodes)
					if randNum == i or randNum == i+1 or randNum == i-1 do
						randNum = :rand.uniform(numNodes)
					end
					neighborList = cond do
								i == 1 -> [i+1, randNum]
								i == numNodes -> [i-1, randNum]
								true -> [i-1, i+1, randNum]
							end
					pid = spawn(fn -> Gossip_worker.start_link(i,neighborList) end)
					Process.monitor(pid)
				end
				listner = Task.async(fn -> converged(numNodes) end)
				:global.register_name(:listner, listner.pid)
				:global.register_name(:server, self())
				start_time = System.system_time(:millisecond)
				IO.puts "Start gossip at #{start_time} milliseconds"
				startGossip(numNodes)
				killSelf(numNodes)
				Task.await(listner, :infinity)
				stop_time = System.system_time(:millisecond)
				IO.puts "Network converged at #{stop_time} milliseconds"
				time_diff = stop_time - start_time
				IO.puts "Time taken to achieve convergence is #{time_diff} milliseconds"
	    	end

			if topology == "torus" do
				rowcnt = round(:math.sqrt(numNodes))
				for i <- 1..numNodes do
					neighborList = cond do
								i == 1 -> [i+1, i+rowcnt, i+rowcnt-1, numNodes-rowcnt+1]
								i == rowcnt -> [1, i-1, i+rowcnt, numNodes]
								i == numNodes-rowcnt+1 -> [1,numNodes,i+1,i-rowcnt]
								i == numNodes -> [i-1,i-rowcnt,i-rowcnt+1,rowcnt]
								i < rowcnt -> [i-1, i+1, i+rowcnt, numNodes-(rowcnt-i)]
								i > (numNodes - rowcnt + 1) -> [i-1, i+1, i-rowcnt, rowcnt-(numNodes-i)]
								rem(i, rowcnt) == 1 -> [i+1, i-rowcnt, i+rowcnt, i+rowcnt-1]
								rem(i, rowcnt) == 0 -> [i-1, i-rowcnt, i+rowcnt, i-rowcnt+1]
								true -> [i+1, i-1, i-rowcnt, i+rowcnt] 
							end
					pid = spawn(fn -> Gossip_worker.start_link(i,neighborList) end)
					Process.monitor(pid)
				end
				listner = Task.async(fn -> converged(numNodes) end)
				:global.register_name(:listner, listner.pid)
				:global.register_name(:server, self())
				start_time = System.system_time(:millisecond)
				IO.puts "Start gossip at #{start_time} milliseconds"
				startGossip(numNodes)
				killSelf(numNodes)
				Task.await(listner, :infinity)
				stop_time = System.system_time(:millisecond)
				IO.puts "Network converged at #{stop_time} milliseconds"
				time_diff = stop_time - start_time
				IO.puts "Time taken to achieve convergence is #{time_diff} milliseconds"
			end

			if topology == "3D" do
				rowcnt = round(:math.pow(numNodes,0.333333))
				planeCnt = rowcnt * rowcnt
				for i <- 1..numNodes do
					planeNum = Float.ceil(i/planeCnt)
					planeNum = Kernel.trunc(planeNum)
					neighborList = case planeNum do
									1 -> cond do											i == 1 -> [i+1, i+rowcnt, i+planeCnt]
										i == rowcnt -> [rowcnt-1, rowcnt+rowcnt, rowcnt+planeCnt]
										i == planeCnt - rowcnt + 1 -> [i+1, i-rowcnt, i+planeCnt]
										i == planeCnt -> [i-1, i-rowcnt, i+planeCnt]
										i < rowcnt -> [i-1, i+1, i+rowcnt, i+planeCnt]
										rem(i, rowcnt) == 1 -> [i+1, i-rowcnt, i+rowcnt, i+planeCnt]
										rem(i, rowcnt) == 0 -> [i-1, i-rowcnt, i+rowcnt, i+planeCnt]
										i > planeCnt - rowcnt -> [i+1, i-1, i-rowcnt, i+planeCnt]
										true -> [i-1, i+1, i-rowcnt, i+rowcnt, i+planeCnt]
									 end
									rowcnt -> cond do
										i == numNodes - planeCnt + 1 -> [i+1, i+rowcnt, i-planeCnt]
										i == numNodes - planeCnt + rowcnt -> [i-1, i+rowcnt, i-planeCnt]
										i == numNodes - rowcnt + 1 -> [i+1, i-rowcnt, i-planeCnt]
										i == numNodes -> [i-1, i-rowcnt, i-planeCnt]
										i < numNodes - planeCnt + rowcnt -> [i-1, i+1, i+rowcnt, i-planeCnt]
										rem(i, rowcnt) == 1 -> [i+1, i-rowcnt, i+rowcnt, i-planeCnt]
										rem(i, rowcnt) == 0 -> [i-1, i-rowcnt, i+rowcnt, i-planeCnt]
										i > numNodes - rowcnt -> [i+1, i-1, i-rowcnt, i-planeCnt]
										true -> [i-1, i+1, i-rowcnt, i+rowcnt, i-planeCnt]
									 end
									true -> cond do
										i == (planeNum * planeCnt) - planeCnt + 1 -> [i+1, i+rowcnt, i-planeCnt, i+planeCnt]
										i == (planeNum * planeCnt) - planeCnt + rowcnt -> [i-1, i+rowcnt, i-planeCnt, i+planeCnt]
										i == (planeNum * planeCnt) - rowcnt + 1 -> [i+1, i-rowcnt, i-planeCnt, i+planeCnt]
										i == (planeNum * planeCnt) -> [i-1, i-rowcnt, i-planeCnt, i+planeCnt]
										i < (planeNum * planeCnt) - planeCnt + rowcnt -> [i-1, i+1, i+rowcnt, i-planeCnt, i+planeCnt]
										rem(i, rowcnt) == 1 -> [i+1, i-rowcnt, i+rowcnt, i-planeCnt, i+planeCnt]
										rem(i, rowcnt) == 0 -> [i-1, i-rowcnt, i+rowcnt, i-planeCnt, i+planeCnt]
										i > (planeNum * planeCnt) - rowcnt -> [i+1, i-1, i-rowcnt, i-planeCnt, i+planeCnt]
										true -> [i-1, i+1, i-rowcnt, i+rowcnt, i-planeCnt, i+planeCnt]
									 end
					end
					pid = spawn(fn -> Gossip_worker.start_link(i,neighborList) end)
					Process.monitor(pid)
				end
				listner = Task.async(fn -> converged(numNodes) end)
				:global.register_name(:listner, listner.pid)
				:global.register_name(:server, self())
				start_time = System.system_time(:millisecond)
				IO.puts "Start gossip at #{start_time} milliseconds"
				startGossip(numNodes)
				killSelf(numNodes)
				Task.await(listner, :infinity)
				stop_time = System.system_time(:millisecond)
				IO.puts "Network converged at #{stop_time} milliseconds"
				time_diff = stop_time - start_time
				IO.puts "Time taken to achieve convergence is #{time_diff} milliseconds"
			end
		end

		## The implementation of pushsum algorithm starts here ##
		if algorithm == "pushsum" do
			if topology == "full" do
				neighborList = Enum.to_list 1..numNodes
                for i <- 1..numNodes do
                    pid = spawn(fn -> PushSum_worker.start_link(i,neighborList) end)
                    Process.monitor(pid)
                end
                listner = Task.async(fn -> converged(numNodes) end)
                :global.register_name(:listner, listner.pid)
                :global.register_name(:server, self())
                start_time = System.system_time(:millisecond)
                IO.puts "Start gossip at #{start_time} milliseconds"
                startPushSum(numNodes)
                killSelf(numNodes)
                Task.await(listner, :infinity)
                stop_time = System.system_time(:millisecond)
                IO.puts "Network converged at #{stop_time} milliseconds"
                time_diff = stop_time - start_time
                IO.puts "Time taken to achieve convergence is #{time_diff} milliseconds"
			end

			if topology == "line" do
				for i <- 1..numNodes do
					neighborList = cond do
								i == 1 ->  [i+1]
								i == numNodes -> [i-1]
								true -> [i-1,i+1]
							end
					pid = spawn(fn -> PushSum_worker.start_link(i,neighborList) end)
					Process.monitor(pid)
				end
				listner = Task.async(fn -> converged(numNodes) end)
				:global.register_name(:listner, listner.pid)
				:global.register_name(:server, self())
				start_time = System.system_time(:millisecond)
				IO.puts "Start gossip at #{start_time} milliseconds"
				startPushSum(numNodes)
				killSelf(numNodes)
				Task.await(listner, :infinity)
				stop_time = System.system_time(:millisecond)
				IO.puts "Network converged at #{stop_time} milliseconds"
				time_diff = stop_time - start_time
				IO.puts "Time taken to achieve convergence is #{time_diff} milliseconds"
			end

			if topology == "rand2D" do
				:ets.new(:node_table,[:set, :public, :named_table])
				for i <- 1..numNodes do
					:ets.insert(:node_table, {i,:rand.uniform,:rand.uniform})
				end
				for i <- 1..numNodes do
					neighborList = neighborSel(numNodes,i,1,[])
					pid = spawn(fn -> PushSum_worker.start_link(i, neighborList) end)
					Process.monitor(pid)
				end
				listner = Task.async(fn -> converged(numNodes) end)
				:global.register_name(:listner, listner.pid)
				:global.register_name(:server, self())
				start_time = System.system_time(:millisecond)
				IO.puts "Start gossip at #{start_time} millisecond"
				startPushSum(numNodes)
				killSelf(numNodes)
				Task.await(listner, :infinity)
				stop_time = System.system_time(:millisecond)
				IO.puts "Network converged at #{stop_time} milliseconds"
				time_diff = stop_time - start_time
				IO.puts "Time taken to achieve convergence is #{time_diff} milliseconds"
				:ets.delete(:node_table)
			end 

			if topology == "imp2D" do
				for i <- 1..numNodes do
					randNum = :rand.uniform(numNodes)
					if randNum == i or randNum == i+1 or randNum == i-1 do
						randNum = :rand.uniform(numNodes)
					end
					neighborList = cond do
								i == 1 -> [i+1, randNum]
								i == numNodes -> [i-1, randNum]
								true -> [i-1, i+1, randNum]
							end
					pid = spawn(fn -> PushSum_worker.start_link(i,neighborList) end)
					Process.monitor(pid)
				end
				listner = Task.async(fn -> converged(numNodes) end)
				:global.register_name(:listner, listner.pid)
				:global.register_name(:server, self())
				start_time = System.system_time(:millisecond)
				IO.puts "Start gossip at #{start_time} milliseconds"
				startPushSum(numNodes)
				killSelf(numNodes)
				Task.await(listner, :infinity)
				stop_time = System.system_time(:millisecond)
				IO.puts "Network converged at #{stop_time} milliseconds"
				time_diff = stop_time - start_time
				IO.puts "Time taken to achieve convergence is #{time_diff} milliseconds"
			end

			if topology == "torus" do
				rowcnt = round(:math.sqrt(numNodes))
				for i <- 1..numNodes do
					neighborList = cond do
								i == 1 -> [i+1, i+rowcnt, i+rowcnt-1, numNodes-rowcnt+1]
								i == rowcnt -> [1, i-1, i+rowcnt, numNodes]
								i == numNodes-rowcnt+1 -> [1,numNodes,i+1,i-rowcnt]
								i == numNodes -> [i-1,i-rowcnt,i-rowcnt+1,rowcnt]
								i < rowcnt -> [i-1, i+1, i+rowcnt, numNodes-(rowcnt-i)]
								i > (numNodes - rowcnt + 1) -> [i-1, i+1, i-rowcnt, rowcnt-(numNodes-i)]
								rem(i, rowcnt) == 1 -> [i+1, i-rowcnt, i+rowcnt, i+rowcnt-1]
								rem(i, rowcnt) == 0 -> [i-1, i-rowcnt, i+rowcnt, i-rowcnt+1]
								true -> [i+1, i-1, i-rowcnt, i+rowcnt] 
							end
					pid = spawn(fn -> PushSum_worker.start_link(i,neighborList) end)
					Process.monitor(pid)
				end
				listner = Task.async(fn -> converged(numNodes) end)
				:global.register_name(:listner, listner.pid)
				:global.register_name(:server, self())
				start_time = System.system_time(:millisecond)
				IO.puts "Start gossip at #{start_time} milliseconds"
				startPushSum(numNodes)
				killSelf(numNodes)
				Task.await(listner, :infinity)
				stop_time = System.system_time(:millisecond)
				IO.puts "Network converged at #{stop_time} milliseconds"
				time_diff = stop_time - start_time
				IO.puts "Time taken to achieve convergence is #{time_diff} milliseconds"
			end

			if topology == "3D" do
				rowcnt = round(:math.pow(numNodes,0.333333))
				planeCnt = rowcnt * rowcnt
				for i <- 1..numNodes do
					planeNum = Float.ceil(i/planeCnt)
					planeNum = Kernel.trunc(planeNum)
					neighborList = case planeNum do
									1 -> cond do
										i == 1 -> [i+1, i+rowcnt, i+planeCnt]
										i == rowcnt -> [rowcnt-1, rowcnt+rowcnt, rowcnt+planeCnt]
										i == planeCnt - rowcnt + 1 -> [i+1, i-rowcnt, i+planeCnt]
										i == planeCnt -> [i-1, i-rowcnt, i+planeCnt]
										i < rowcnt -> [i-1, i+1, i+rowcnt, i+planeCnt]
										rem(i, rowcnt) == 1 -> [i+1, i-rowcnt, i+rowcnt, i+planeCnt]
										rem(i, rowcnt) == 0 -> [i-1, i-rowcnt, i+rowcnt, i+planeCnt]
										i > planeCnt - rowcnt -> [i+1, i-1, i-rowcnt, i+planeCnt]
										true -> [i-1, i+1, i-rowcnt, i+rowcnt, i+planeCnt]
									 end
									rowcnt -> cond do
											i == numNodes - planeCnt + 1 -> [i+1, i+rowcnt, i-planeCnt]
											i == numNodes - planeCnt + rowcnt -> [i-1, i+rowcnt, i-planeCnt]
											i == numNodes - rowcnt + 1 -> [i+1, i-rowcnt, i-planeCnt]
											i == numNodes -> [i-1, i-rowcnt, i-planeCnt]
											i < numNodes - planeCnt + rowcnt -> [i-1, i+1, i+rowcnt, i-planeCnt]
											rem(i, rowcnt) == 1 -> [i+1, i-rowcnt, i+rowcnt, i-planeCnt]
											rem(i, rowcnt) == 0 -> [i-1, i-rowcnt, i+rowcnt, i-planeCnt]
											i > numNodes - rowcnt -> [i+1, i-1, i-rowcnt, i-planeCnt]
											true -> [i-1, i+1, i-rowcnt, i+rowcnt, i-planeCnt]
										 end
									true -> cond do
											i == (planeNum * planeCnt) - planeCnt + 1 -> [i+1, i+rowcnt, i-planeCnt, i+planeCnt]
											i == (planeNum * planeCnt) - planeCnt + rowcnt -> [i-1, i+rowcnt, i-planeCnt, i+planeCnt]
											i == (planeNum * planeCnt) - rowcnt + 1 -> [i+1, i-rowcnt, i-planeCnt, i+planeCnt]
											i == (planeNum * planeCnt) -> [i-1, i-rowcnt, i-planeCnt, i+planeCnt]
											i < (planeNum * planeCnt) - planeCnt + rowcnt -> [i-1, i+1, i+rowcnt, i-planeCnt, i+planeCnt]
											rem(i, rowcnt) == 1 -> [i+1, i-rowcnt, i+rowcnt, i-planeCnt, i+planeCnt]
											rem(i, rowcnt) == 0 -> [i-1, i-rowcnt, i+rowcnt, i-planeCnt, i+planeCnt]
											i > (planeNum * planeCnt) - rowcnt -> [i+1, i-1, i-rowcnt, i-planeCnt, i+planeCnt]
											true -> [i-1, i+1, i-rowcnt, i+rowcnt, i-planeCnt, i+planeCnt]
										 end
					end
					pid = spawn(fn -> PushSum_worker.start_link(i,neighborList) end)
					Process.monitor(pid)
				end
				listner = Task.async(fn -> converged(numNodes) end)
				:global.register_name(:listner, listner.pid)
				:global.register_name(:server, self())
				start_time = System.system_time(:millisecond)
				IO.puts "Start gossip at #{start_time} milliseconds"
				startPushSum(numNodes)
				killSelf(numNodes)
				Task.await(listner, :infinity)
				stop_time = System.system_time(:millisecond)
				IO.puts "Network converged at #{stop_time} milliseconds"
				time_diff = stop_time - start_time
				IO.puts "Time taken to achieve convergence is #{time_diff} milliseconds"
			end
		end
   	end

##################################################################################
## Select the neighbor for rand2D topology by accessing the ETS only for last node
## Input: numNodes, nodeID, count, list
## Calls: None
###################################################################################

    def neighborSel(numNodes, nodeID, count, list) when count >= numNodes do
		selfcor = :ets.match(:node_table, {nodeID, :"$1", :"$2"})
		[val|tail] = selfcor
		[x|rem] = val
		[y|un] = rem
	 	neighcor = :ets.match(:node_table, {count, :"$1", :"$2"})
		[val1|tail1] = neighcor
		[xs|rem1] = val1
		[ys|un1] = rem1
		firstTerm = :math.pow((x-xs),2)
		secTerm = :math.pow((y-ys),2)
		distance = :math.sqrt(firstTerm+secTerm)
		list = if distance < 0.1 and distance != 0.0 do [count | list] else list
		end
	end

###############################################################
## Select the neighbor for rand2D topology by accessing the ETS 
## Input: numNodes, nodeID, count, list
## Calls: itself for numNodes-1 times
###############################################################

	def neighborSel(numNodes, nodeID, count, list) do
		selfcor = :ets.match(:node_table, {nodeID, :"$1", :"$2"})
		[val|tail] = selfcor
		[x|rem] = val
		[y|un] = rem
	 	neighcor = :ets.match(:node_table, {count, :"$1", :"$2"})
		[val1|tail1] = neighcor
		[xs|rem1] = val1
		[ys|un1] = rem1
		firstTerm = :math.pow((x-xs),2)
		secTerm = :math.pow((y-ys),2)
		distance = :math.sqrt(firstTerm+secTerm)
		list = if distance < 0.1 and distance != 0.0 do [count | list] else list
		end
		neighborSel(numNodes, nodeID, count+1, list)
	end

#################################################
## Choose a random node and initiate the gossip 
## Input: numNodes
## Calls: itself, Gossip_worker
#################################################

    def startGossip(numNodes) do
        pick_node = :rand.uniform(numNodes)
        node_pid = Server.whereis(pick_node)
        if node_pid != nil do
            send(node_pid, {:listner, "Superman and Spiderman are enemies"})
        else
            startGossip(numNodes)
        end
    end

#################################################
## Choose a random node and initiate the pushsum 
## Input: numNodes
## Calls: itself, PushSum_worker
#################################################

	def startPushSum(numNodes) do
		pick_node = :rand.uniform(numNodes)
		node_pid = Server.whereis(pick_node)
		if node_pid != nil do
			send(node_pid, {:initiate, 0, 0})
		else
			startPushSum(numNodes)
		end
	end

#################################################
## Keep track of time convergence is taking 
## Input: numNodes
## Calls: Nonde
#################################################

    def killSelf(numNodes) do
        if numNodes != 0 do
            receive do
                {:DOWN, _, :process, _pid, _reason} -> killSelf(numNodes-1)
            end
        else
            nil
        end
    end

#################################################
## Keep track of number of nodes converged
## Input: numNodes
## Calls: itself, killSelf
#################################################

    def converged(numNodes) do
        if(numNodes != 0) do
            receive do
                {:converged, _} -> converged(numNodes-1)                        
            after
                5000 -> send(:global.whereis_name(:server),{:DOWN, :anything, :process, :random, :getreadytokillself})
                        converged(numNodes-1)
            end
        end
    end

#################################################
## Find the pid for input node from registry
## Input: node name 
## Calls: none
#################################################

    def whereis(this_node) do
        case Registry.lookup(:node_directory, this_node) do
            [{pid,_}] -> pid
            [] -> nil
        end
    end
end
