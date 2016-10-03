#!/bin/bash

set -e

if [ -f "/usr/sbin/apache2" ]; then
  echo "> Apache web server already installed"
else
  echo "> Installing Httpd"

  apt-get install -y apache2 2>&1 >> $provision_output_file
  a2dissite 000-default
  rm -rf /etc/apache2/sites-available/*
  cp $PROVISION_DIR/httpd/httpd.conf /etc/apache2/sites-available/infoglue.conf
  a2enmod proxy 2>&1 >> $provision_output_file
  a2ensite infoglue 2>&1 >> $provision_output_file
  a2enmod proxy_ajp 2>&1 >> $provision_output_file
  systemctl restart apache2 2>&1 >> $provision_output_file

  print_success "Httpd installed"
fi
