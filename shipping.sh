#!/bin/bash
source ./common.sh
app_name=shipping


app_setup
java_setup
systemd_setup

if command -v mysql >/dev/null 2>&1; then
    echo -e "mysql already installed ... $Y SKIPPING $N"
else   
    dnf install mysql -y &>>$LOG_FILE
    VALIDATE $? "installing mysql client"
fi

if mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e 'use cities' &>>$LOG_FILE; then
    echo -e "Shipping data is already loaded ... $Y SKIPPING $N"
else
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql &>>$LOG_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql &>>$LOG_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOG_FILE
    VALIDATE $? "loading app data"
fi
app_restart
print_total_time