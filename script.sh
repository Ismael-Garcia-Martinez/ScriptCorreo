#!/bin/bash

echo "1) Datos de red de tu equipo"
echo "2) Estado del servicio"
echo "3) Instalar Postfix"
echo "4) Desinstalar Postfix"
echo "5) Instalar SquirrelMail"
echo "6) Desinstalar SquirrelMail"
echo "7) Ayuda"
echo "8) Iniciar Postfix"
echo "9) Detener Postfix"
read -p "Seleccione una opción: " opcion

if [ "$opcion" -eq 1 ]; then
    ip a
    echo "Datos de red mostrados"

elif [ "$opcion" -eq 2 ]; then
    systemctl status postfix
    echo "Estado del servicio mostrado"

elif [ "$opcion" -eq 3 ]; then
	sudo apt update && sudo apt install -y postfix mailutils libsasl2-2 ca-certificates libsasl2-modules

	echo "¿Cómo quieres que se llame tu dominio? (ejemplo.com)"
	read -p "Dominio: " dominio

	sudo postconf -e "home_mailbox= Maildir/"
	sudo postconf -e "inet_interfaces = all"
	sudo postconf -e "mydestination = localhost, $dominio"

	sudo systemctl restart postfix

	echo "Postfix instalado y configurado"

elif [ "$opcion" -eq 4 ]; then
    sudo systemctl stop postfix
    sudo apt remove --purge -y postfix mailutils libsasl2-2 ca-certificates libsasl2-modules
    sudo apt autoremove -y
    echo "Postfix desinstalado"

elif [ "$opcion" -eq 5 ]; then
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

elif [ "$opcion" -eq 6 ]; then
    sudo systemctl stop apache2
    sudo apt remove --purge -y squirrelmail apache2 php libapache2-mod-php
    sudo rm -rf /etc/apache2/sites-available/squirrelmail.conf
    sudo rm -rf /var/www/html/squirrelmail
    sudo systemctl reload apache2
    echo "SquirrelMail desinstalado"

elif [ "$opcion" -eq 7 ]; then
    echo "Ayuda del script:"
    echo "1) Datos de red de tu equipo: Muestra la configuración de red."
    echo "2) Estado del servicio: Muestra el estado actual del servicio Postfix."
    echo "3) Instalar Postfix: Instala y configura el servicio de correo Postfix."
    echo "4) Desinstalar Postfix: Elimina completamente Postfix."
    echo "5) Instalar SquirrelMail: Instala el cliente web de correo SquirrelMail."
    echo "6) Desinstalar SquirrelMail: Elimina completamente SquirrelMail."
    echo "7) Ayuda: Muestra esta explicación detallada sobre cada opción del script."
    echo "8) Iniciar Postfix: Activa el servicio de Postfix."
    echo "9) Detener Postfix: Detiene el servicio de Postfix."

elif [ "$opcion" -eq 8 ]; then
    sudo systemctl start postfix
    echo "Postfix iniciado"

elif [ "$opcion" -eq 9 ]; then
    sudo systemctl stop postfix
    echo "Postfix detenido"
fi
