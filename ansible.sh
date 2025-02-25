#!/bin/bash

Directorio="playbook_correo"
archivo="$Directorio/instalacion.yml"
configuracion="$Directorio/configuracion"
principal="$configuracion/principal.cf.j2"
inventario="$Directorio/inventory.ini"

if mkdir -p "$configuracion"; then
    echo "Directorio '$Directorio' creado correctamente."
else
    echo "Error: No se pudo crear el directorio '$Directorio'."
    exit 1
fi

cat > "$archivo" <<EOL
---
- name: Instalar y configurar Postfix como proxy SMTP
  hosts: localhost  # Cambiado a localhost
  connection: local  # Conexión local
  become: true
  vars:
    postfix_relayhost: "[127.0.0.1]:25"
  
  tasks:
    - name: Instalar Postfix y mailutils
      apt:
        name:
          - postfix
          - mailutils
        state: present
        update_cache: yes

    - name: Configurar Postfix en modo proxy
      template:
        src: configuracion/principal.cf.j2
        dest: /etc/postfix/main.cf
      notify: Reiniciar Postfix

    - name: Asegurar que Postfix está habilitado y activo
      systemd:
        name: postfix
        enabled: yes
        state: started

  handlers:
    - name: Reiniciar Postfix
      service:
        name: postfix
        state: restarted
EOL

if [ -f "$archivo" ]; then
    echo "Playbook creado correctamente en '$archivo'."
else
    echo "Error: No se pudo crear el playbook."
    exit 1
fi

cat > "$principal" <<EOL
relayhost = [127.0.0.1]:25
mynetworks = 127.0.0.0/8
smtpd_relay_restrictions = permit_mynetworks reject_unauth_destination
smtp_use_tls=no
smtp_sasl_auth_enable=no
EOL

if [ -f "$principal" ]; then
    echo "Plantilla de configuración creada en '$principal'."
else
    echo "Error: No se pudo crear la plantilla de configuración."
    exit 1
fi

cat > "$inventario" <<EOL
[localhost]
localhost ansible_connection=local  # Configuración para ejecutar en local
EOL

if [ -f "$inventario" ]; then
    echo "Inventario creado en '$inventario'."
else
    echo "Error: No se pudo crear el archivo de inventario."
    exit 1
fi

echo "Playbook de instalación de Postfix generado en '$Directorio'."
