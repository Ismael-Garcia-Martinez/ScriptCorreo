#!/bin/bash

Directorio="playbook_correo"
archivo="$Directorio/instalacion.yml"
configuracion="$Directorio/configuracion"
principal="$configuracion/principal.cf.j2"
inventario="$Directorio/inventory.ini"

mkdir -p "$configuracion"

cat > "$archivo" <<EOL
---
- name: Instalar y configurar Postfix para correos locales
  hosts: local
  connection: local
  become: true
  vars:
    myhostname: "localhost"
    mydomain: "local"
    usuario_destino: "pepe@localhost"  

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

    - name: Configurar Postfix para correos locales
      template:
        src: configuracion/principal.cf.j2
        dest: /etc/postfix/main.cf
      notify: Reiniciar Postfix

    - name: Asegurar que Postfix está habilitado y activo
      systemd:
        name: postfix
        enabled: yes
        state: started

    - name: Enviar correo de prueba a otro usuario local
      command: >
        echo "Este es un correo de prueba" |
        mail -s "Prueba de correo local" {{ usuario_destino }}

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
relayhost =
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

echo "Sincronizando la hora del sistema..."
sudo timedatectl set-ntp true
sudo systemctl restart systemd-timesyncd

echo "Verificando la hora del sistema..."
timedatectl status

echo "Instalando ntpdate para sincronización manual de la hora..."
sudo apt install -y ntpdate
sudo ntpdate pool.ntp.org

echo "Actualizando la caché de APT..."
sudo apt update

echo "Resolviendo el problema de la clave de APT obsoleta..."
if sudo apt-key list | grep -q "docker"; then
    echo "Migrando la clave de Docker al nuevo formato..."
    KEY_ID=$(sudo apt-key list | grep -B 1 "docker" | head -n 1 | awk '{print $2}')
    sudo apt-key export "$KEY_ID" | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg
    sudo apt-key del "$KEY_ID"
    echo "Clave de Docker migrada correctamente."
else
    echo "No se encontró la clave de Docker en el formato antiguo."
fi

echo "Playbook de instalación de Postfix generado en '$Directorio'."
echo "Ejecuta el playbook con el siguiente comando:"
echo "ansible-playbook -i $inventario $archivo"
echo "Para enviar un correo usa lo siguiente: "
echo "'Este es un correo de prueba' | mail -s 'Prueba de correo local' pepe@localhost"
echo "Haz un cat de /var/mail/<usuario>"
