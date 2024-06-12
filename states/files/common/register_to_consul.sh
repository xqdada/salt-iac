#!/usr/bin/bash
for hostname in bjmain;do 
    ENV='生产'
    CSP='华为云'
    Region='北京四'
    Service='PHP 主/负载/推送主服务'
    ip=`salt "\${hostname}" grains.item ipv4 |grep -v -E "127.0.0.1|:|---"|awk '{print $2}'|head -n 1|xargs`
    echo "${hostname}":"${ip}"
    curl -X PUT -d "{\"id\": \"${hostname}\",\"name\": \"node_exporter\",\"address\": \"${ip}\",\"port\": 9100,\"meta\": {\"ENV\": \"${ENV}\",\"CSP\": \"${CSP}\",\"Region\": \"${Region}\",\"Service\": \"${Service}\"}}" http://10.0.0.244:8500/v1/agent/service/register
done
