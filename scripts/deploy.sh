#!/bin/bash

#Importamos el archivo de variables 
source .env

#Para mostrar los comandos que se van ejecutando
set -ex

#Eliminamos clonados previos de la aplicación
rm -rf /tmp/iaw-practica-lamp

#Clonamos el repositorio de la aplicación en /tmp
git clone https://github.com/josejuansanchez/iaw-practica-lamp.git /tmp/iaw-practica-lamp