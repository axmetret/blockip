# Adding a logging rule to determine the network scanner
iptables -I UNPUT 1 -p icmp --icmp-type 8 -m state --state NEW,ESTABLISHED,RELATED -j LOG --log-level=1 --log-prefix "Ping request: "

