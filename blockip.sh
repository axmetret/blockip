# block echo request dct ip
########
#r00_hx#
########
#
# Start only ROOT
#
func_create () {
	mkdir ~/findip # create dir save find ip
}

finc_find () { 
	awk '{print $12}' /var/log/syslog | grep 'SRC' > ~/findip/.sortip # Sorting addresses
	sed 's/SRC=//' `/findip/.sortip > ~/findip/sortip # editing SRC=192.168.1.1 > 192.168.1.1
	sort ~/findip/sortip | uniq > ~/findip/findip.txt # Deleting duplicate address
}

func_sort () { 
	diff -e ~/findip/findip.txt ~/findip/ip.allow > ~/findip/.badip
	sed '1d' ~/findip/.badip | head -n -2 > ~/findip/badip.txt
}

func_add () { 
	while read ip ; do # func add rule ip block 
	       iptables -I INPUT 2  -s $ip -j DROP
       done < ~/findip/badip.txt
}


