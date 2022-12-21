#!/bin/bash

source components/common.sh

print "Installing Nginx"
yum install nginx -y &>>$LOG_FILE
StatCheck $?

print "Downloading Nginx Content"
curl -f -s -L -o /tmp/frontend.zip "https://github.com/roboshop-devops-project/frontend/archive/main.zip" &>>$LOG_FILE
StatCheck $?

print "Cleanup old Nginx content"
rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
StatCheck $?

cd /usr/share/nginx/html/

print "Extract new downloaded archive"
unzip /tmp/frontend.zip &>>$LOG_FILE && mv frontend-main/* . &>>$LOG_FILE && mv static/* . &>>$LOG_FILE
StatCheck $?

print "Updating RoboShop Configuration"
mv localhost.conf /etc/nginx/default.d/roboshop.conf &>>$LOG_FILE
sed -i -e '/catalogue/s/localhost/catalogue.roboshop.internal/' -e '/user/s/localhost/user.roboshop.internal/' -e '/cart/s/localhost/cart.roboshop.internal/' /etc/nginx/default.d/roboshop.conf
StatCheck $?

print "Starting Nginx"
systemctl restart nginx &>>$LOG_FILE && systemctl enable nginx &>>$LOG_FILE
StatCheck $?
