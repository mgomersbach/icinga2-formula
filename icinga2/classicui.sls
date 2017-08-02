{# keep backwards compatibility #}
{% set classicui = salt['pillar.get']('icinga2:classicui', salt['pillar.get']('icinga2:lookup::classicui', {}))%}

{% if grains['os_family'] in ['Debian']  %}

include:
  - icinga2
  - .repositories

icinga2-classicui:
  pkg.installed:
    - require:
      - pkgrepo: icinga_repo
{% if grains['osrelease'] < 8 %}
      - file: /etc/apache2/mods-enabled/version.load
{% endif %}

/etc/icinga2-classicui/htpasswd.users:
  file.managed:
    - user: root
    - group: www-data
    - mode: 0640
    - require:
      - pkg: icinga2-classicui
    - contents: |
{%- for user, password_hash in classicui.users.items() %}
        {{ user }}:{{ password_hash }}
{%- endfor %}

/etc/icinga2-classicui/cgi.cfg:
  file.managed:
    - source: salt://icinga2/files/classicui.cgi.cfg.tpl
    - template: jinja
    - makedirs: True

{% endif %}

{% if grains['os_family'] not in ['Debian'] or grains['osrelease'] < 8 %}

/etc/apache2/mods-enabled/version.load:
  file.symlink:
    - target: /etc/apache2/mods-available/version.load
    - require:
      - pkg: apache2

apache2:
  pkg.installed: []
  service.running:
    - watch:
      - file: /etc/apache2/mods-enabled/version.load
    - require:
      - pkg: apache2

{% endif %}
