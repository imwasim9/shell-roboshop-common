#!/bin/bash

source ./common.sh

check_root

cp mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATE $? "Adding mongo repo"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "mongodb-org installation"

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "Enabling mongodb"
systemctl start mongod &>>$LOG_FILE
VALIDATE $? "Starting mongodb"
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>$LOG_FILE
VALIDATE $? "Allowing remote connections to mongodb"
systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "Restarting mongodb"

print_total_time
