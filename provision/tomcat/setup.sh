#!/bin/bash

export TOMCAT_USER=tomcat
export TOMCAT_GROUP=tomcat
export TOMCAT_VERSION="8.0.37"
export TOMCAT_INSTALL_DIR=/opt/tomcat

if ls -l /etc/systemd/system/ | grep -Fq "tomcat" ; then
	TOMCAT_IS_INSTALLED=true
else
	TOMCAT_IS_INSTALLED=false
fi

if $TOMCAT_IS_INSTALLED; then
	echo "Tomcat already installed"
else
	echo "Installing Tomcat ... "

	echo "> Installing Java JDK ..."
	apt-get install -y default-jdk 2>&1 >> $provision_output_file

	echo "> Adding Tomcat user and group ..."
	[ $(getent group $TOMCAT_GROUP) ] || groupadd $TOMCAT_GROUP
	[ $(getent passwd $TOMCAT_USER) ] || useradd -s /bin/false -g $TOMCAT_GROUP -d /opt/tomcat $TOMCAT_USER

	echo "> Downloading Tomcat"
	cd /tmp
	curl -O --silent "http://apache.mirrors.ionfish.org/tomcat/tomcat-8/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz" >> $provision_output_file

	echo "> Extracting Tomcat files ..."
	mkdir -p $TOMCAT_INSTALL_DIR
	tar xzf apache-tomcat-${TOMCAT_VERSION}.tar.gz -C $TOMCAT_INSTALL_DIR --strip-components=1 >> $provision_output_file
	cd $TOMCAT_INSTALL_DIR
	chgrp -R tomcat conf
	mkdir -p $TOMCAT_INSTALL_DIR/logs
	chmod g+rwx conf
	chmod g+r conf/*
	chown -R tomcat webapps/ work/ temp/ logs/

	jdk_path=$(update-java-alternatives -l | awk '{ print $3 }')
	export JAVA_HOME="$jdk_path/jre"

	cat $PROVISION_DIR/tomcat/tomcat.service | envsubst '${TOMCAT_USER} ${TOMCAT_GROUP} ${TOMCAT_INSTALL_DIR} ${JAVA_HOME}' > /etc/systemd/system/tomcat.service
	cat $PROVISION_DIR/tomcat/tomcat-user.xml > $TOMCAT_INSTALL_DIR/conf/tomcat-users.xml
	cat $PROVISION_DIR/tomcat/server.xml > $TOMCAT_INSTALL_DIR/conf/server.xml
	ls $TOMCAT_INSTALL_DIR/webapps/* | grep -v manager | xargs rm -rf
	systemctl daemon-reload
	systemctl start tomcat

	print_success "Tomcat installed"
fi
