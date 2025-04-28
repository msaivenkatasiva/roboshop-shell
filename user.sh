#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

MONGO_HOST=mongodb.devopswithmsvs.uno

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

VALIDATE(){
    if [ $? -ne 0 ]
    then
        echo -e "$2.....$R FAILED $N"
    else
        echo -e "$2.....$G success $N"
    fi
}

if [ $ID -ne 0 ]
then    
    echo -e "$R error::please enter with root user $N"
else
    echo -e "$G you are a root user $N"
fi

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "disabling nodejs successfull"

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "enabling nodejs:18 successfull"

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop
else  
    echo -e "$G roboshop user already exists $N"
fi
    
VALIDATE $? "userroboshop added"

mkdir -p /app 
VALIDATE $? "creating app directory"

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE
VALIDATE $? "downloading user application"

cd /app 

unzip -p /tmp/user.zip &>> $LOGFILE
VALIDATE $? "UNZIPPING user"

npm install &>> $LOGFILE
VALIDATE $? "dependencies created"

cp /C/Users/Dell/SIVA/devopswithmsvs/roboshop-shell/user.service /etc/systemd/system/user.service &>> $LOGFILE
VALIDATE $? "copying user.service"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "deamon reloaded successfully"

systemctl enable user &>> $LOGFILE
VALIDATE $? "user enabled successfully"

systemctl start user &>> $LOGFILE
VALIDATE $? "system started successfully"

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "copied mongodb repo"

dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? "installed mongodb client successfully"

mongo --host $MONGO_HOST </app/schema/user.js &>> $LOGFILE
VALIDATE $? "loading user data into mongodb"

