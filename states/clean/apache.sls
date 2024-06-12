stop-httpd:
  cmd.run:
  - name: |
      chkconfig --del httpd
      /etc/init.d/httpd stop

{% for dir_name, dir_path in pillar.get('HTTPD_DIRS', {}).items() %}
{{ dir_name|lower }}:
  file.absent:
    - name: {{ dir_path }}
      clean: true
{% endfor %}
