#!/bin/bash

Directorio="playbook_correo"
archivo="$Directorio/instalacion.yml"
configuracion="$Directorio/configuracion"
principal="$configuracion/principal.cf.j2"
inventario="$Directorio/inventory.ini"

mkdir -p "$configuracion"

cat > "$archivo" <<EOL
---
- name: Instalar y configurar Postfix como proxy SMTP
  hosts: local
  connection: local
  become: true
  vars:
    postfix_relayhost: "[127.0.0.1]:25"
    myhostname: "localhost"
    mydomain: "local"
    email_destino: "ismael@localhost"

  tasks:
    - name: Detener y deshabilitar el servicio Postfix (si existe)
      systemd:
        name: postfix
        state: stopped
        enabled: no
      ignore_errors: yes

    - name: Eliminar Postfix y archivos de configuración
      apt:
        name: postfix
        state: absent
        purge: yes
        autoremove: yes

    - name: Eliminar archivos residuales de Postfix
      file:
        path: "{{ item }}"
        state: absent
      loop:
        - /etc/postfix
        - /var/lib/postfix
        - /var/log/mail.log
      ignore_errors: yes

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

    - name: Enviar correo de prueba
      command: >
        echo "Este es un correo de prueba" |
        mail -s "Prueba de Postfix" {{ email_destino }}

    - name: Verificar que Postfix está escuchando en el puerto 25
      wait_for:
        port: 25
        timeout: 10

  handlers:
    - name: Reiniciar Postfix
      service:
        name: postfix
        state: restarted
EOL

cat > "$principal" <<EOL
myhostname = {{ myhostname }}
mydomain = {{ mydomain }}
myorigin = \$mydomain
inet_interfaces = all
mydestination = \$myhostname, localhost.\$mydomain, \$mydomain
relayhost = {{ postfix_relayhost }}
mynetworks = 127.0.0.0/8
smtpd_relay_restrictions = permit_mynetworks reject_unauth_destination
smtp_use_tls = no
smtp_sasl_auth_enable = no
EOL

cat > "$inventario" <<EOL
[local]
localhost ansible_connection=local
EOL

echo "Configurando sudo sin contraseña para el usuario actual..."
if sudo grep -q "$USER ALL=(ALL) NOPASSWD: ALL" /etc/sudoers; then
    echo "El usuario $USER ya tiene permisos de sudo sin contraseña."
else
    echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers > /dev/null
    echo "Permisos de sudo sin contraseña agregados para $USER."
fi

echo "Playbook de instalación de Postfix generado en '$Directorio'."
echo "Ejecuta el playbook con el siguiente comando:"
echo "ansible-playbook -i $inventario $archivo"
