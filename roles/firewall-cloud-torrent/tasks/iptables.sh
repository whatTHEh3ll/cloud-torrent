#!/bin/bash

# Make sure the script is being executed with superuser privileges.
if [[ "${UID}" -ne 0 ]]
then
   echo 'Please run with sudo or as root.' >&2
   exit 1
fi

### 1: Drop invalid packets ### 
/sbin/iptables -t mangle -A PREROUTING -m conntrack --ctstate INVALID -j DROP  

### 2: Drop TCP packets that are new and are not SYN ### 
/sbin/iptables -t mangle -A PREROUTING -p tcp ! --syn -m conntrack --ctstate NEW -j DROP 
 
### 3: Drop SYN packets with suspicious MSS value ### 
/sbin/iptables -t mangle -A PREROUTING -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65535 -j DROP  

### 4: Block packets with bogus TCP flags ### 
/sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP 
/sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP 
/sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags SYN,RST SYN,RST -j DROP 
/sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,RST FIN,RST -j DROP 
/sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,ACK FIN -j DROP 
/sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,URG URG -j DROP 
/sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,FIN FIN -j DROP 
/sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,PSH PSH -j DROP 
/sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL ALL -j DROP 
/sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL NONE -j DROP 
/sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP 
/sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN,FIN,PSH,URG -j DROP 
/sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP  

### 6: Drop ICMP (you usually don't need this protocol) ### 
/sbin/iptables -t mangle -A PREROUTING -p icmp -j DROP  

### 7: Drop fragments in all chains ### 
/sbin/iptables -t mangle -A PREROUTING -f -j DROP  

### 8: Limit connections per source IP ### 
/sbin/iptables -A INPUT -p tcp -m connlimit --connlimit-above 111 -j REJECT --reject-with tcp-reset  

### 9: Limit RST packets ### 
/sbin/iptables -A INPUT -p tcp --tcp-flags RST RST -m limit --limit 2/s --limit-burst 2 -j ACCEPT 
/sbin/iptables -A INPUT -p tcp --tcp-flags RST RST -j DROP  

### 10: Limit new TCP connections per second per source IP ### 
/sbin/iptables -A INPUT -p tcp -m conntrack --ctstate NEW -m limit --limit 60/s --limit-burst 20 -j ACCEPT 
/sbin/iptables -A INPUT -p tcp -m conntrack --ctstate NEW -j DROP  

### 11: Use SYNPROXY on all ports (disables connection limiting rule) ### 
# Hidden - unlock content above in "Mitigating SYN Floods With SYNPROXY" section

### SSH brute-force protection ### 
/sbin/iptables -A INPUT -p tcp --dport ssh -m conntrack --ctstate NEW -m recent --set 
/sbin/iptables -A INPUT -p tcp --dport ssh -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 10 -j DROP  

### Protection against port scanning ### 
/sbin/iptables -N port-scanning 
/sbin/iptables -A port-scanning -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s --limit-burst 2 -j RETURN 
/sbin/iptables -A port-scanning -j DROP

### apply changes
iptables-save > /etc/iptables/rules.v4