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
