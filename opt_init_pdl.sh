#!/bin/sh

echo "潘多拉固件本地插件安装功能部署 5.0"
sleep 1
echo "作者：Chen（陈生工作室）www.gongkong-maker.com"
sleep 1
echo "【免责声明】：仅供学习研究使用，本人不对使用该脚本产生的任何后果负责，需要一定动手能力"
sleep 1
echo "使用本部署脚本，默认同意以上“免责声明”"
sleep 1
echo "如果需要定制该功能固件，可以与我联系（442957525@163.com）"
sleep 1

echo "正在下载安装curl、e2fsprogs等必要软件，请稍等。。。"
opkg install curl libcurl e2fsprogs > /dev/null
if [ "$(which mkfs.ext4)" = "" ] 
then
	opkg install e2fsprogs --force-depends > /dev/null
else
	echo "相关必要软件，已安装完成。。。"
fi
echo "切换脚本目录到/tmp，下载并安装luci-app-c_plugin_5.0.ipk，请稍等。。。"
cd /tmp
wget -q --no-check-certificate "https://github.com/Chen244970717/ipk/raw/master/luci-app-c_plugin_5.0.ipk"
i=1
while [ 1 ]
do
	opkg install luci-app-c_plugin_5.0.ipk --force-depends > /dev/null
	echo "正在安装luci-app-c_plugin_5.0.ipk，请稍等。。。"
	usb=$(mount|grep mnt|awk '{print $3}'|grep sd)
	tf=$(mount|grep mnt|awk '{print $3}'|grep mmc)
	[ -f /usr/sbin/opt_init.sh ] && [ ! "$(pidof opt_init.sh)" = "" ] && echo "luci-app-c_plugin_5.0.ipk安装完成，正在执行opt初始化脚本，请稍等。。。"
	if [ ! "$(mount|grep opt|grep -v grep)" = "" ]
	then
		echo "opt初始化完成，脚本部署完毕，可以刷新页面找到”应用插件“入口，并尝试安装插件了。"
		rm luci-app-c_plugin_5.0.ipk
		exit 0
	else
		if [ ! "$usb" = "" ] && [ ! -f $usb/o_p_t.img ]
		then
			echo "重启opt（$usb）初始化脚本。。。"
			/usr/sbin/opt_init.sh 
		elif [ ! "$tf" = "" ] && [ ! -f $tf/o_p_t.img ]
		then
			echo "重启opt（$tf）初始化脚本。。。"
			/usr/sbin/opt_init.sh 
		elif [ ! "$usb" = "" ] && [ -f $usb/o_p_t.img ]
		then
			echo "重试挂载（$usb）opt。。。"
			[ "$(which mkfs.ext4)" = "" ] && opkg install e2fsprogs --force-depends > /dev/null
			mkfs.ext4 $usb/o_p_t.img<<-EOF
			Y
			EOF
			sleep 1
			mount -t ext4 $usb/o_p_t.img /opt
			echo "$usb" > /tmp/usbdir
		elif [ ! "$tf" = "" ] && [ -f $tf/o_p_t.img ]
		then
			echo "重试挂载（$tf）opt。。。"
			[ "$(which mkfs.ext4)" = "" ] && opkg install e2fsprogs --force-depends > /dev/null
			mkfs.ext4 $usb/o_p_t.img<<-EOF
			Y
			EOF
			sleep 1
			mount -t ext4 $tf/o_p_t.img /opt
			echo "$usb" > /tmp/usbdir
		else
			[ "$(which mkfs.ext4)" = "" ] && opkg install e2fsprogs --force-depends > /dev/null
			echo "初始化失败，正在第$i次重试。。。"
			[ $i -gt 5 ] && echo "抱歉，已多次重试，任然失败，建议尝试重启路由器。。。" && exit 0
		fi
	fi
	echo "初始化失败，正在第$i次重试。。。"
	[ $i -gt 5 ] && echo "抱歉，已多次重试，任然失败，建议尝试重启路由器。。。" && exit 0
	sleep 5
	i=$(expr $i + 1)
done