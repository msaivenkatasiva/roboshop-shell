#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 .....$R failed $N"
        exit 1
    else
        echo -e "$2......$G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then    
    echo -e "$R error:: you are not a root user $N"
    exit 1
else
    echo -e "$G you are root user $N"
fi

dnf install python36 gcc python3-devel -y &>>$LOGFILE
VALIDATE $? "installing python36"

id roboshop #if user doesn't exists, then it's failure and creates a user
if [ $? -ne 0 ]
then 
    echo -e "user already exists $Y.....skkipping$N"
else
    useradd roboshop &>>$LOGFILE
    VALIDATE $? "user roboshop added"
fi


mkdir -p /app &>>$LOGFILE
VALIDATE $? "app created"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>>$LOGFILE
VALIDATE $? "validating payment"

cd /app 

unzip -p /tmp/payment.zip &>>$LOGFILE
VALIDATE $? "unzipping payment"

cd /app 

pip3.6 install -r requirements.txt &>>$LOGFILE
VALIDATE $? "dependencies installed"

cp /root/roboshop-shell/payment.service /etc/systemd/system/payment.service &>>$LOGFILE
VALIDATE $? "copying payment.service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "deamon reloaded"

systemctl enable payment &>>$LOGFILE
VALIDATE $? "enabling payment"

systemctl start payment &>>$LOGFILE
VALIDATE $? "payment started"
