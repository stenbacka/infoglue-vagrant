    . _____        __             _
      \_   \_ __  / _| ___   __ _| |_   _  ___
       / /\/ '_ \| |_ / _ \ / _` | | | | |/ _ \
    /\/ /_ | | | |  _| (_) | (_| | | |_| |  __/
    \____/ |_| |_|_|  \___/ \__, |_|\__,_|\___|
            /\   /\__ _  __ |___/_ __ _ _ __ | |_
            \ \ / / _` |/ _` | '__/ _` | '_ \| __|
             \ V / (_| | (_| | | | (_| | | | | |_
              \_/ \__,_|\__, |_|  \__,_|_| |_|\__|
                        |___/

# About
This is a development environment for Infoglue development.

*TODO* Add tomcat debug capabilities

## Environment components
The environment contains the following parts.

- Apache Tomcat
- Apache web server
- MySQL
- Mailcatcher

## General information
The default environment only deploys the CMS instance and a working instance. If a live or preview instance is desired it will have to be enabled in the build.properties file.

*The environment can be access through the IP _192.168.13.37_*.
- CMS instace: http://192.168.13.37/infoglueCMS
- Working instace: http://192.168.13.37/infoglueDeliverWorking

# Requirements
- Virtualbox
- Vagrant
- Java JDK >=8
- Eclipse (recommended but not required)

# Install
- Run `vagrant up`.
- Copy the `build.properties` file into the infoglue folder.
- Build infoglue using _ant_. Either through Eclipse or using standalone ant.
- Since the build process is not completely compatible with this setup some files needs to copied manually. This will be a one-time operation for most developers.

  SSH into the virtual machine and execute `sudo mv /opt/tomcat/webapps/infoglue-libs/* /opt/tomcat/lib && sudo rmdir /opt/tomcat/webapps/infoglue-libs`
- Restart _tomcat_.

The provisioning script will create a database with some default data. It might however be desirable to import a database export instead. This has to be done manually by connecting to the virtual MySQL instance.

# Workflow
The Infoglue build script will put a number of webapps in a folder. This vagrant environment is setup with a shared folder where these webapps can be access both by the host environment and the virtual machine. The idea is that the host machine build the code and the virtual machine runs the server environment.

# Troubleshooting

## Tomcat service fail to start
- Verify that the logs directory was created properly in the tomcat home directory and that the tomcat user is allowed to write to the folder.
