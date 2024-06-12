{% for certname in ['ca-bundle-client.crt','star_seetong_com.crt','star_seetong_com.key'] %}

{{ loop.index }}-{{ certname.split('.')[0] }}:
  file.managed:
    - name: /opt/httpd/conf/{{ certname }}
    - source: salt://states/files/ssl/{{ certname }}
    - user: daemon
    - group: daemon
    - mode: 755

{% endfor %}