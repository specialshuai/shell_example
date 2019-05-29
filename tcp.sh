#!/bin/sh
#1.check user root and params
if[ $UID -ne 0 ];then
echo"please run it with root"
exit 1
fi
if[ $# -gt 1 ];then
{
		echo"wrong params!"
		cat<<USAGE
usage:	
		./tcp.sh
		./tcp.sh old_config_file
USAGE
		exit
}else if[ $# -eq 1 ];then
		{
				#recover the old config
				if[ !-f $1 ];then
				{
						echo"$1 does not exist!"
						exit 1
				}
				fi
				cat $1 >> /etc/sysctl.conf
				sysctl -p
				if[ $? -eq 0 ];then
						echo"resume old config $1 SUCCESS"
						exit 0
				else
						echo"resume old config not all items get succeeded,please check it"
						exit 1
				fi
		
		}
		fi
fi

#define a tcp parms
a="net.ipv4.tcp_ecn,net.ipv4.tcp_fin_timeout"
OLD_IFS="$IFS"
IFS=","
arr=($a)
IFS=$OLD_IFS
#2.backup the old config
bak_file_name='date|sed's//-/g''".bak"
for item in ${arr[@]}
do
	sysctl -a|grep $item >> $bak_file_name 2>&1
done
#3.remove the old items
for item in ${arr[@]}
do
	sed -i "/^$item/d" /etc/sysctl.conf
done
#4.add the new items
cat>>/etc/sysctl.conf<<EOF
net.ipv4.tcp_ecn = 2
net.ipv4.tcp_fin_timeout = 10
EOF
#5.enable the new added items
sysctl -p
if[ $? -eq 0 ];then
		echo"SUCCESS"
else
		echo"NOT ALL succeeded,please check it"
fi