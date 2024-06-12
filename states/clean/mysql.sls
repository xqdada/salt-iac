mysql-dead:
  service.dead:
    - name: mysqld

mysql-disabled:    
  service.disabled:
    - name: mysqld  

pkg-purge:
  pkg.purged:
  - pkgs:
    - mysql-community-common-5.7.32-1.el7.x86_64
    - mysql-community-server-5.7.32-1.el7.x86_64
    - mysql-community-libs-5.7.32-1.el7.x86_64
    - mysql-community-libs-compat-5.7.32-1.el7.x86_64
    - mysql-community-client-5.7.32-1.el7.x86_64
  - onlyif: rpm -qa|grep -Eq "^mysql-community"  
  
{% for dir in ['/mnt/hdisk/coredump','/mnt/hdisk/database','/etc/my.cnf.d'] %}
{{ dir|replace('/','_') }}:
  file.absent:
    - name: {{ dir }}
    - clean: True
{% endfor %}

{% set mysql_files = ['/usr/lib/systemd/system/mysqld.service','/etc/my.cnf']  %}
{% for file in mysql_files %}
{{ file|replace('/','_') }}:
  file.absent:
  - name: {{ file }}
{% endfor %}

delete_mysqld_content_in_rc_local:
  file.replace:  
    - name: /etc/rc.local  
    - pattern: 'service mysqld start'  
    - repl: ''  
    - backup: True