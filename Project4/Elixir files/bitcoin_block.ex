##################################################################
# Authors: Nirali Patel, Shreyas Gaadikere Sreedhara
# University of Florida
# Distributed Operating System Principles
##################################################################

defmodule Bitcoin_block do

#######################################################################################
# This function declares a struct for use as block in the bitcoin blockchain technology
# Input: default values [only for genesis block]
# Calls: none
#######################################################################################
    
    defstruct blockID: 0, hashOfPrev: "0000", timeStamp: "2018-11-25 06:19:10.111000Z", data: "00", nonce: "73", hash: "C91BAFAEF88EBE3C39E6B88DC3239551C53F824DE9D8FD42A68DAEA253B576C3"

end