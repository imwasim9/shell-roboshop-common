
# color codes
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log" # /var/log/shell-roboshop/mongodb.log
START_TIME=$(date +%s)
SCRIPT_DIR=$PWD # for current absolute path
MONGODB_HOST=mongodb.wasdaws.cyou
MYSQL_HOST=mysql.wasdaws.cyou

# getting the user id -> id -u, sudo id -u
USER_ID=$(id -u) # running the command using $()

mkdir -p $LOGS_FOLDER
echo "Script started at: $(date)" | tee -a $LOG_FILE

check_root(){  
    if [ $USER_ID -ne 0 ]; then
    echo -e "$R ERROR$N:: Please run this script with root privelege" | tee -a $LOG_FILE
    # failure code is 1 and success code is 0 for exit status
    # 0 - sucess, 1-127 failure codes   
    exit 1 
    fi
}

VALIDATE() {  #functions will recieve input via cmd line arguments just like shell script args
   if [ $1 -ne 0 ]; then
       echo -e "$R ERROR$N:: $2 failed please check logs" | tee -a $LOG_FILE
       exit 1 
   else 
       echo -e "$2 is $G successful$N" | tee -a $LOG_FILE
   fi 
}

nodejs_setup(){
    # ******* node js ************
    dnf module disable nodejs -y &>>$LOG_FILE
    VALIDATE $? "disabling nodejs"
    dnf module enable nodejs:$nodejs_version -y &>>$LOG_FILE
    VALIDATE $? "enabling nodejs:$nodejs_version"
    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "installing nodejs:$nodejs_version"
    
    npm install &>>$LOG_FILE
    VALIDATE $? "installing npm dependencies"
}

java_setup(){
    dnf install maven -y &>>$LOG_FILE
    VALIDATE $? "install maven"
    mvn clean package &>>$LOG_FILE
    VALIDATE $? "packaging the application"
    mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
    VALIDATE $? "Renaming the artifact"
}

python_setup(){
    dnf install python3 gcc python3-devel -y &>>$LOG_FILE
    VALIDATE $? "install python 3"
    pip3 install -r requirements.txt &>>$LOG_FILE
    VALIDATE $? "install python requirement dependencies"
}

app_setup(){    
    if id roboshop &>>$LOG_FILE; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop user" roboshop
        VALIDATE $? "Creating system user"
    else
        echo -e "User already exist ... $Y SKIPPING $N"
    fi
    mkdir -p /app
    VALIDATE $? "Creating app directory"
    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>>$LOG_FILE
    VALIDATE $? "Downloading $app_name application"
    cd /app &>>$LOG_FILE
    VALIDATE $? "Changing to app directory"
    rm -rf /app/* &>>$LOG_FILE # when we run more than one time better to delete existing code and install new code
    VALIDATE $? "Removing existing code"
    unzip /tmp/$app_name.zip &>>$LOG_FILE
    VALIDATE $? "unzip $app_name"
}

systemd_setup(){
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service &>>$LOG_FILE
    VALIDATE $? "Copy systemctl service"

    systemctl daemon-reload
    systemctl enable $app_name &>>$LOG_FILE
    VALIDATE $? "Enable $app_name"

}

app_restart(){
    systemctl restart $app_name &>>$LOG_FILE
    VALIDATE $? "Restarted $app_name"
}

print_total_time(){
    END_TIME=$(date +%s)
    TOTAL_TIME=$(($END_TIME - $START_TIME))
    echo -e "Script executed in: $Y $TOTAL_TIME seconds $N"
}
