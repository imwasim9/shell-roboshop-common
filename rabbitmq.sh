#!/bin/bash
source ./common.sh
check_root

cp $SCRIPT_DIR/rabbitmq.repo  /etc/yum.repos.d/rabbitmq.repo &>>$LOG_FILE
VALIDATE $? "add rabbitmq repo"

dnf install rabbitmq-server -y &>>$LOG_FILE
VALIDATE $? "install rabbitmq repo"
systemctl enable rabbitmq-server &>>$LOG_FILE
systemctl start rabbitmq-server &>>$LOG_FILE
VALIDATE $? "start rabbitmq repo"


if id roboshop &>>$LOG_FILE; then
    echo -e "User already exists ... $Y SKIPPING $N"    
else 
    rabbitmqctl add_user roboshop roboshop123 &>>$LOG_FILE
    VALIDATE $? "create system user"
    rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE
    VALIDATE $? "set user permission" 
fi

print_total_time