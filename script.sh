#!/bin/bash

echo "1) Instalar Postfix"
echo "2) Desinstalar Postfix"
echo "3) Instalar SquirrelMail (Ampliacion)"
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

elif [ "$opcion" -eq 3 ]; then
    sudo apt update && sudo apt install -y squirrelmail apache2 php libapache2-mod-php
    echo "SquirrelMail instalado"

    echo "Introduce el nombre de dominio para el servidor web (ejemplo: correo.ejemplo.com)"
    read -p "Dominio: " dominio_web

    sudo ln -s /usr/share/squirrelmail /var/www/html/squirrelmail

    echo "<VirtualHost *:80>
        ServerName $dominio_web
        DocumentRoot /usr/share/squirrelmail
        <Directory /usr/share/squirrelmail>
            Options FollowSymLinks
            AllowOverride All
            Require all granted
        </Directory>
    </VirtualHost>" | sudo tee /etc/apache2/sites-available/squirrelmail.conf

    sudo a2ensite squirrelmail.conf
    sudo systemctl reload apache2

    echo "127.0.0.1 $dominio_web" | sudo tee -a /etc/hosts

    echo "SquirrelMail configurado. Accede en: http://$dominio_web/squirrelmail"
fi
