#!/bin/bash

echo -e "\e[36m installing Nginx \e[0m"
yum install nginx -y

echo -e "\e[36m Downloading Nginx Content \e[0m"
curl -s -L -o /tmp/frontend.zip "https://github.com/roboshop-devops-project/frontend/archive/main.zip"

echo -e "\e[36m Cleanup old Nginx and extract new downloaded archive \e[0m"
rm -rf /usr/share/nginx/html/*
cd /usr/share/nginx/html/
unzip /tmp/frontend.zip
mv frontend-main/static/* .
mv frontend-main/localhost.conf /etc/nginx/default.d/roboshop.conf

echo -e "\e[36m starting nginx \e[0m"
systemctl enable nginx
systemctl start nginx

