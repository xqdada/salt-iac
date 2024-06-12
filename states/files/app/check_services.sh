#!/bin/bash

progs=`ps -A`
errcode=$?

# 检查httpd个数；
httpd_num=`echo -e "$progs" | grep httpd | wc -l`
if test 2 -gt $httpd_num;then
    echo "httpd start failed, exit $errcode"
else
    echo "httpd ok"
fi

# 检查memecahed个数，主服务器是4个，其它是3个；
memecached_num=`echo -e "$progs" | grep memcached | wc -l`
if test 3 -ne $memecached_num;then
    echo "memcache start failed, exit $errcode"
else
    echo "memcache ok"
fi

# 检查mysql个数，web服务器不需要用到mysql；
mysqld_num=`echo -e "$progs" | grep mysqld | wc -l`
if test 1 -gt $mysqld_num;then
    echo "mysql server start failed, exit $errcode"
else
    echo "mysql ok"
fi

# 检查告警推送服务；
alarmsender_num=`echo -e "$progs" | grep AlarmSender | wc -l`
if test 1 -gt $alarmsender_num;then
    echo "TAServerd start failed, exit $errcode"
else
    echo "TAServerd ok"
fi