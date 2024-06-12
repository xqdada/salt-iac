{% for pkg in ['redhat-lsb-core', 'redhat-lsb-submod-security', 'postfix', 'mariadb-libs', 'mysql-community-devel', 'mysql-community-server', 'mysql-community-libs-compat', 'mysql-community-client', 'mysql-community-libs', 'mysql-community-common'] %}  
erase_{{ pkg }}:  
  pkg.purged:  
    - names:  
      - {{ pkg }}  
    - unless: rpm -qa | grep -q {{ pkg }}  
{% endfor %}