kafka-deb-packaging
===================

Work in Progress.

Simple debian packaging for Apache Kafka 0.8.1, 


kafka-bin.patch contains the following fixes (applied only on source)

- The shell helper scripts are patched to be allow for overriding environment variables set within them
- The `kafka-run-class.sh` script no longer forcefully creates the log dir it believes should be used


Kafka user management
-----

According to debian guidelines kafka user will not be dropped on package deletion - only locked (postrm script)
On installation of a package user will be created, if not exists. If exists - unlocked.

Kafka folders
---

Pid storage: `/var/run/*.pid`
Kafka working path (message logs): `/var/lib/kafka`, also home for kafka user...
Kafka binaries path: `/opt/kafka`
Kafka configuration: `/etc/kafka` linked to `/etc/kafka/config`
Kafka init script (debian): `/etc/init.d/kafka`
Kafka "default" : `/etc/default/kafka` 

Question about binary locations
---

Following [Filesystem Hierarchy Standard](http://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard)  [here](http://www.pathname.com/fhs/): `/opt` is for programs that are not packaged and don't follow the standards. You'd just put all the libraries there together with the program.

Some other scripts on github have kafka packaged to /usr/lib/kafka (and they have bin, and libs inside)...

However, it seems to be wrong assumption, so this scripts packs the kafka into /opt/kafka

