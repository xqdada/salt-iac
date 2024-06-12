include:
  - base.tpsee-tools.require

{% if 'mysql' in salt['pillar.get']('install_services') %}
include:
  - states.mysql.install
{% endif %}

{% if 'apache'in salt['pillar.get']('install_services') %}
include:
  - states.apache.start
{% endif %}

{% if 'memcached' in salt['pillar.get']('install_services') %}
include:
  - states.memcached.start
{% endif %}

{% if 'mysql' in salt['pillar.get']('install_services') %}
include:
  - states.mysql.install
{% endif %}

{% if 'taserverd' in salt['pillar.get']('install_services') %}
include:
  - states.taserverd.start
{% endif %}

{% if 'apache' in salt['pillar.get']('install_services')  and 'mysql' in salt['pillar.get']('install_services') %}
include:
  - states.apache.start
  - states.mysql.install
{% endif %}

{% if 'apache' in salt['pillar.get']('install_services')  and 'mysql' in salt['pillar.get']('install_services')  and 'taserverd' in salt['pillar.get']('install_services') %}
include:
  - states.apache.start
  - states.mysql.install
  - states.taserverd.start
{% endif %}