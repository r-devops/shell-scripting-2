#!/bin/bash

StatCheck() {
if [ $1 -eq 0 ] ; then
  echo -e "\e[32mSUCCESS\e[0m"
else
  echo "\e[31mFAILURE\e[0m"
  exit 2
fi
}

USER_ID=$(id -u)
if [ "$USER_ID" -ne 0 ]; then
  echo You should run your script as sudo or root user
  exit 1
fi


echo -e "\e[36m Installing Nginx \e[0m"
yum install nginx -y
StatCheck $?

echo -e "\e[36m Downloading Nginx Content \e[0m"
curl -s -L -o /tmp/frontend.zip "https://github.com/roboshop-devops-project/frontend/archive/main.zip"
StatCheck $?

echo -e "\e[36m Cleanup old Nginx content and Extract new downloaded archive \e[0m"
rm -rf /usr/share/nginx/html
cd /usr/share/nginx/html
unzip /tmp/frontend.zip
mv frontend-main/* .
mv static/* .
rm -rf frontend-main README.md
mv localhost.conf /etc/nginx/default.d/roboshop.conf
StatCheck $?

echo -e "\e[36m Starting Nginx \e[0m"
systemctl restart nginx
StatCheck $?
systemctl enable nginx