#!/usr/bin/env sh

# outbound iptables
docker exec sleep curl -s helloworld.sample.svc:5000/hello

# smart-dns-proxy
docker exec sleep curl -svI productpage.bookinfo:9080/productpage
docker exec sleep curl -s reviews.bookinfo:9080/reviews/1
docker exec sleep curl -s details.bookinfo:9080/details/1
docker exec sleep curl -s ratings.bookinfo:9080/ratings/1

# pilot-agent ports
netstat -plant|grep pilot
# tcp        0      0 127.0.0.1:15053         0.0.0.0:*               LISTEN      3817/pilot-agent
# tcp        0      0 10.0.0.13:59256         10.0.0.242:15012        ESTABLISHED 3817/pilot-agent
# tcp        0      0 10.0.0.13:59252         10.0.0.242:15012        ESTABLISHED 3817/pilot-agent
# tcp6       0      0 :::15020                :::*                    LISTEN      3817/pilot-agent

cat /etc/resolv.conf
# nameserver 223.5.5.5
# nameserver 223.6.6.6

# iptables -F
# iptables --flush
iptables -t nat -L -v
# Chain PREROUTING (policy ACCEPT 9 packets, 723 bytes)
#  pkts bytes target     prot opt in     out     source               destination
#   285 15387 DOCKER     all  --  any    any     anywhere             anywhere             ADDRTYPE match dst-type LOCAL
#   186  9696 ISTIO_INBOUND  tcp  --  any    any     anywhere             anywhere

# Chain INPUT (policy ACCEPT 194 packets, 10355 bytes)
#  pkts bytes target     prot opt in     out     source               destination

# Chain OUTPUT (policy ACCEPT 127 packets, 7812 bytes)
#  pkts bytes target     prot opt in     out     source               destination
#   107  6420 DOCKER     all  --  any    any     anywhere            !127.0.0.0/8          ADDRTYPE match dst-type LOCAL
#   116  6960 ISTIO_OUTPUT  tcp  --  any    any     anywhere             anywhere
#     0     0 RETURN     udp  --  any    any     anywhere             anywhere             udp dpt:domain owner UID match 1337
#     0     0 RETURN     udp  --  any    any     anywhere             anywhere             udp dpt:domain owner GID match 1337
# 46055 3030K REDIRECT   udp  --  any    any     anywhere             public1.alidns.com   udp dpt:domain redir ports 15053
#    24  1643 REDIRECT   udp  --  any    any     anywhere             public2.alidns.com   udp dpt:domain redir ports 15053

# Chain POSTROUTING (policy ACCEPT 46207 packets, 3039K bytes)
#  pkts bytes target     prot opt in     out     source               destination
#     0     0 MASQUERADE  all  --  any    !docker0  172.17.0.0/16        anywhere

# Chain DOCKER (2 references)
#  pkts bytes target     prot opt in     out     source               destination
#     0     0 RETURN     all  --  docker0 any     anywhere             anywhere

# Chain ISTIO_INBOUND (1 references)
#  pkts bytes target     prot opt in     out     source               destination
#     0     0 RETURN     tcp  --  any    any     anywhere             anywhere             tcp dpt:15008
#     1    64 RETURN     tcp  --  any    any     anywhere             anywhere             tcp dpt:ssh
#     0     0 RETURN     tcp  --  any    any     anywhere             anywhere             tcp dpt:15090
#     0     0 RETURN     tcp  --  any    any     anywhere             anywhere             tcp dpt:15021
#     0     0 RETURN     tcp  --  any    any     anywhere             anywhere             tcp dpt:15020
#   185  9632 ISTIO_IN_REDIRECT  tcp  --  any    any     anywhere             anywhere

# Chain ISTIO_IN_REDIRECT (3 references)
#  pkts bytes target     prot opt in     out     source               destination
#   185  9632 REDIRECT   tcp  --  any    any     anywhere             anywhere             redir ports 15006

# Chain ISTIO_OUTPUT (1 references)
#  pkts bytes target     prot opt in     out     source               destination
#   107  6420 RETURN     all  --  any    lo      127.0.0.6            anywhere
#     0     0 ISTIO_IN_REDIRECT  tcp  --  any    lo      anywhere            !localhost            tcp dpt:!domain owner UID match 1337
#     0     0 RETURN     tcp  --  any    lo      anywhere             anywhere             tcp dpt:!domain ! owner UID match 1337
#     0     0 RETURN     all  --  any    any     anywhere             anywhere             owner UID match 1337
#     0     0 ISTIO_IN_REDIRECT  all  --  any    lo      anywhere            !localhost            owner GID match 1337
#     0     0 RETURN     tcp  --  any    lo      anywhere             anywhere             tcp dpt:!domain ! owner GID match 1337
#     0     0 RETURN     all  --  any    any     anywhere             anywhere             owner GID match 1337
#     0     0 REDIRECT   tcp  --  any    any     anywhere             public1.alidns.com   tcp dpt:domain redir ports 15053
#     0     0 REDIRECT   tcp  --  any    any     anywhere             public2.alidns.com   tcp dpt:domain redir ports 15053
#     0     0 RETURN     all  --  any    any     anywhere             localhost
#     0     0 ISTIO_REDIRECT  all  --  any    any     anywhere             172.21.0.0/20
#     1    60 ISTIO_REDIRECT  all  --  any    any     anywhere             240.240.0.0/16
#     8   480 RETURN     all  --  any    any     anywhere             anywhere

# Chain ISTIO_REDIRECT (2 references)
#  pkts bytes target     prot opt in     out     source               destination
#     1    60 REDIRECT   tcp  --  any    any     anywhere             anywhere             redir ports 15001
