# Distributed Operating System Principles

All devices from phones to supercomputers are connected to the Internet or other communication networks. On the other hand, we have problems that are too large for any one device. So, we need to involve multiple devices/machines to solve such problems. Distributed systems principles and methods are crucial for tackling such a task. Networking provides the communication infrastructure, Algorithms/Data-structures/Databases the computational techniques but Distributed Systems provide the glue that holds everything together under mildly or harshly adversarial conditions. This class will be focused on tackling the challenges that arise in a principled manner.

## Course Outline

1. Actor model and Elixir
2. Definition, goals and examples of Distributed Systems
3. System architectures and models
4. Inter process communication
5. Remote invocation, indirect communication
6. Operating system support
7. Distributed objects, web services and peer to peer systems
8. Distributed file systems
9. Time and global states
10. Coordination and agreement
11. Transaction and concurreny control
12. Distributed transactions
13. Replication
14. Distributed multimedia systems 
15. Security, access control

## Contents

This folder consists of four distributed system projects that I designed as part of my Distributed Operating System Principles here at the University of Florida. 
1. [Finding perfect sqaures which are also sum of consecutive squares](Project1)
2. [Gossip and Push Sum communication protocols](Project2)
3. [Chord Network protocol](Project3)
4. [Bitcoin network](Project4)

All the projects make use of the actor model for achieving parallelism in a distributed envirnoment. Additional facilities such as tasks, registry and OTP have also been used. These are the tools provided by Elixir to make computing on multiple machines easy and also make the execution of the program parallel in a single multicore machine.

## Author information

1. Shreyas Gaadikere Sreedhara, Email - shreyasgaadikere@ufl.edu
2. Nirali Patel, Email - niralipatel@ufl.edu

## License

https://img.shields.io/github/license/Shreyassreedhara/Distributed-Operating-System-Principles?logo=GitHub
Licensed under the [MIT license](LICENSE.md)
