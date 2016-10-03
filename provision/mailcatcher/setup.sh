#!/bin/bash

set -e

apt-get install -y build-essential libsqlite3-dev ruby-dev 2>&1 >> $provision_output_file

if gem list | grep -Fq mailcatcher; then
  echo "> Mailcatcher already installed"
else
  echo "> Installing Mailcatcher"
  gem install mailcatcher 2>&1 >> $provision_output_file
  cp $PROVISION_DIR/mailcatcher/mailcatcher.service /etc/systemd/system/mailcatcher.service
  systemctl daemon-reload
	systemctl start mailcatcher

  print_success "Mailcatcher installed"
fi
