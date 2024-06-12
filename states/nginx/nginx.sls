{% set nginx_version = "1.19.2" %}
make-install:
  - pkg.installed:
    - name: make

nginx-install:
  file.managed:
    - name: /usr/local/src/nginx-{{ nginx_version }}.tar.gz
    - source: salt://states/files/nginx-{{ nginx_version }}.tar.gz
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - name: |
      cd /usr/local/src
      tar zxf nginx-{{ nginx_version }}.tar.gz
      cd nginx-{{ nginx_version }}
      ./configure --prefix=/usr/local/nginx-{{ nginx_version }} --user=www --group=www --with-http_ssl_module --with-stream --with-http_stub_status_module --with-file-aio
      make && make install
      ln -s /usr/local/nginx-{{ nginx_version }} /usr/local/nginx
    - unless: test -d /usr/local/nginx-{{ nginx_version }} && test -L /usr/local/nginx
    - require:
      - file: nginx-install
      - pkg: pkg-init

nginx-init:
  file.managed:
    - name: /usr/lib/systemd/system/nginx.service
    - source: salt://templates/nginx-service.template
    - mode: 755
    - user: root
    - group: root
  cmd.run:
    - name: systemctl daemon-reload
    - require:
      - file: nginx-init

/usr/local/nginx/conf/nginx.conf:
  file.managed:
    - source: salt://templates/nginx.conf.template
    - user: www
    - group: www
    - mode: 644

nginx-service:
  file.directory:
    - name: /usr/local/nginx/conf/online
    - require:
      - cmd: nginx-install
  service.running:
    - name: nginx
    - enable: True
    - reload: True
    - require:
      - cmd: nginx-init
    - watch:
      - file: /usr/local/nginx/conf/nginx.conf
      - file: nginx-service      