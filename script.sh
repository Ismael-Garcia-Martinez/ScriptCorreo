#!/bin/bash

echo "Iniciando instalación de Postfix..."
sudo apt update && sudo apt install -y postfix mailutils libsasl2-2 ca-certificates libsasl2-modules

echo "¿Cómo quieres que se llame tu dominio? (ejemplo.com)"
read -p "Dominio: " dominio

sudo postconf -e "home_mailbox= Maildir/"
sudo postconf -e "inet_interfaces = all"
sudo postconf -e "mydestination = localhost, $dominio"

sudo systemctl restart postfix

echo "Postfix instalado y configurado"
