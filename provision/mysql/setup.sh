#!/bin/bash

set -e

MYSQL_USER=infoglue
MYSQL_PASSWORD=changeit
MYSQL_DATABASE=infoglue_vagrant
MYSQL_HOST=127.0.0.1
MYSQL_FULL_USER="${MYSQL_USER}@${MYSQL_HOST}"

if service --status-all 2> /dev/null | grep -Fq "mysql"; then
	MYSQL_IS_INSTALLED=true
else
	MYSQL_IS_INSTALLED=false
fi

if $MYSQL_IS_INSTALLED; then
	echo "MySQL already installed"
else
	echo "Installing MySQL ... "

	DB_ROOT_PASSWORD="changeit"
	debconf-set-selections <<< "mysql-server mysql-server/root_password password $DB_ROOT_PASSWORD"
	debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DB_ROOT_PASSWORD"

	apt-get install mysql-server -y 2>&1 >> $provision_output_file

	echo "> Configuring MySQL settings ..."
	cp /vagrant/provision/mysql/config.cnf /root/.my.cnf
	mysql <<- EOM
		SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
	EOM

	print_success "MySQL installed"
fi

if ! mysql --execute="select CONCAT_WS('@', User, Host) from mysql.user" | grep $MYSQL_FULL_USER > /dev/null
then
	echo "> Creating MySQL user ..."
	mysql  <<- EOM
		CREATE USER $MYSQL_FULL_USER IDENTIFIED BY "$MYSQL_PASSWORD";
		GRANT ALL ON ${MYSQL_DATABASE}.* TO $MYSQL_FULL_USER;
		GRANT SELECT ON mysql.* TO $MYSQL_FULL_USER;
		FLUSH PRIVILEGES;
	EOM
fi

if ! mysqlshow  2> /dev/null | grep "$MYSQL_DATABASE" > /dev/null
then
	echo "> Creating database ..."
	mysql <<- EOM
		CREATE DATABASE $MYSQL_DATABASE CHARACTER SET utf8 COLLATE utf8_general_ci;
	EOM
fi

if ! [[ $(mysql  $MYSQL_DATABASE --execute="SHOW TABLES;") ]];
then
	echo "> Creating tables ..."
	mysql $MYSQL_DATABASE < /vagrant/infoglue/src/webapp/up2date/sql/infoglue_core_schema_mysql.sql
	echo "> Adding base data ..."
	mysql $MYSQL_DATABASE < /vagrant/infoglue/src/webapp/up2date/sql/infoglue_initial_data_mysql.sql
fi

print_success "MySQL configured"
