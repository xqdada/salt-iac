node-exporter-install:
  file.managed:
    - source: salt://states/files/node_exporter-1.4.0.linux-amd64.tar.gz
/usr/lib/systemd/system/node_exporter.service:
  file.managed:
    - source: salt://templates/node_exporter.service.template   
shell_script:
  cmd.script: 
    - source: salt://states/files/common/install_node-exporter.sh
    - user: root
    - shell: /bin/bash
    
#seetong-ops ssh-key
sudo-add:
  cmd.script:
    - source: salt://states/files/common/sudoers.sh
    - shell: /bin/bash
    - user: root
sshkey-cp:
  file.managed:
    - source: salt://states/files/authorized_keys
    - user: seetong-ops
    - mode: 600   

 #进程监控   
mionitor:
  file.managed:
    - source: salt://states/files/common/count_process.sh
bash /usr/local/node_exporter/count_process.sh >/dev/null 2>&1:
  cron.present:
    - user: root
