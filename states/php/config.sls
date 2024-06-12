{% set HTTPD_CONFIG_BAK = "/opt/httpd/bak/" %}

httpd-bak-dir:
  file.managed:
    - name: {{ HTTPD_CONFIG_BAK }}
    - user: daemon
    - group: daemon
    - mode: 755
    - makedirs: True
    - unless: test -d {{ HTTPD_CONFIG_BAK }}

php-db-config:
  file.managed:
    - name: {{ HTTPD_CONFIG_BAK }}/dbconfig.php
    - source: salt://templates/php/dbconfig.php.template
    - user: daemon
    - group: daemon
    - mode: 755
    - template: jinja

{% set http_server_id = salt['pillar.get']('HTTP_SERVER_ID') %}
{% set http_server_type = salt['pillar.get']('HTTP_SERVER_TYPE', 'APP') %} 
{% set http_server_area = salt['pillar.get']('HTTP_SERVER_AREA', 'CN') %} 
php-webid-config:
  file.managed:
    - name: {{ HTTPD_CONFIG_BAK }}/webid.php
    - source: salt://templates/php/webid.php.template
    - user: daemon
    - group: daemon
    - mode: 755
    - template: jinja
    - context:
        http_server_id: {{ http_server_id }}
        http_server_type: {{ http_server_type }}
        http_server_area: {{ http_server_area }} 

copy_php_config_into_commdir:
  cmd.run.:
    - name: if [ -d /opt/httpd/htdocs/comm ];then \cp -f {{ HTTPD_CONFIG_BAK }}/* /opt/httpd/htdocs/comm/;fi
    - require:
      - file: php-db-config
      - file: php-webid-config