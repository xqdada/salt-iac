{% set TARGE_PACKAGE = "web_setuppack_init.zip" %}

unzip_file:
  file.managed:
    - name: {{ pillar['TMP_DIR'] }}/{{ TARGE_PACKAGE }}
    - source: salt://states/files/{{ TARGE_PACKAGE }}
    - user: root
    - group: root
    - unless: test -f {{ pillar['TMP_DIR'] }}/{{ TARGE_PACKAGE }}
  cmd.run:
    - name: |
       echo " Extracting {{ TARGE_PACKAGE }} into /"
       if /usr/bin/unzip -o {{ pillar['TMP_DIR'] }}/{{ TARGE_PACKAGE }} -d /;then
         echo "==== echo "Archive has been successfully" " 
         #rm -f {{ pillar['UNZIPDIR'] }}/{{ TARGE_PACKAGE }}
       fi
    - unless: test -d {{ pillar['SERVICE_INSTALL_DIR'] }}