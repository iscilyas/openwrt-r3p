#!/bin/sh
append DRIVERS "mt7615e2"

. /lib/wifi/ralink_common.sh

prepare_mt7615e2() {
	prepare_ralink_wifi mt7615e2
}

scan_mt7615e2() {
	scan_ralink_wifi mt7615e2 mt7615e
}

disable_mt7615e2() {
	iwpriv ra0 set hw_nat_register=0
	disable_ralink_wifi mt7615e2
}

enable_mt7615e2() {
	enable_ralink_wifi mt7615e2 mt7615e
	iwpriv ra0 set hw_nat_register=1
}

detect_mt7615e2() {
#	detect_ralink_wifi mt7602e mt76x2e
	ssid=mt7615e-`ifconfig eth0 | grep HWaddr | cut -c 51- | sed 's/://g'`
	cd  /sys/module/
	[ -d $module ] || return
        [ -e /etc/config/wireless ] && return
         cat <<EOF
config wifi-device      mt7615e2
        option type     mt7615e2
        option vendor   ralink
        option band     2.4G
        option channel  0
        option autoch   2

config wifi-iface
        option device   mt7615e2
        option ifname   ra0
        option network  lan
        option mode     ap
        option ssid     $ssid
        option encryption psk2
        option key      12345678
        option g256qam      1

EOF

}


