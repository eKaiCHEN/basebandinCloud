Overview:
Try to adapt wireless baseband(LTE, HSPA, WCDMA etc) software into cloud computing with open source Linux/NoSQL/Message Broker(RabbitMQ) platform supported.

This is NOT multi-core DSPs, but multi-computers connected with slow sockets; No shared memory or fast link in between,but with SQL/NoSQL DB supported

As baseband SW, L2 scheduling and HARQ timing requirement should be fulfilled,hopefully.

The application supposed to be Distributed and Paralleled to utilise the advantage of cloud platform.

Not to loss generality ,the DSP SW modules are written in matlab or standard C come from textbook "Understanding LTE with MATLAB" by Houman Zarrinkoub,2014,WILEY, so it does not touch the topic of adapt highly optimal DSP C code to linux platform.

Developed and tested in Linux/MacOS; cloud related operation tested only with OracleVM (VirtualBoxVM) so far.

Written in python/matlab/C/Shell, for a fast prototype.

Approach:
Approach toward service-oriented SW: service processes/thread(s) with RabbitMQ receiver queue(s) in every node(computer) holding related DSP SW module will provide DSP service to input data from DB(Redis), trigger by service request from RabbitMQ publish queue associated with this service,the internal interface is not web/xml/JSON based as SOA required.
Ref:http://www3.nd.edu/~soseg/soseg/

Approach toward DSP platform: #Todo.....DSP cloud platform with hardware accelerator. 
Ref:http://www.ti.com/lit/wp/spry219/spry219.pdf

SW components overview:
Baseband SW:
LTE L1 data plan DSP SW module fork from "Understanding LTE with MATLAB" by Houman Zarrinkoub,2014,WILEY, also some C module in the future; so it should fit general purpose CPU.
Tx:CRC,Turbo encode,interlevel,scramble,OFDMA Tx,RS
Rx:OFDMA rx,Channel estimation(interpolate by RS), equalizer(MMSE), Decoder
No MIMO, CP, HARQ, timing advance, power control, and any scheduling/L2 processing so far. 

Support SW:
Linux:OS
Ubuntu 14.04LTS
RabbitMQ :Work distribute and loading balance;
RabbitMQ 3.2.4, Erlang R16B03;Python client pika 
Redis:Database for all, including data exchange between different SW module running in different node;
redis-2.8.19,C client Hiredis,Matlab client go-redis, both are clients advised in Redis.io
Matlab:R2014b 

Use Case:
Service Approach 
1.Copy the SW to all nodes inside the cloud and kick off the service, waiting the coming task from RabbitMQ publish queue
2.Send the DSP task(s) request to RabbitMQ receiver queue, by send the command locally or a RESTful http request
3.Remote service receive the request and do the job.

Usage:
http://localhost:8088/Tx should trigger Tx flow
http://localhost:8088/Rx should trgger Rx flow

