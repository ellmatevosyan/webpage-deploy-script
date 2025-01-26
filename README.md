# webpage-deploy-script
This repository contains a Bash script to automate the deployment of an e-commerce web application. The script installs and configures the required infrastructure, including a database server, web server, and firewall rules. It also sets up the application with sample data.

---

## Overview
The deployment script performs the following actions:
1. Installs and configures `firewalld` with rules for the database and web servers.
2. Installs MariaDB, creates a database (`ecomdb`), and loads product inventory data.
3. Sets up Apache HTTP server and PHP to host the web application.
4. Downloads the e-commerce web application from a Git repository.
5. Verifies the deployment by checking the availability of key items on the web page.

---

## Commands
### Run the Script
To execute the deployment script:
```bash
./deploy-ecommerce-application.sh
```


## Prerequisites
1. Supported OS: A CentOS-based system with sudo privileges.
2. Network Access: ENsure internet connectivity for installing packages and cloning the application.
3. Dependencies: The script installs necessary tools like firewalld, MariaDB, Apache, PHP, and git.

## Setup Guide
1. Clone the repositry:
```bash
git clone <repository-url>
cd <repository-name>
```
2. Make the script executable:
```bash
chmod +x deploy-ecommerce-application.sh
```
3. Run the script:
```bash
./deploy-ecommerce-application.sh
```

## Script Details
### 1. Firewall Configuration
* Installs `firewalld`.
* Adds rules to open ports:
    * `3306` for database.
    * `80` for web server.
### 2. Database Setup
* Installs MariaDB and configures it.
* Creates:
    * Database: `ecomdb`
    * User: `ecomuser` with password `ecompassword`
* Loads sample product inventory into the database.
### 3. Web Server Setup
* Installs Apache HTTP server and PHP.
* Configures `httpd` to serve PHP files.
* Clones the e-commerce application repository.
* Updates database configurations in the application code.
### 4. Validation
* Verifies:
    * Services are running (`firewalld`, `mariadb`, `httpd`).
    * Firewall rules are configured correctly.
    * Sample data is loaded into the database.
    * Web page contains key inventory items.
---
## Example Output
The script outputs progress logs, such as:
* Service status checks:
 ```bash
[green] firewalld Service is active
[green] mariadb Service is active
```
* Database validation:
 ```bash
[green] Inventory data is loaded
```
* Web page validation:
```bash
[green] Item Laptop is present on the web page
```
