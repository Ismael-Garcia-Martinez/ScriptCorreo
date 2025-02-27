#!/bin/bash

mostrar_menu() {
    clear
    echo "===================================="
    echo "          MENÚ PRINCIPAL            "
    echo "===================================="
    echo "1. Ejecutar Script de Docker"
    echo "2. Ejecutar Script de Comandos Bash"
    echo "3. Menú de Ansible"
    echo "4. Salir"
    echo "===================================="
}

mostrar_submenu_ansible() {
    clear
    echo "===================================="
    echo "          SUBMENÚ DE ANSIBLE         "
    echo "===================================="
    echo "1. Instalar Ansible"
    echo "2. Desinstalar Ansible"
    echo "3. Instalar Servicio de Correo (Postfix)"
    echo "4. Volver al Menú Principal"
    echo "===================================="
}

ejecutar_docker() {
    echo "Ejecutando Script de Docker..."
    /ruta/al/script_docker.sh
}

ejecutar_bash() {
    echo "Ejecutando Script de Comandos Bash..."
    /ruta/al/script_bash.sh
}

instalar_ansible() {
    echo "Instalando Ansible..."
    sudo apt update
    sudo apt install -y ansible
    echo "Ansible ha sido instalado correctamente."
}

desinstalar_ansible() {
    echo "Desinstalando Ansible..."
    sudo apt remove -y ansible
    sudo apt autoremove -y
    echo "Ansible ha sido desinstalado correctamente."
}

instalar_servicio_correo() {
    echo "Instalando Servicio de Correo (Postfix)..."
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
    
}

while true; do
    mostrar_menu
    read -p "Selecciona una opción (1-4): " opcion

    case $opcion in
        1)
            ejecutar_docker
            ;;
        2)
            ejecutar_bash
            ;;
        3)
            while true; do
                mostrar_submenu_ansible
                read -p "Selecciona una opción (1-4): " opcion_ansible

                case $opcion_ansible in
                    1)
                        instalar_ansible
                        ;;
                    2)
                        desinstalar_ansible
                        ;;
                    3)
                        instalar_servicio_correo
                        ;;
                    4)
                        echo "Volviendo al Menú Principal..."
                        break
                        ;;
                    *)
                        echo "Opción no válida. Por favor, selecciona una opción del 1 al 4."
                        ;;
                esac

                read -p "Presiona Enter para continuar..."
            done
            ;;
        4)
            echo "Saliendo del menú..."
            break
            ;;
        *)
            echo "Opción no válida. Por favor, selecciona una opción del 1 al 4."
            ;;
    esac

    read -p "Presiona Enter para continuar..."
done
