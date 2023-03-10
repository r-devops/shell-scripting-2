#!/bin/bash

StatCheck() {
if [ $1 -eq 0 ] ; then
  echo -e "\e[32mSUCCESS\e[0m"
else
  echo -e "\e[31mFAILURE\e[0m"
  exit 2
fi
}

print() {
  echo -e "\n.................$1................" &>>$LOG_FILE
  echo -e "\e[36m $1 \e[0m"
}
USER_ID=$(id -u)
if [ "$USER_ID" -ne 0 ]; then
  echo You should run your script as sudo or root user
  exit 1
fi
LOG_FILE=/tmp/roboshop.log
rm -rf $LOG_FILE

APP_USER=roboshop

APP_SETUP(){
  print "Add Application User"
    id ${APP_USER} &>>${LOG_FILE}
    if [ $? -ne 0 ]; then
      useradd ${APP_USER} &>>${LOG_FILE}
      StatCheck $?
    fi


  print "Download App Component"
    curl -f -s -L -o /tmp/${COMPONENT}.zip "https://github.com/roboshop-devops-project/${COMPONENT}/archive/main.zip" &>>${LOG_FILE}
    StatCheck $?

    print "CleanUp OLd Content"
    rm -rf /home/${APP_USER}/${COMPONENT} &>>${LOG_FILE}
    StatCheck $?

    print "Extract App Content"
    cd /home/${APP_USER} &>>${LOG_FILE} && unzip -o /tmp/${COMPONENT}.zip &>>${LOG_FILE} && mv ${COMPONENT}-main ${COMPONENT} &>>${LOG_FILE}
    StatCheck $?
}

SERVICE_SETUP() {

  print "Fix App User Permission"
  chown -R ${APP_USER}:${APP_USER} /home/${APP_USER}
  StatCheck $?

  print "Setup SystemD File"
  sed -i -e 's/MONGO_DNSNAME/mongodb.roboshop.internal/' \
  -e 's/REDIS_ENDPOINT/redis.roboshop.internal/' \
  -e 's/MONGO_ENDPOINT/mongodb.roboshop.internal/' \
  -e 's/CATALOGUE_ENDPOINT/catalogue.roboshop.internal/' \
  -e 's/CARTENDPOINT/cart.roboshop.interval/' \
  -e 's/DBHOST/mysql.roboshop.internal/' \
  -e 's/CARTHOST/cart.roboshop.internal/' \
  -e 's/USERHOST/user.roboshop.internal/' \
  -e "s/AMQPHOST/rabbitmq.roboshop.internal/" \
  /home/roboshop/${COMPONENT}/systemd.service &>>${LOG_FILE} &&
  mv /home/roboshop/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service &>>${LOG_FILE}
  StatCheck $?

  print "Restart ${COMPONENT} Service"
  systemctl daemon-reload &>>${LOG_FILE} && systemctl restart ${COMPONENT} &>>${LOG_FILE} && systemctl enable ${COMPONENT} &>>${LOG_FILE}
  StatCheck $?
}

NODEJS() {


  print "Configure YUM Repos"
  curl -fsSL https://rpm.nodesource.com/setup_16.x | sudo bash - &>>${LOG_FILE}
  StatCheck $?

  print "Install NodeJS"
  yum install nodejs gcc-c++ -y &>>${LOG_FILE}
  StatCheck $?

  APP_SETUP

  StatCheck $?

  print "Install App Dependencies"
  cd /home/${APP_USER}/${COMPONENT} &>>${LOG_FILE} && npm install &>>${LOG_FILE}
  StatCheck $?

  SERVICE_SETUP
}

MAVEN()
{
  print "Install Maven"
  yum install maven -y &>>${LOG_FILE}
  StatCheck $?

  APP_SETUP

  print "Maven Packaging"
  cd /home/${APP_USER}/${COMPONENT}  && mvn clean package &>>${LOG_FILE} && mv target/shipping-1.0.jar shipping.jar &>>${LOG_FILE}
  StatCheck $?

  SERVICE_SETUP
}

PYTHON() {

  print "Install Python"
  yum install python36 gcc python3-devel -y &>>${LOG_FILE}
  StatCheck $?

  APP_SETUP

  print "Install Python Dependencies"
  cd /home/${APP_USER}/${COMPONENT} && pip3 install -r requirements.txt &>>${LOG_FILE}
  StatCheck $?

  SERVICE_SETUP

}