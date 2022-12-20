#!/bin/bash

source components/common.sh

print "Configure YUM Repos"
curl -fsSL https://rpm.nodesource.com/setup_16.x | sudo bash - &>>${LOG_FILE}
StatCheck $?

print "Install NodeJS"
yum install nodejs gcc-c++ -y &>>${LOG_FILE}
StatCheck $?

print "Add Application User"
id ${APP_USER} &>>${LOG_FILE}
if [ $? -ne 0 ]; then
  useradd ${APP_USER} &>>${LOG_FILE}
fi
StatCheck $?

print "Download App Component"
curl -f -s -L -o /tmp/catalogue.zip "https://github.com/roboshop-devops-project/catalogue/archive/main.zip" &>>${LOG_FILE}
StatCheck $?

print "CleanUp OLd Content"
rm -rf /home/${APP_USER}/catalogue &>>${LOG_FILE}
StatCheck $?

print "Extract App Content"
cd /home/${APP_USER} &>>${LOG_FILE} && unzip -o /tmp/catalogue.zip &>>${LOG_FILE} && mv catalogue-main catalogue &>>${LOG_FILE}
StatCheck $?

print "Install App Dependencies"
cd /home/${APP_USER}/catalogue &>>${LOG_FILE} && npm install &>>${LOG_FILE}
StatCheck $?

print "Fix App User Permission"
chown -R ${APP_USER}:${APP_USER} /home/${APP_USER}
StatCheck $?

print "Setup SystemD File"
sed -i -e 's/MONGO_DNSNAME/mongodb.roboshop.internal/' /home/roboshop/catalogue/systemd.service &>>${LOG_FILE} && mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/catalogue.service &>>${LOG_FILE}
StatCheck $?

print "Start Catalogue Service"
systemctl daemon-reload &>>${LOG_FILE} && systemctl restart catalogue &>>${LOG_FILE} && systemctl enable catalogue &>>${LOG_FILE}
StatCheck $?