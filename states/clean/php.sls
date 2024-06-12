stop_php_processes:  
  cmd.run:  
    - name: pkill -f php-cgi 
    - onlyif: pgrep -f php-cgi

php-dir-remove:
  file.directory:
    - name: /mnt/hdisk/opt/php
    - clean: True 
    - require:
      - cmd: stop_php_processes    