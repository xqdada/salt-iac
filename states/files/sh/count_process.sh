#!/usr/bin/bash

instance_name=`hostname`
if [ $instance_name == "localhost" ];then
    echo "Must FQDN hostname"
    exit 1
fi

push_server='114.116.194.26:9091'
ip=`/usr/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`

if [ -d /topsee/bin ] ;then
    Service_name=`ls /topsee/bin|grep -E 'seetong|topsee|ruoyi'|grep -v 'topsee-update-php'|xargs`
    echo ${Service_name}
else
    Service_name=`ls /mnt/hdisk|grep -E 'relaysvr_linux_a|p2psvr_linux_a'|xargs`
    echo ${Service_name}
fi

for label_name in ${Service_name};do
    label="${label_name}"
    count_process=`ps -ef |grep -vE 'grep|server_running.log|^tailf|^tail' |grep  "${label_name}/"|wc -l`
    echo "${label_name} : ${count_process}"
    echo "count_process ${count_process}" | curl -s --data-binary @- http://${push_server}/metrics/job/pushgateway_ops/instance/${ip}/Hostname/$instance_name/Service/${label_name}
    if [ ${count_process} -eq 0 ];then
        if [ -d /topsee/bin/${label_name} ];then
            cd /topsee/bin/${label_name}
           ./auto_deploy.sh start
        fi
 
        if [ -f /mnt/hdisk/${label_name}/pgMonitorSvr/bin/wrapper_app ] ;then
           source /etc/profile
           p2p_num=`echo ${label_name}|awk  -F '_' '{print $NF}'`
           /etc/init.d/pgp2pd_a_${p2p_num} start
        fi
    
        if [ -f /mnt/hdisk/${label_name}/pgRelay ];then
           source /etc/profile
           pg_num=`echo ${label_name}|awk  -F '_' '{print $NF}'`
           /etc/init.d/pgRelayd_a_${pg_num} start
           #/mnt/hdisk/${label_name}/pgRelay
        fi
        sleep 1
    fi
 done
