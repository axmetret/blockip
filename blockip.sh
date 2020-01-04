# block echo request dct ip
########
#r00_hx#
########
#
# Start only ROOT
#
# Constants
PATH1="$HOME/findip"
VAR="$PATH1/ip.allow"
FND="$PATH1/findip.txt"

func_create () {
	mkdir $PATH1 # Create dir save find ip
	touch $PATH1/ip.allow # Create file permition ip-addresses

	func_find
}

func_find () { 
	awk '{print $12}' /var/log/syslog | grep 'SRC' > $PATH1/.sortip # Sorting addresses
	sed 's/SRC=//' $PATH1/.sortip > $PATH1/sortip # Editing SRC=192.168.1.1 > 192.168.1.1
	sort $PATH1/sortip | uniq > $PATH1/findip.txt # Deleting duplicate address

	func_sort
}

func_sort () { # I can't compare the lines of two files, i cloud think of only this way...fuck!
	for (( i=1; i<256; i++ )) ; do # Write file line by line permition ip
		sed -n "$i"p $VAR > $PATH1/str_i$i 
		if [[ -z $(cat $PATH1/str_i$i) ]] ; then # If the file is onot empty
			for (( f=1; f<256; f++ )) ; do # Write file line by line bad ip
				sed -n "$f"p $FND > $PATH1/str_f$f
				if [[ $(cat $PATH1/str_i$i) = $(cat $PATH1/strf$f) ]] ; then # Compare files
					echo $(cat $PATH1/str_f$f) >> $PATH1/findip.txt
					sort $PATH1/findip.txt | uniq -u > $PATH1/badip.txt
				fi
			done
		fi
	done

	if [[ -n $PATH1/badip.txt ]] ; then # If the file exists, then "continue", if "not" then do nothing
		func_add
	fi
}

func_add () { 
	while read ip ; do # func add rule ip block 
	       iptables -I INPUT 2 -s $ip -j DROP
       done < $PATH1/badip.txt

       func_del
}

func_del () {
	rm .* str_* $PATH1 # Delite temp
}

func_start () { 
	if [[ -f $PATH1/ip.allow ]] ; then # If the file exists, then "continue"
		func_find
	else
		func_create
	fi
}

func_start
