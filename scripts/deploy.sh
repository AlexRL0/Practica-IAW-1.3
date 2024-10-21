#!/bin/bash

#Importamos el archivo de variables 
source .env

#Para mostrar los comandos que se van ejecutando
set -ex

#Eliminamos clonados previos de la aplicación
rm -rf /tmp/iaw-practica-lamp

#Clonamos el repositorio de la aplicación en /tmp
git clone https://github.com/josejuansanchez/iaw-practica-lamp.git /tmp/iaw-practica-lamp

#Movemos el código fuente de la aplicación a /var/www/html
mv /tmp/iaw-practica-lamp/src/* /var/www/html

#Configuramos el archivo config.php
sed -i "s/database_name_here/$DB_NAME/" /var/www/html/config.php
sed -i "s/username_here/$DB_USER/" /var/www/html/config.php
sed -i "s/password_here/$DB_PASSWORD/" /var/www/html/config.php