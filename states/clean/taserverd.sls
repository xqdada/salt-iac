taserverd-stop:
  cmd.run:
    - name: |
        /etc/init.d/TAServerd stop
        chkconfig --del TAServerd
        rm -f /etc/init.d/TAServerd

{% set taservice_dirs = ['/mnt/hdisk/opt/TAService','/mnt/hdisk/alarm_logs'] %}
{% for dir in taservice_dirs %}
{{ dir }}:
  file.absent:
    - name: {{ dir }}
      clean: True
{% endfor %}