# block echo request dct ip
########
#r00_hx#
########
#
# Start only ROOT
#
#!/usr/bin/env bash
#
# Constants
PATH1="$HOME/findip"
VAR="$PATH1/ip.allow"
FND="$PATH1/findip.txt"
VER="$(uname -r)" # Version kernel linux
RUL='iptables -I INPUT 1 -p icmp --icmp-type 8 -m state --state NEW,ESTABLISHED,RELATED -j LOG --log-level=1 --log-prefix "Ping-request: "'
IPT="bee50a4ed019759713f09d1a9c026d7c"
#
#
# Funcion for creating a rule in iptables
func_check_file () {
	if [[ -d $PATH1 ]]
	then
		echo "0" # True
		if [[ -e $VAR ]] 
 
			then echo "0"  # True
		else
			touch $VAR $>> errlog.txt # Create file permition ip-addr
		fi
	else
		mkdir $PATH1 $>> errlog.txt # Create dir save find ip-addr
		touch $VAR 
		if  (( $? ))
		then 
			echo "I don't creating" >> errlog.txt
		fi
	fi
	func_check_rule
}
#
func_check_rule () {

	iptables -L | grep "Ping request:" > rule | md5sum rule > md5sum
	
	if [[ $IPT -eq $md5sum ]]
	then
		echo "0" # True 
		rm -f rule md5sum # clear temp
	else
		$RUL $>> errlog.txt
		rm -f rule md5sum # -//-
	fi
#func_find
}

func_find () { 
	if [[ $VER == '2.4.32-vniins42' ]] ; then 
		awk '{print $11}' /var/log/messages | grep 'SRC' > $PATH1/.sortip # For MCBC 3.0
	else
		awk '{print $12}' /var/log/syslog | grep 'SRC' > $PATH1/.sortip # Sorting addresses
	fi

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
	rm .* str_* sortip* $PATH1 # Delite temp
}

func_start () { 
	if [[ -f $PATH1/ip.allow ]] ; then # If the file exists, then "continue"
		func_find
	else
		func_create
	fi
}

func_check_file
#func_start
