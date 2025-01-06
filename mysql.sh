#!/bin/bash
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/expense-logs"
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H:%M:%S)
LOG_FILE_NAME="$LOG_FOLDER/$LOG_FILE-$TIMESTAMP"

VALIDATE(){
    if [ $? -ne 0 ]
    then
    echo -e "$R $2 is .....FAILURE $N"
    else
    echo -e "$G $2 is .....SUCCESS $N"
    fi
}

CHECH_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo -e "$R Need sudo access for installing packages $N"
        exit 1
    fi
}

echo -e "$G Execution of the script started $N at : $TIMESTAMP" &>>LOG_FILE_NAME

CHECH_ROOT

dnf install mysql-server -y &>>LOG_FILE_NAME
VALIDATE $? "Installing Mysql-Server"

systemctl enable mysqld &>>LOG_FILE_NAME
VALIDATE $?, "Enabling mysql"

systemctl start mysqld &>>LOG_FILE_NAME
VALIDATE $?,"Started Mysql"

mysql_secure_installation --set-root-pass ExpenseApp@1
VALIDATE $? "Setting Root Password"
