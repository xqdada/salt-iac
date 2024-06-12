memcached-stop:
  cmd.run:
    - name: |
        /etc/init.d/memcached stop
        chkconfig --del memcached
    - onlyif: test -f /etc/init.d/memcached    

file-remove:    
  file.absent:
    - name: /etc/init.d/memcached
      require:
        - cmd: memcached-stop

dir-remove:       
  file.absent:
    - name: /mnt/hdisk/opt/memcache
    - clean: True
    - require:
      - cmd: memcached-stop  
 

