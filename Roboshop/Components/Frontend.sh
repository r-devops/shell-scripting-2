#!/bin/bash

StatCheck() {
if [ $1 -eq 0 ] ; then
  echo -e "\e[32mSUCCESS\e[0m"
else
  echo "\e[31mFAILURE\e[0m"
  exit 2
fi
}

print() {
  echo -e "\n.................$1................" >>$LOG_FILE
  echo -e "\e[36m $1 \e[0m"
}
USER_ID=$(id -u)
if [ "$USER_ID" -ne 0 ]; then
  echo You should run your script as sudo or root user
  exit 1
fi
LOG_FILE=temp/roboshop.log
rm -rf $LOG_FILE

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
StatCheck $?

print "Starting Nginx"
systemctl restart nginx &>>$LOG_FILE && systemctl enable nginx &>>$LOG_FILE
StatCheck $?
