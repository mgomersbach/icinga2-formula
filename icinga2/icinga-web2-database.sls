{% from "icinga2/map.jinja" import icinga2 with context %}

is-icinga2web-password-set:
  test.check_pillar:
    - present:
      - 'icinga2:lookup:icinga_web2:db:password'
    - string:
      - 'icinga2:lookup:icinga_web2:db:password'

#Create an empty database which will be populated later
icinga2web-db-setup:
  postgres_user.present:
    - name: "{{ icinga2.icinga_web2.db.user }}"
    - password: "{{ icinga2.icinga_web2.db.password }}"
    - createdb: True
    - createroles: True
    - createuser: True
    - inherit: True
    - login: True
    # Necessary as of PostgreSQL 10
    - encrypted: True
    - require:
      - test: is-icinga2web-password-set
      - pkg: icinga2-web2
  postgres_database.present:
    - name: "{{ icinga2.icinga_web2.db.name }}"
    - encoding: UTF8
    - template: template0
    - owner: "{{ icinga2.icinga_web2.db.user }}"
    - require:
      - test: is-icinga2web-password-set
      - postgres_user: icinga2web-db-setup
