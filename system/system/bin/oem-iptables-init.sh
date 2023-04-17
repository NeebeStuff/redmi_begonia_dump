#!/system/bin/sh

DISABLE=`getprop persist.tethering.disable_ttlfix`

if [[ $DISABLE == 1 ]]; then
  exit
fi

iptables -t mangle -A POSTROUTING -o ccmni+ -j TTL --ttl-set 64
iptables -t mangle -A PREROUTING -i ccmni+ -j TTL --ttl-inc 1
