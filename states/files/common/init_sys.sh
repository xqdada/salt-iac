#!/bin/bash

#set -o errexit

function print_ln() {
cat << EOF
+---------------------------------------------------------------------------+
|  Initialize for the CentOS 7                                              |
+---------------------------------------------------------------------------+
EOF
}

function logger() {
  TIMESTAMP=$(date +'%Y-%m-%d %H:%M:%S')
  case "$1" in
    debug)
      echo -e "$TIMESTAMP \033[36mDEBUG\033[0m $2"
      ;;
    info)
      echo -e "$TIMESTAMP \033[32mINFO\033[0m $2"
      ;;
    warn)
      echo -e "$TIMESTAMP \033[33mWARN\033[0m $2"
      ;;
    error)
      echo -e "$TIMESTAMP \033[31mERROR\033[0m $2"
      ;;
    *)
      ;;
  esac
}

# 关闭防火墙
function stop_firewall() {
    logger info "stop firewall"
    systemctl stop firewalld
    systemctl disable firewalld
}

# 配置SELINUX
function set_selinux() {
    logger info "set selinux"
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
}

# 配置系统HOSTNAME
function set_hostname() {
    hostname=$1
    logger info "set hostname"
    logger info current hostname is "${HOSTNAME}"

    logger info 'please input new hostname(ng:hw-bj-test-massage-00)'
    logger info "hostname 设置为：${hostname}"
    sudo hostnamectl set-hostname ${hostname}
}

# Create Log 创建该脚本运行记录日志
function create_log_file() {
    logger info "Create log file..."
    C_DATE=`date +"%F %H:%M"`
    LOG=/var/log/sysinitinfo.log
    echo $C_DATE >> $LOG
    echo "------------------------------------------" >> $LOG
}

#设置命令历史记录参数
function set_history() {
    echo "Set history commands."
    sudo sed -i 's/HISTSIZE=100/HISTSIZE=1000/' /etc/profile
    sudo sed -i "8 s/^/alias vi='vim'/" /root/.bashrc

    if ! grep 'HISTFILESIZE' /etc/bashrc &>/dev/null;then
sudo cat << EOF >> /etc/bashrc
HISTFILESIZE=4000
HISTSIZE=4000
HISTTIMEFORMAT=" %Y-%m-%d %H:%M:%S  `whoami` "
EOF
    fi
    source /etc/bashrc
}

# set vim 显示行数
function set_vim() {
    echo "Set Vim."
cat << EOF > ~/.vimrc
set number
EOF
}

# Epel 升级epel源
function install_epel() {
    echo "Install epel"
    sudo yum update -y
    sudo yum install epel-release -y
}

#Yum install Development tools  安装开发包组及必备软件
function install_pkgs() {
    echo "Install Development tools(It will be a moment)"
    sudo yum groupinstall -y "Development tools" &> /dev/null
    sudo yum install -y bind-utils lrzsz wget gcc gcc-c++ vim htop openssl &>/dev/null
}

# Yum update bash and openssl  升级bash/openssl
function update_openssl() {
    echo "Update bash and openssl"
    sudo yum -y update bash openssl &> /dev/null
}

# Set ssh 设置ssh登录策略
function sshd_config() {
    echo "Set sshd."
    sudo sed -i.bak "s/^#PermitEmptyPasswords/PermitEmptyPasswords/" /etc/ssh/sshd_config
    sudo sed -i "s/^#LoginGraceTime 2m/LoginGraceTime 6m/" /etc/ssh/sshd_config

    if ! grep "UseDNS no" /etc/ssh/sshd_config &>/dev/null;then
        echo "UseDNS no" >> /etc/ssh/sshd_config
    fi

    #禁止 root 使用 ssh 登入
    sudo sed -i "s/^#PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config

    #修改sshd默认端口
    sudo sed -i "s/^#Port 22/Port 13522/" /etc/ssh/sshd_config
    sudo systemctl  restart sshd.service
}

