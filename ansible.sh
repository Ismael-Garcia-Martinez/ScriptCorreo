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
 


