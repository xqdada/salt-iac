
backup-files:
  cmd.run:
    - name: |
        [ -d {{ pillar['BAKDIR'] }} ] || mkdir -p {{ pillar['BAKDIR'] }}
        cp -rf /bin/curl {{ pillar['BAKDIR'] }}
        cp -rf /lib64/libcurl.so.4.7.0 {{ pillar['BAKDIR'] }}
        [ -f /etc/my.cnf ]||cp -rf /etc/my.cnf {{ pillar['BAKDIR'] }}
        grep -wq "/usr/local/lib/" /etc/ld.so.conf && echo "/usr/local/lib/ Set"  || echo "/usr/local/lib/" >> /etc/ld.so.conf && ldconfig 