# Del unnecessary users 删除不必要的用户,新增用户，配置sudo用户
function del_unnecessary_users() {
    echo "Del unnecessary users."
    for user in adm lp sync shutdown halt mail news uucp operator games gopher;do
        if grep $user /etc/passwd &>/dev/null;then
            userdel $user &> /dev/null
        fi
    done

    sudo useradd seetong-ops;
    sudo echo 'YAr3bCLN#5XuU9q&' | passwd --stdin seetong-ops;
    sudo useradd seetong-log;
    sudo echo 'oac&6MGBQTgO3M4C'| passwd --stdin seetong-log;
    sudo useradd seetong;
    sudo echo 'lN$CQ&*W&&dZynHI' | passwd --stdin seetong;
    sudo echo 'seetong-ops        ALL=(ALL)       NOPASSWD: ALL' >>/etc/sudoers
}

# Del unnecessary groups 删除不必要的用户组
function del_unnecessary_groups() {
    echo "Del unnecessary groups."
    for group in adm lp mail news uucp games gopher mailnull floppy dip pppusers popusers slipusers daemon;do
        if grep $group /etc/group &> /dev/null;then
           sudo groupdel $group &> /dev/null
        fi
    done
}

# Disabled reboot by keys ctlaltdelete 禁用ctlaltdelete重启功能
function disable_ctlaltdelte() {
    echo "Disabled reboot by keys ctlaltdelete"
    sudo sed -i 's/^exec/#exec/' /etc/init/control-alt-delete.conf
}

# Set ulimit  设置文件句柄数
function set_limit() {
    echo "Set ulimit 1000000"
sudo cat << EOF > /etc/security/limits.conf

*    soft    nofile  1000000
*    hard    nofile  1000000
*    soft    nproc 102400
*    hard    nproc 102400
root soft    nofile 1000000
root hard    nofile  100000
EOF

    sudo sed -i 's/4096/102400/' /etc/security/limits.d/20-nproc.conf

    echo "Set kernal"
    if [ `grep 'fs.file-max = 1000000' /etc/sysctl.conf |wc -l` -eq 0 ];then
cat >>/etc/sysctl.conf<< EOF
fs.file-max = 1000000
fs.nr_open=1100000
net.ipv4.ip_local_port_range = 5000 65000
EOF
        sysctl -p
    else
        echo 'Set kernal ok'
    fi
}


# Disabled crontab send mail 禁用执行任务计划时向root发送邮件
function disable_cron_send_mail() {
    echo "Disable crontab send mail."
    sudo sed -i 's/^MAILTO=root/MAILTO=""/' /etc/crontab
    sudo sed -i 's/^mail\.\*/mail\.err/' /etc/rsyslog.conf
}

# 安装minion
function install_minion() {
    #SALT_MASTER_HOST="${2:-10.0.0.244}"
    yum install -y https://repo.saltstack.com/py3/redhat/salt-py3-repo-latest.el7.noarch.rpm

    sudo yum clean expire-cache
    sudo yum install -y salt-minion
    sudo cp  /etc/salt/minion /etc/salt/minion.default
    
    ping -c 1 10.0.0.244
    if [[ $? -eq 0 ]];then
        sudo sed -i "s/^#master: salt/master: 10.0.0.244/" /etc/salt/minion 
    else
        sudo sed -i "s/^#master: salt/master: 114.116.194.26/" /etc/salt/minion 
    fi

    sudo systemctl start salt-minion.service
    sudo systemctl status salt-minion.service
    sudo systemctl enable salt-minion.service
    sudo salt-call --local key.finger
}

retry() {
    local retries=3
    local delay=3
    local count=1

    while [ $retries -gt 0 ]; do
      "$@"
      if [ $? -eq 0 ]; then
        return 0
      fi
      retries=$((retries - 1))
      echo "----------------Run $count time,will be retried in ${delay}s ..."
      sleep $delay

      let count+=1
    done

    echo
    echo "========================================================================="
    echo "The retry count has reached the maximum limit, and the operation failed !"
    echo "========================================================================="
    exit 1
}

main() {
    print_ln
    stop_firewall
    set_selinux
    #set_hostname
    create_log_file
    set_history
    set_vim
    retry install_epel
    retry install_pkgs
    retry update_openssl
    sshd_config
    del_unnecessary_users
    del_unnecessary_groups
    disable_ctlaltdelte
    set_limit
    disable_cron_send_mail
    retry install_minion
}

main $*
