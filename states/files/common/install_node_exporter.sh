#!/bin/sh

#判断系统版本
v=`cat /etc/redhat-release|sed -r 's/.* ([0-9]+)\..*/\1/'`
if [ $v -eq 6 ]; then
    echo "centos 6"
fi
#  centos-7:
if [ $v -eq 7 ]; then
    echo "centos 7"
fi

function centos6(){
 # 判断是否安装wget，没有则安装
 if [ `rpm -qa |grep wget|wc -l ` -eq 0 ];then
     yum install -y wget
 fi
 # 判断是否安装daemonize，没有则安装，服务后台启动
 cd /usr/local/src
 if [ ! -f daemonize-1.7.7-1.el7.x86_64.rpm  ] ;then
    wget -O daemonize-1.7.7-1.el7.x86_64.rpm  http://rpmfind.net/linux/epel/7/x86_64/Packages/d/daemonize-1.7.7-1.el7.x86_64.rpm
    rpm -ivh daemonize-1.7.7-1.el7.x86_64.rpm
fi
#判断node_exporter安装文件是否存在，不存在则下载
if [ ! -f node_exporter-1.4.0.linux-amd64.tar.gz ];then
    wget -O node_exporter-1.4.0.linux-amd64.tar.gz https://github.com/prometheus/node_exporter/releases/download/v1.4.0/node_exporter-1.4.0.linux-amd64.tar.gz
    cd /usr/local/src && tar -xf  node_exporter-1.4.0.linux-amd64.tar.gz  &&  rm -rf /usr/local/node_exporter && mv node_exporter-1.4.0.linux-amd64 /usr/local/node_exporter
fi
#判断prometheus系统用户是否存在，不存在则创建
id prometheus
    if [ $? -eq 1 ];then
    useradd -M -s /sbin/nologin prometheus
else
    echo  'user prometheus already exists'
fi
#service启动调用参数
if [ `grep 'ARGS' /etc/sysconfig/node_exporter|wc -l` -ge 1 ];then
    echo 'ARGS=""'
else
    echo 'ARGS="--web.config=/usr/local/node_exporter/config.yml"' >>/etc/sysconfig/node_exporter
fi
#判断node_exporter 服务是否启动
if [ `ss -nlp|grep 9100|grep node_exporter|wc -l` -ge 1 ]; then
    echo 'node_exporter already exists'
    service node_exporter status
else
    cd /usr/local/src && tar -xf node_exporter-1.4.0.linux-amd64.tar.gz && rm -rf /usr/local/node_exporter && mv node_exporter-1.4.0.linux-amd64 /usr/local/node_exporter
    echo 'basic_auth_users to config.yml'
    cat > /usr/local/node_exporter/config.yml<<EOF
    basic_auth_users:
    prometheus: \$2y\$12\$xV8w9fq8S5q94kmdUTSB1OraggSITbJ3dnoS996Jl4Gb6LaKH2Fcm
    EOF
    ## 家目录修改属主
    chown -R prometheus:prometheus /usr/local/node_exporter/
    ##拷贝可执行文件到/usr/bin/
    cp  -af /usr/local/node_exporter/node_exporter /usr/bin/node_exporter
    ## 创建运行目录
    mkdir -p /var/run/prometheus/
    chown -R  prometheus.prometheus /var/run/prometheus/
    ## 创建pid文件，并赋权
    touch /var/run/prometheus/node_exporter.pid
    chown -R  prometheus.prometheus /var/run/prometheus/node_exporter.pid
    ## 创建日志目录，并创建日志文件，赋权，修改属主
    mkdir -p /var/log/prometheus/
    touch /var/log/prometheus/node_exporter.log
    chown -R  prometheus.prometheus /var/log/prometheus
    chown -R  prometheus.prometheus /var/log/prometheus/node_exporter.log
    chown prometheus:prometheus /var/log/prometheus/node_exporter.log
##node_exporter 启动脚本
cat >/usr/local/src/node_exporter<<EOF
#!/bin/bash
#       /etc/rc.d/init.d/node_exporter
# chkconfig: 2345 80 80
#
# config: /etc/prometheus/node_exporter.conf
# pidfile: /var/run/prometheus/node_exporter.pid

# Source function library.
. /etc/init.d/functions
RETVAL=0
PROG="node_exporter"
DAEMON_SYSCONFIG=/etc/sysconfig/\${PROG}
DAEMON=/usr/bin/\${PROG} #要把安装目录下/opt/node_exporter/node_exporter可执行文件拷贝到/usr/bin目录下
PID_FILE=/var/run/prometheus/\${PROG}.pid
LOCK_FILE=/var/lock/subsys/\${PROG}
LOG_FILE=/var/log/prometheus/node_exporter.log
DAEMON_USER="prometheus"
FQDN=\$(hostname)
GOMAXPROCS=\$(grep -c ^processor /proc/cpuinfo)

. \${DAEMON_SYSCONFIG}

start() {
  if check_status > /dev/null; then
    echo "node_exporter is already running"
    exit 0
  fi

  echo -n \$"Starting node_exporter: "
  daemonize -u \${DAEMON_USER} -p \${PID_FILE} -l \${LOCK_FILE} -a -e \${LOG_FILE} -o \${LOG_FILE} \${DAEMON} \${ARGS}
  RETVAL=\$?
  echo ""
  return \$RETVAL
}

stop() {
    echo -n \$"Stopping node_exporter: "
    killproc -p \${PID_FILE} -d 10 \${DAEMON}
    RETVAL=\$?
    echo
    [ \$RETVAL = 0 ] && rm -f \${LOCK_FILE} \${PID_FILE}
    return \$RETVAL
}

check_status() {
    status -p \${PID_FILE} \${DAEMON}
    RETVAL=\$?
    return \$RETVAL
}

case "\$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    status)
        check_status
        ;;
    reload|force-reload)
        reload
        ;;
    restart)
        stop
        start
        ;;
    *)
        N=/etc/init.d/\${NAME}
        echo "Usage: \$N {start|stop|status|restart|force-reload}" >&2
        RETVAL=2
        ;;
