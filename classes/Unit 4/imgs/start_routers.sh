#! /bin/sh

. ../common/start_functions.sh

fws="router1 router2"
fw1="router1" 
fw2="router2"


if test $# -eq 1; then
    eid=$1
    isEidRunning $eid
else
    for i in $fws
    do
        eid=`himage -e $i`
        if test $? -ne 0 ;then
            echo "Cannot find node $i"
            exit 2
        fi
    done
fi

for i in $fw1
do
    echo Starting iptables on $i...
    himage ${i}@${eid} iptables -F
    
    echo Setting the default policy = DROP
    himage ${i}@${eid} iptables -P FORWARD DROP
    
    echo Setting the HTTP for 10.0.5.11 ICARO
    himage ${i}@${eid} iptables -A FORWARD -p tcp --dport 80 -d 10.0.5.11 -s 10.0.4.0/24  -j ACCEPT
    himage ${i}@${eid} iptables -A FORWARD -p tcp --dport 80 -d 10.0.5.11 -s 10.0.0.0/24  -j ACCEPT
    himage ${i}@${eid} iptables -A FORWARD -p tcp --sport 80 -s 10.0.4.0/24 -d 10.0.5.11 -j ACCEPT
    himage ${i}@${eid} iptables -A FORWARD -p tcp --sport 80 -s 10.0.0.0/24 -d 10.0.5.11 -j ACCEPT

    echo Setting the SSH 10.0.5.10 ZEUS 
	himage ${i}@${eid} iptables -A FORWARD -d 10.0.5.10 -s 10.0.4.0/24 -p tcp --dport 22 -j ACCEPT
	himage ${i}@${eid} iptables -A FORWARD -d 10.0.5.10 -s 10.0.0.0/24 -p tcp --dport 22 -j ACCEPT
	himage ${i}@${eid} iptables -A FORWARD -d 10.0.5.10 -s 10.0.3.21 -p tcp --dport 22 -j ACCEPT
	himage ${i}@${eid} iptables -A FORWARD -s 10.0.5.10 -d 10.0.4.0/24 -p tcp --sport 22 -j ACCEPT
	himage ${i}@${eid} iptables -A FORWARD -s 10.0.5.10 -d 10.0.0.0/24 -p tcp --sport 22 -j ACCEPT
	himage ${i}@${eid} iptables -A FORWARD -s 10.0.5.10 -d 10.0.3.21 -p tcp --sport 22 -j ACCEPT
    
done



for i in $fw2

do
    echo Starting iptables on $i...
    himage ${i}@${eid} iptables -F
    
    echo Setting the default policy = DROP
    himage ${i}@${eid} iptables -P FORWARD DROP
    
    echo Setting the HTTP for 10.0.2.11 THOR
	himage ${i}@${eid} iptables -A FORWARD -p tcp --dport 80 -d 10.0.2.11 -j ACCEPT
	himage ${i}@${eid} iptables -A FORWARD -p tcp --sport 80 -s 10.0.2.11 -j ACCEPT


    echo Setting the FTP for 10.0.2.10 DEDALUS
	himage ${i}@${eid} iptables -A FORWARD -p tcp -m multiport --dports 20,21 -d 10.0.2.10 -j ACCEPT
	himage ${i}@${eid} iptables -A FORWARD -p tcp -m multiport --sports 20,21 -s 10.0.2.10 -j ACCEPT


    echo Setting the HTTP for 10.0.5.11 ICARO
	himage ${i}@${eid} iptables -A FORWARD -p tcp --dport 80 -s 10.0.4.0/24 -d 10.0.5.11 -j ACCEPT
	himage ${i}@${eid} iptables -A FORWARD -p tcp --sport 80 -s  10.0.5.11 -d 10.0.4.0/24 -j ACCEPT


    echo Setting the SSH for 10.0.5.10 ZEUS
	himage ${i}@${eid} iptables -A FORWARD -d 10.0.5.10 -s 10.0.3.21 -p tcp --dport 22 -j ACCEPT
	himage ${i}@${eid} iptables -A FORWARD -d 10.0.5.10 -s 10.0.4.0/24 -p tcp --dport 22 -j ACCEPT
	himage ${i}@${eid} iptables -A FORWARD -s 10.0.5.10 -d 10.0.3.21 -p tcp --sport 22 -j ACCEPT
	himage ${i}@${eid} iptables -A FORWARD -s 10.0.5.10 -d 10.0.4.0/24 -p tcp --sport 22 -j ACCEPT

    
    
done

echo script is configured

