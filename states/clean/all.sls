#remove_cron_jobs:  
#  file.blockreplace:  
#    - name: /etc/crontab  
#    - marker_start: '*/10 * * * * root /mnt/hdisk/scripts/SystemMonitor.sh &'  
#    - marker_end: '* */1 * * * root /mnt/hdisk/scripts/logDelete.sh &'  
#    - content: ''  
#    - backup: True
#    - append_if_not_found: False

include:
  - base.tpsee-tools.erase-pkg
  - states.clean.delete-scripts
  - states.clean.taserverd
  - states.clean.apache
  - states.clean.memcached
  - states.clean.mysql

remove_cron_jobs:
  cmd.run:
    - name: |
        sed -i '/.sh &/d' /etc/crontab;
        if [[ -d /mnt/hdisk ]];then
          cd /mnt
          rm -rf hdisk
        fi  