esac

exit \${RETVAL}
EOF


    cp  -af /usr/local/src/node_exporter /etc/rc.d/init.d
    chmod +x /etc/rc.d/init.d/node_exporter
    cd  /etc/rc.d/init.d && ./node_exporter start
    service node_exporter status
fi
}

function centos7(){
cd /usr/local/src
 #判断是否安装wget
if [ `rpm -qa |grep wget|wc -l ` -eq 0 ];then
     yum install -y wget
fi
 #判断node_exporter安装文件是否存在，不存在则下载
if [ ! -f node_exporter-1.4.0.linux-amd64.tar.gz ];then
    wget -O node_exporter-1.4.0.linux-amd64.tar.gz https://github.com/prometheus/node_exporter/releases/download/v1.4.0/node_exporter-1.4.0.linux-amd64.tar.gz
    cd /usr/local/src && tar -xf  node_exporter-1.4.0.linux-amd64.tar.gz  &&  rm -rf /usr/local/node_exporter && mv node_exporter-1.4.0.linux-amd64 /usr/local/node_exporter
fi
#判断prometheus系统用户是否存在，不存在则创建
id prometheus
if [ $? -eq 1 ];then
    useradd -M -s /sbin/nologin prometheus
else
    echo  'user prometheus already exists'
fi
#判断node_exporter 服务是否启动
if [ `ss -nlp|grep 9100|grep node_exporter|wc -l` -ge 1 ]; then
    systemctl status node_exporter
else
cat >/usr/lib/systemd/system/node_exporter.service<<EOF
 [Unit]
Description=Node_exporter
Documentation=https://github.com/prometheus/node_exporter/
After=network.target

[Service]
WorkingDirectory=/usr/local/node_exporter/
ExecStart=/usr/local/node_exporter/node_exporter --web.config=/usr/local/node_exporter/config.yml
ExecReload=/bin/kill -HUP \$MAINPID
ExecStop=/bin/kill -KILL \$MAINPID
Type=simple
KillMode=control-group
Restart=on-failure
RestartSec=15s

[Install]
WantedBy=multi-user.target
EOF
cd /usr/local/src && tar -xf  node_exporter-1.4.0.linux-amd64.tar.gz  &&  rm -rf /usr/local/node_exporter && mv node_exporter-1.4.0.linux-amd64 /usr/local/node_exporter
echo 'basic_auth_users to config.yml'
cat > /usr/local/node_exporter/config.yml<<EOF
basic_auth_users:
  prometheus: \$2y\$12\$xV8w9fq8S5q94kmdUTSB1OraggSITbJ3dnoS996Jl4Gb6LaKH2Fcm
EOF
    chown -R prometheus:prometheus /usr/local/node_exporter && systemctl daemon-reload && systemctl enable node_exporter && systemctl restart node_exporter && systemctl status node_exporter
fi
}

case $v in
6)
    centos6
;;
7)
    centos7
;;
esac
