{% set scripts_path = "/mnt/hdisk/scripts" %}
delete-scripts:
  file.absent:
    - name: {{ scripts_path }}
    - clean: True
