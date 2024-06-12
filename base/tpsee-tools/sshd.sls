sshd-restart:
  service.running: 
    - name: sshd
    - enable: True  
    - reload: True  
    #- watch:
    #  - file: /etc/ssh/sshd_config