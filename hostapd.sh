#添加虚拟无线网卡
export PATH=/data/local/bin:$PATH
test  ! -e /data/local/bin/hostapd && mkdir -p /data/local/bin && cp -a  /sdcard/bin/* /data/local/bin && chmod -R 0777 /data/local/bin
cd /data/local/bin
ifconfig wlan2 up || iw wlan0 interface add wlan2 type managed
while iptables -t nat -D POSTROUTING 1;do : ;done
while killall dnsmasq;do sleep 1 ;done
if mount -o remount,rw  / && cp dnsmasq.conf /etc chmod 0777 /etc/dnsmasq.conf && mount -o remount,ro   /;then 
	dnsmasq
else
	#sh proxy.sh
	dnsmasq -C  dnsmasq.conf
fi 
hostapd  -B  5h.conf
sleep 1
ifconfig wlan2 up 
ifconfig br0  192.168.1.1 up

while sleep 1;do                                                                                        
	if busybox route |grep default ;then                                                                    
		sleep 1                                                                                 
	else                                                                                                    
		if ip route get 8.8.8.8 >/dev/null 2>/dev/null ;then                                                    
			while iptables -t nat -D POSTROUTING 1;do :;done
			ip route get 8.8.8.8|head -n 1|awk '{if($3)print "busybox route add default gw "$3"\niptables -t nat -A POSTROUTING -o "$5" -j MASQUERADE"}' >/dev/gw.sh   
			sh /dev/gw.sh ; rm /dev/gw.sh                                                           
		fi                                                                                      
	fi                                                                                              
	cat  /proc/sys/net/ipv4/ip_forward|grep 1|| echo 1 >/proc/sys/net/ipv4/ip_forward       
done

