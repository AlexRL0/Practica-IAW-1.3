#!/bin/bash

#Importamos el archivo de variables 
source .env

#Para mostrar los comandos que se van ejecutando
set -ex

#Actualizamos los repositorios
apt update

#Actualizamos los paquetes
apt upgrade -y

#Configuramos las respuestas para la instalación de phpmyadmin
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $PHPMYADMIN_APP_PASSWORD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $PHPMYADMIN_APP_PASSWORD" | debconf-set-selections

#Instalamos phpMyAdmin
sudo apt install phpmyadmin php-mbstring php-zip php-gd php-json php-curl -y

#----------------------------------------------------------------------------
#Instalación de Adminer

#Paso 1. Creamos un directorio para adminer
mkdir -p /var/www/html/adminer

#Paso 2. Instalamos Adminer
wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-mysql.php -P /var/www/html/adminer

#Paso 3. Renombramos el nombre del script de Adminer
mv /var/www/html/adminer/adminer-4.8.1-mysql.php /var/www/html/adminer/index.php

#Paso 4. Modificamos el propietario y el grupo del archivo
chown -R www-data:www-data /var/www/html/adminer

#---------------------------------------------------------------------------------------------------------------
#Instalamos la herramienta goaccess

apt update
apt install goaccess -y

#Creamos un directorio para los informes estadisticos
mkdir -p /var/www/html/stats

#Ejecutamos GoAccess en background
goaccess /var/log/apache2/access.log -o /var/www/html/stats/index.html --log-format=COMBINED --real-time-html --daemonize

#-------------------------------------------------------------------------------------------------------------------------