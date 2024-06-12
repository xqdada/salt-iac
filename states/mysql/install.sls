mysql-install:
  pkg.installed:
    - sources:
      - mysql-community-common: {{ pillar['BAKDIR'] }}/mysql-community-common-5.7.32-1.el7.x86_64.rpm
      - mysql-community-libs: {{ pillar['BAKDIR'] }}/mysql-community-libs-5.7.32-1.el7.x86_64.rpm
      - mysql-community-libs-compat: {{ pillar['BAKDIR'] }}/mysql-community-libs-compat-5.7.32-1.el7.x86_64.rpm
      - mysql-community-client: {{ pillar['BAKDIR'] }}/mysql-community-client-5.7.32-1.el7.x86_64.rpm
      - mysql-community-server: {{ pillar['BAKDIR'] }}/mysql-community-server-5.7.32-1.el7.x86_64.rpm
    - unless: rpm -qa|grep -qE "^mysql-community"

script-exec:
 cmd.run:
  - name: |  
      if [[ ! -f /lib64/libcurl.so.4.7.0 ]];then
        cp -rf {{ pillar['BAKDIR'] }}/libcurl.so.4.7.0 /lib64
        rm -f /lib64/libcurl.so.4 /lib64/libcurl.so
      fi

      if [[ !-f /lib64/libcurl.so.4 && ! -f /lib64/libcurl.so ]];then
        ln -s /lib64/libcurl.so.4.7.0 /lib64/libcurl.so.4
        ln -s /lib64/libcurl.so.4.7.0 /lib64/libcurl.so
      fi

      cp -rf {{ pillar['BAKDIR'] }}/curl /bin
      cp -rf {{ pillar['BAKDIR'] }}/my.cnf /etc

      # Add mysql user
      user=mysql
      group=$user
      #create group if not exists
      if ! egrep "^$group" /etc/group >& /dev/null;then
        groupadd $group  
      fi

      # create user if not exists  
      if ! egrep "^$user" /etc/passwd >& /dev/null;then  
        useradd -r -g $group $user  
      fi

mysql-start:
  cmd.run:
  - name: |
      [ -d /mnt/hdisk/database ] || mkdir -p /mnt/hdisk/database
      [ -d /mnt/hdisk/database/data ] || mkdir -p /mnt/hdisk/database/data
      chown -hR mysql.mysql /mnt/hdisk/database
      chown daemon.daemon /mnt/hdisk/ -R
      chown mysql.mysql /mnt/hdisk/database/data/ -R

      # Add the system startup services
      if ! grep -wq "service mysqld start" /etc/rc.local;then
        echo "service mysqld start Set"  && echo "service mysqld start" >> /etc/rc.local
      fi

      service mysqld start
      /sbin/sysctl -p
  - require_in:
      - pkg: mysql-install
      - cmd: script-exec