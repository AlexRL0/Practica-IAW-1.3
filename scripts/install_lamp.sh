#!/bin/bash

#Para mostrar los comandos que se van ejecutando
set -ex

#Actualizamos los repositorios
apt update

#Actualizamos los paquetes
apt upgrade -y

#Instalamos el servidor web Apache
apt install apache2 -y

#Habilitamos el módulo rewrite
a2enmod rewrite

#Copiamos el archivo de configuracion de apache
cp ../conf/000-default.conf /etc/apache2/sites-available

#Instalamos PHP y algunos módulos de PHP para Apache y MYSQL
sudo apt install php libapache2-mod-php php-mysql -y

#Hacemos un restart al servicio de apache para aplicar los cambios
systemctl restart apache2

#Instalamos MYSQL server
sudo apt install mysql-server -y

#Copiamos el archivo de prueba de PHP en /var/www/html
cp ../php/index.php /var/www/html

#Modificamos el propietario y el grupo del archivo index.php
chown -R www-data:www-data /var/www/html