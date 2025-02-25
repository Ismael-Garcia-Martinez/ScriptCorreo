#!/bin/bash
if command -v ansible &> /dev/null
then
    echo "Ansible ya esta instalado en tu ordenador"
        exit 0
fi
sudo apt update && sudo apt install -y ansible

if command -v ansible &> /dev/null
then
    echo "Ansible se ha instalado correctamente."
else
    echo "Error: La instalación de Ansible ha fallado."
    exit 1
fi

ansible --version

echo "Configuración completada."
