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


#--------------------------------------------------------------------------------------------------------------
#Creamos una base de datos de ejemplo
mysql -u root <<< "DROP DATABASE IF EXISTS $DB_NAME"
mysql -u root <<< "CREATE DATABASE $DB_NAME"

#Creamos un usuario para la base de datos de ejemplo
mysql -u root <<< "DROP USER IF EXISTS '$DB_USER'@'%'"
mysql -u root <<< "CREATE USER '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%'"

#---------------------------------------------------------------------------------------------------------------
#Instalamos la herramienta goaccess

apt update
apt install goaccess -y

#Creamos un directorio para los informes estadisticos
mkdir -p /var/www/html/stats

#Ejecutamos GoAccess en background
goaccess /var/log/apache2/access.log -o /var/www/html/stats/index.html --log-format=COMBINED --real-time-html --daemonize

#-------------------------------------------------------------------------------------------------------------------------
# Control de acceso a un directorio con autenticación básica

cp ../conf/000-default.stats.conf /etc/apache2/sites-available

#Deshabilitamos el virtualhost que hay por defecto
a2dissite 000-default.conf

#Habilitamos el nuevo virtualhost 
a2ensite 000-default.stats.conf

#Hacemos un reload del servicio apache
systemctl reload apache2

#Creamos el archivo de contraseñas
sudo htpasswd -bc /etc/apache2/.htpasswd $STATS_USERNAME $STATS_PASSWORD

#-------------------------------------------------------------------------------------------------------------------------

#Control de acceso a un directorio con .htaccess
cp ../conf/000-default-htaccess.conf /etc/apache2/sites-available

#Deshabilitamos el virtualhost 000-default-stats.conf
a2dissite 000-default.stats.conf

#Habilitamos el nuevo virtualhost 000-default-htaccess.conf
a2ensite 000-default-htaccess.conf

#Hacemos un reload del servicio apache
systemctl reload apache2

#Copiamos el archivo .htaccess a /var/www/html/stats
cp ../conf/.htaccess /var/www/html/stats