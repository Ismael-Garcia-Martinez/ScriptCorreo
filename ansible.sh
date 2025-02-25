#!/bin/bash

Directorio="playbook_correo"
archivo="$Directorio/intalacion.yml"
configuracion="$Directorio/configuracion"
principal="$configuracion/principal.cf.j2"
inventario="$Directorio/inventory.ini"

if mkdir -p "$TEMPLATE_DIR"; then
    echo "Directorio '$Directorio' creado correctamente."
else
    echo "Error: No se pudo crear el directorio '$Director>
    exit 1
fi
mkdir -p $configuracion
cat > "$archivo" <<EOL
---
- name: Instalar y configurar Postfix
  hosts: servidores_correo
  become: true
  vars:
    postfix_relayhost: "[relay.example.com]:587"
  
  tasks:
    - name: Instalar Postfix
      apt:
        name: postfix
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
relayhost = {{ postfix_relayhost }}
smtpd_relay_restrictions = permit_mynetworks permit>
inet_interfaces = all
proxy_interfaces = 0.0.0.0
EOL

if [ -f "$principal" ]; then
    echo "Plantilla de configuración creada en '$pr>
else
    echo "Error: No se pudo crear la plantilla de c>
    exit 1
fi

cat > "$inventario" <<EOL
[servidores_correo]
mi-servidor ansible_host=192.168.1.10 ansible_user=>
EOL

if [ -f "$inventario" ]; then
    echo "Inventario creado en '$inventario'."
else
    echo "Error: No se pudo crear el archivo de inv>
    exit 1
fi

echo "Playbook de instalación añadido en '$Directorio'."


 


