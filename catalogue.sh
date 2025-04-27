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
        exit 1
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
VALIDATE $? "app created"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip -y &>> $LOGFILE
VALIDATE $? "catalogue application downloaded"


cd /app &>> $LOGFILE

unzip /tmp/catalogue.zip &>> $LOGFILE
VALIDATE $? "unziped catalouge file"

cd /app

npm install &>> $LOGFILE
VALIDATE $? "dependencies downloaded"


cp catalouge.service /etc/systemd/system/catalogue.service &>> $LOGFILE
VALIDATE $? "servicefile created"


systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "deamon reloaded"

systemctl enable catalogue &>> $LOGFILE
VALIDATE $? "catalouge enabled"


systemctl start catalogue &>> $LOGFILE
VALIDATE $? "catalogue started"


cp /root/roboshop.shell/mongo.repo &>> $LOGFILE
VALIDATE $? "mongodb repo copied"

dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? "mongodb client installed"


mongo --host $mongo_host </app/schema/catalogue.js &>> $LOGFILE
VALIDATE $? "mongo host configured succesfully"


