#!/bin/bash

echo "1) Instalar Postfix"
echo "2) Desinstalar Postfix"
read -p "Seleccione una opción: " opcion

if [ "$opcion" -eq 1 ]; then
	sudo apt update && sudo apt install -y postfix mailutils libsasl2-2 ca-certificates libsasl2-modules

	echo "¿Cómo quieres que se llame tu dominio? (ejemplo.com)"
	read -p "Dominio: " dominio

	sudo postconf -e "home_mailbox= Maildir/"
	sudo postconf -e "inet_interfaces = all"
	sudo postconf -e "mydestination = localhost, $dominio"

	sudo systemctl restart postfix

	echo "Postfix instalado y configurado"

elif [ "$opcion" -eq 2 ]; then
    sudo systemctl stop postfix
    sudo apt remove --purge -y postfix mailutils libsasl2-2 ca-certificates libsasl2-modules
    sudo apt autoremove -y
    echo "Postfix desinstalado"
fi
