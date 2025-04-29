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

dnf install maven -y &>> $LOGFILE

id roboshop #if roboshop user does not exist, then it is failure
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir -p /app

VALIDATE $? "creating app directory"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE

VALIDATE $? "Downloading shipping"

cd /app

VALIDATE $? "moving to app directory"

unzip -o /tmp/shipping.zip &>> $LOGFILE

VALIDATE $? "unzipping shipping"

mvn clean package &>> $LOGFILE

VALIDATE $? "Installing dependencies"

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE

VALIDATE $? "renaming jar file"

cp /root/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE

VALIDATE $? "copying shipping service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "deamon reload"

systemctl enable shipping  &>> $LOGFILE

VALIDATE $? "enable shipping"

systemctl start shipping &>> $LOGFILE

VALIDATE $? "start shipping"

dnf install mysql -y &>> $LOGFILE

VALIDATE $? "install MySQL client"

mysql -h mysql.devopswithmsvs.uno -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE

VALIDATE $? "loading shipping data"

systemctl restart shipping &>> $LOGFILE

VALIDATE $? "restart shipping"