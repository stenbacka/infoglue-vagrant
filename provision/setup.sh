#!/bin/bash

set -e

# Colors
ESC_SEQ="\x1b["
COL_RESET=$ESC_SEQ"39;49;00m"
COL_RED=$ESC_SEQ"31;01m"
COL_GREEN=$ESC_SEQ"32;01m"
COL_YELLOW=$ESC_SEQ"33;01m"
COL_BLUE=$ESC_SEQ"34;01m"
COL_MAGENTA=$ESC_SEQ"35;01m"
COL_CYAN=$ESC_SEQ"36;01m"


function print_success {
	echo -e "${COL_GREEN}$1${COL_RESET}"
}

export DEBIAN_FRONTEND=noninteractive

echo "Provisioning Infoglue Vagrant..."

startime=$(date +"%Y-%m-%d %H:%M")
provision_output_file=/tmp/provision.log
PROVISION_DIR=/vagrant/provision

echo "Starting provisioning at `$starttime`" >> $provision_output_file

#################################################
## Essentials  ##################################
#################################################

echo "Installing essentials..."

apt-get update >> $provision_output_file
apt-get install -y debconf-utils >> $provision_output_file
apt-get install -y curl vim >> $provision_output_file

print_success "Essentials installed"

#################################################
##  Setup components  ###########################
#################################################

source $PROVISION_DIR/mysql/setup.sh
source $PROVISION_DIR/mailcatcher/setup.sh
source $PROVISION_DIR/tomcat/setup.sh
source $PROVISION_DIR/httpd/setup.sh

echo "Completed provisioning" >> $provision_output_file
print_success "Completed provisioning"
