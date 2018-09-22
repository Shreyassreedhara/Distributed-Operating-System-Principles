# 
# Nirali Patel (36318593), Shreyas Gaadikere Sreedhara (13144396)
# University of Florida
#
# Project 1 - Given n and k, calculate the sum of sqaures of numbers starting from 1 till n for k consecutive numbers and 
#            return only such an n for which the sum of squares is a perfect square
#
#            Ex1: n = 3, k = 2
#                Output: 3
#
#            Ex2: n = 40, k = 24
#                Output: 1, 9, 20, 25
#


defmodule Project1 do
    def start do
        n = String.to_integer(Enum.at(System.argv,0))                       # Store n from the args_tuple
        k = String.to_integer(Enum.at(System.argv,1))                       # Store k from the args_tuple
        no_of_cores = 10*System.schedulers_online                           # Total number of cores on the system
        work_range = n / no_of_cores |> Float.ceil |> Kernel.trunc          # number of numbers that has to be processed by each thread 
        t = 1                                                               # Initial number
        create_actors(no_of_cores, t, work_range, k, n, self())             # Recursive function to create actors 
        for _ <- 1..no_of_cores do
            receive do
                {:ok, _} -> nil
            end
        end
    end

    def create_actors(no_of_cores, t, work_range, k, n, pid) when no_of_cores <= 1 do        # Only last actor spawning function
        spawn(Project1, :worker, [t, n, k, n, pid])
    end

    def create_actors(no_of_cores, t, work_range, k, n, pid) do                              # Actor spawning function
        spawn(Project1, :worker, [t, t + work_range, k, n, pid])
        create_actors(no_of_cores - 1, t + work_range + 1, work_range, k, n, pid)
    end

    def worker(start_num, end_num, k, n, pid) do
        for x <- start_num..end_num do
            y = x + k - 1
            sum1 = (y *(y+1) *((2*y)+1))                                    # sum of squares starting from one to range
            sum = div(sum1,6)
            un = x-1
            un_sum = (un * (un+1) * ((2*un)+1))                             # sum of squares starting from one to starting number-1
            unwanted_sum = div(un_sum,6)
            real_sum =  sum - unwanted_sum                                  # sum of squares for required range
            sqr_root = :math.sqrt(real_sum)                                 # root of the number to see if it is a perfect square
            round_sqrt = Float.floor(sqr_root)                   
            if sqr_root - round_sqrt == 0 do                                # if the number is perfect square then print it
                IO.puts "#{x}"
            end
        end
        send pid, {:ok, "done"}                                             # Send message back to the boss
    end
end

Project1.start()