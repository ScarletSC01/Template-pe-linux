#!/bin/bash
echo "Inicializando VM Linux PE..."
sudo apt-get update -y
sudo apt-get install -y nginx
systemctl enable nginx
systemctl start nginx
echo "✅ VM configurada correctamente con Nginx" > /var/www/html/index.html
