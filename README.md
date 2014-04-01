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

Kafka home folder
---

would be thee folder where the kafka will operate (/var/run/kafka)


General packaging
---

Following [Filesystem Hierarchy Standard](http://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard)  [here](http://www.pathname.com/fhs/): `/opt` is for programs that are not packaged and don't follow the standards. You'd just put all the libraries there together with the program.

Some other scripts on github have kafka packaged to /usr/lib/kafka (and they have bin, and libs inside)...

Yet, I find this wrong, but will reuse exsiting solution. YET. :-)
Later, maybe, this packaging script would be an atempt to pack kafka in right places.


