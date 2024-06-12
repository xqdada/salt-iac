include:
  - states.php.config

httpd-config:
  file.managed:
    - name: /mnt/hdisk/opt/httpd_worker/conf/httpd.conf
    - source: salt://templates/apache/httpd.conf.template
    - user: daemon
    - group: daemon
    - mode: 755

httpd-npm-config:
  file.managed:
    - name: /mnt/hdisk/opt/httpd_worker/conf/extra/httpd-mpm.conf
    - source: salt://templates/apache/httpd-mpm.conf.template
    - user: daemon
    - group: daemon
    - mode: 755

httpd-ssl-config:
  file.managed:
    - name: /mnt/hdisk/opt/httpd_worker/conf/extra/httpd-ssl.conf
    - source: salt://templates/apache/httpd-ssl.conf.template
    - user: daemon
    - group: daemon
    - mode: 755
    - template: jinja

httpd-vhosts-config:
  file.managed:
    - name: /mnt/hdisk/opt/httpd_worker/conf/extra/httpd-vhosts.conf
    - source: salt://templates/apache/httpd-vhosts.conf.template
    - user: daemon
    - group: daemon
    - mode: 755
    - template: jinja
      context:
        SERVER_NAME: {{ salt['pillar.get']('HTTPD_SETTINGS:VHOST_OPTIONS:SERVER_NAME') }}
        SERVER_ALIAS: {{ salt['pillar.get']('HTTPD_SETTINGS:VHOST_OPTIONS:SERVER_ALIAS') }}
        ERROR_LOG: {{ salt['pillar.get']('HTTPD_SETTINGS:VHOST_OPTIONS:ERROR_LOG') }}

httpd-start:
  cmd.run:
  - name: |
      mkdir -p /mnt/hdisk/coredump /mnt/hdisk/http_logs /opt/httpd/logs/
      if [ -d /opt/httpd/htdocs/upload ];then
        rm -rf /opt/httpd/htdocs/upload
      fi

      if [ -f /mnt/hdisk/httpupload ];then
        rm -rf /mnt/hdisk/httpupload
      fi

      mkdir -p /opt/httpd/htdocs/upload /mnt/hdisk/httpupload/
      ln -svnf /mnt/hdisk/httpupload/ /opt/httpd/htdocs/upload
      chmod a+r /opt/httpd/htdocs/
      chmod a+rw /opt/httpd/htdocs/upload
      chmod a+rw /mnt/hdisk/httpupload/
      chown daemon.daemon /opt/httpd/htdocs/ -R
      chmod a+rw /mnt/hdisk/http_logs -R
      mkdir -p /opt/httpd/htdocs/netlogs
      chown daemon.daemon /opt/httpd/ -R
      chkconfig --add httpd
      chkconfig httpd on
      /etc/init.d/httpd -k start
  - require_in:
      - file: httpd-config
      - file: httpd-npm-config
      - file: httpd-ssl-config
      - file: httpd-vhosts-config
  - unless: pgrep httpd