include:
  - states.node-exporter.install

init-all:
  cmd.script:
    - source: salt://states/files/common/init_sys.sh