kafka-deb-packaging
===================

Simple debian packaging for Apache Kafka.
This project relays on https://github.com/jordansissel/fpm

Please note that the kafka broker does NOT start after package installation, I think it is wrong for deamons to be started after install.
Nice write up about this problem : http://major.io/2014/06/26/install-debian-packages-without-starting-daemons/ 
