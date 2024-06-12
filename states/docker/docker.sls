docker-install:
  file.managed:
    - name: /etc/yum.repos.d/docker-ce.repo
    - source: salt://templates/docker/docker-ce.repo.template
    - user: root
    - group: root
    - mode: 644
  pkg.installed:
    - name: docker-ce

docker-config-dir:
  file.directory:
    - name: /etc/docker
    
docker-daemon-config:
  file.managed:
    - name: /etc/docker/daemon.json
    - source: salt://templates/docker/daemon.json.template
    - user: root
    - group: root
    - mode: 644

docker-service:
  file.managed:
    - name: /etc/systemd/system/docker.service
    - source: salt://templates/docker/docker.service.template
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: systemctl daemon-reload
  service.running:
    - name: docker
    - enable: True
    - watch:
      - file: docker-config
      - file: docker-daemon-config
