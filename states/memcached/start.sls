startup-script-config:
  file.managed:
    - name: /etc/init.d/memcached
    - source: salt://states/files/app/memcached
    - user: root
    - group: root
    - mode: 755

memcached-start:
  cmd.run:
  - name: |
      chkconfig --add memcached 
      chkconfig memcached on
      /etc/init.d/memcached start
  - require:
      - file: startup-script-config  