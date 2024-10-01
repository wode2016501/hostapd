#! /system/bin/sh
#添加net0
ip netns add net0
#添加veth 
ip link add veth01 type veth peer name veth02
ip link set dev veth02 netns net0
ip netns exec net0  /system/bin/sh
busybox unshare --fork --pid --mount-proc busybox ps
