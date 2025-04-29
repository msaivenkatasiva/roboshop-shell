#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
mongo_host=mongodb.devopswithmsvs.uno

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

ID=$(id -u)

VALIDATE(){
    if [ $? -ne 0 ]
    then   
        echo -e "$2.....$R FAILED $N"
    else
        echo -e "$2.....$G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then 
    echo -e "$R error::Please try with root user $N"
    exit 1
else    
    echo -e "$G you are root user $N"
fi

dnf install nginx -y &>>$LOGFILE
VALIDATE $? "installing nginx"

systemctl enable nginx &>>$LOGFILE
VALIDATE $? "enabling nginx"

systemctl start nginx &>>$LOGFILE
VALIDATE $? "starting nginx"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE
VALIDATE $? "removing default website"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>>$LOGFILE
VALIDATE $? "downloading robosho"

unzip -p /tmp/web.zip &>>$LOGFILE
VALIDATE $? "unzipping application"

cp /root/roboshop-shell/roboshop.conf etc/nginx/default.d/roboshop.conf &>>$LOGFILE
VALIDATE $? "copying robo conf"

systemctl restart nginx &>>$LOGFILE
VALIDATE $? "restarted nginx"