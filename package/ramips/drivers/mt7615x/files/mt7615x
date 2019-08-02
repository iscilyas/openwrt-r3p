#!/bin/sh /etc/rc.common

START=99
MODNAME=mt7615x
MOD_INTERFACES="ra0 rai0"
UCI_IFPROP="network.lan.ifname"

reverse_word_order() {
    local result=
    for word in $@; do
        result="$word $result"
    done
    echo "$result"
}

wait_if_down() {
    local ifname=$1

    while /sbin/ifconfig | grep -q ^$ifname
    do
        echo "waiting for $ifname to turn off..."
        sleep 1
    done
}

start() {
	/sbin/modprobe $MODNAME
	/sbin/uci set $UCI_IFPROP="`uci get $UCI_IFPROP` $MOD_INTERFACES"
	/sbin/uci commit
	for i in $MOD_INTERFACES
	do
		/sbin/ifconfig $i up
		/usr/sbin/brctl addif br-lan $i
		if ! /sbin/uci get $UCI_IFPROP | grep -q $i
		then
			/sbin/uci set $UCI_IFPROP="`/sbin/uci get $UCI_IFPROP` $i"
		fi
	done
}

stop() {
	local reverse_interfaces=$(reverse_word_order $MOD_INTERFACES)
	for i in $reverse_interfaces
	do
		/usr/sbin/brctl delif br-lan $i
		sleep 5
		/sbin/ifconfig $i down
		wait_if_down $i
	done
	ALLIFS=`/sbin/uci get $UCI_IFPROP`
	/sbin/uci set $UCI_IFPROP="${ALLIFS%$MOD_INTERFACES}"
	/sbin/uci commit
	/sbin/rmmod $MODNAME
}

reload() {
	stop
	start
}
