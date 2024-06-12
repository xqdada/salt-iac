{% set hostnames = pillar.get('hostnames',[]) %}
{% for hostname in hostnames %}
set-{{ hostname }}:
  host.present:
    - ip: {{ salt['pillar.get']('ip_addr') }}
    - names:
      #- {{ grains['fqdn'] }}
      - {{ hostname }}
    - comment: 访问云平台服务地址  
{% endfor %}