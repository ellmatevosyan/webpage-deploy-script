#!/bin/bash
#
# This script automates the deployment of a web page

######################################
#Print a given message in color
#Arguments:
# Color. eg: green, red
######################################
function print_color(){
    case $1 in
        "green") COLOR="\033[0;32m";;
        "red") COLOR="\033[0;31m" ;;
        "*") COLOR="\033[0m" ;;
        esac

    echo -e "${COLOR} $2 ${NC}"
}

######################################
#Check the status od a given service. Error and exit if not active
#Arguments:
# Service Name. eg: httpd, firewalld
######################################
function check_service_status(){
    is_service_active=$(systemctl is-active $1)
if [ $is_service_active = "active"]
then
    print_color "green" "$1 Service is active"
else
    print_color "red" "$1 Service is not active"
    exit 1
fi
}

######################################
# Check if a port is enabled in a firewalld rule
#Arguments:
# Port. eg: 3306, 80
######################################
function is_firewalld_rule_configured(){
    firewalld_ports=$(sudo firewall-cmd --list-all --zone=public | grep ports)
    if [[  $firewalld_ports = *$1* ]]
    then 
        print_color "green" "Port $1 is configured"
    else
        print_color "red" "Port $1 is not configured"
    fi
}

######################################
# Check if an Item is present in a given web page
#Arguments:
#  Webpage
#  Item
######################################
function check_item(){
    if [[ $1 = *$2* ]]
    then 
        print_color "green" "Item $2 is present on the web page"
    else 
        print_color "red" "Item $2 is not present on the web page"
        
    fi
}


# --------------Database Configuration -------------------
#Install and configure firewalld
print_color "green" "Installing firewalld..."
sudo yum install -y firewalld
sudo systemctl start firewalld
sudo systemctl enable firewalld

check_service_status firewalld

#Install and configure MariaDB
print_color "green" "Installing MariaDB..."
sudo yum install -y mariadb-server

sudo systemctl start mariadb
sudo systemctl enable mariadb

check_service_status mariadb


#Add firewalld rules for Database
print_color "green" "Adding firewall rules for DB..."
sudo firewall-cmd --permanent --zone=public --add-port=3306/tcp
sudo firewall-cmd --reload

is_firewalld_rule_configured 3306


#Configure Database server
print_color "green" "Configuring DB..."
cat > setup-db.sql <<-EOF
  CREATE DATABASE ecomdb;
  CREATE USER 'ecomuser'@'localhost' IDENTIFIED BY 'ecompassword';
  GRANT ALL PRIVILEGES ON *.* TO 'ecomuser'@'localhost';
  FLUSH PRIVILEGES;
EOF

sudo mysql < setup-db.sql

#Load Product Inventory Information to database
print_color "green" "Loading inventory data into DB..."
cat > db-load-script.sql <<-EOF
USE ecomdb;
CREATE TABLE products (id mediumint(8) unsigned NOT NULL auto_increment,Name varchar(255) default NULL,Price varchar(255) default NULL, ImageUrl varchar(255) default NULL,PRIMARY KEY (id)) AUTO_INCREMENT=1;

INSERT INTO products (Name,Price,ImageUrl) VALUES ("Laptop","100","c-1.png"),("Drone","200","c-2.png"),("VR","300","c-3.png"),("Tablet","50","c-5.png"),("Watch","90","c-6.png"),("Phone Covers","20","c-7.png"),("Phone","80","c-8.png"),("Laptop","150","c-4.png");

EOF

sudo mysql < db-load-script.sql

#Checking if the db is created properly
mysql_db_results=$(sudo mysql -e "use ecomdb; select * from products;")
if [[ $mysql_db_results = *Laptop* ]]
then
    print_color "green" "Inventory data is loaded"
else
    print_color "red" "Inventory data is not loaded"
    exit 1
fi
# -------------- Web Server Configuration -------------------
#Install apache web server and php
print_color "green" "Configuring web server..."
sudo yum install -y httpd php php-mysqlnd

#Configure firewall rules for web server
print_color "green" "Configuring firewall rules for web server..."
sudo firewall-cmd --permanent --zone=public --add-port=80/tcp
sudo firewall-cmd --reload

is_firewalld_rule_configured 80

#Configure httpd
sudo sed -i 's/index.html/index.php/g' /etc/httpd/conf/httpd.conf

#Start httpd
print_color "green" "Starting web server..."
sudo systemctl start httpd
sudo systemctl enable httpd

#Download code
print_color "green" "Cloning GIT Repo..."
sudo yum install -y git
sudo git clone https://github.com/kodekloudhub/learning-app-ecommerce.git /var/www/html/

sudo sed -i 's#// \(.*mysqli_connect.*\)#\1#' /var/www/html/index.php
sudo sed -i 's#// \(\$link = mysqli_connect(.*172\.20\.1\.101.*\)#\1#; s#^\(\s*\)\(\$link = mysqli_connect(\$dbHost, \$dbUser, \$dbPassword, \$dbName);\)#\1// \2#' /var/www/html/index.php


#Replace database IP with localhost
sudo sed -i 's/172.20.1.101/localhost/g' /var/www/html/index.php
print_color "green" "All set."

web_page=$(curl http://localhost)
#Check the availability of the web page by searching the word Laptop

for item in Laptop Drone VR Watch
do 
    check_item "$web_page" $item
done 
