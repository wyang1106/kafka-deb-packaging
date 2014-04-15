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
Kafka working path (message logs): `/var/lib/kafka`, also this is $HOME for kafka user...
Kafka binaries path: `/opt/kafka`
Kafka configuration: `/etc/kafka` linked to `/opt/kafka/config`
Kafka init script (debian): `/etc/init.d/kafka`
Kafka "default" : `/etc/default/kafka` 

Question about binary locations
---

Following [Filesystem Hierarchy Standard](http://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard)  [here](http://www.pathname.com/fhs/): `/opt` is for programs that are not packaged and don't follow the standards. You'd just put all the libraries there together with the program.

Some other scripts on github have kafka packaged to `/usr/lib/kafka` (and they have `bin`, and `libs` inside), this approach does not comply with FHS.

So, this scripts packs the kafka into `/opt/kafka` (while keeping configs linked from `/etc` and init sript in `/etc/init.d/*`)

Logging
---

Kafka is using slf4j, and there is log4j config in /opt/kafka/config

Kafka heap optimization:
---
While there were patches that optimize kafka heap usage - this should be setup in `/etc/default/kafka`, as well as ulimits. Kafka can open lots of files, so in most cases ulimit for opened files should be changed from default.
Opposed to patching this in `./bin/kafka-run-class.sh`, maintaining a var in `/etc/default/kafka` is much more flexible way.

Distribution support
---

Yet this script was developed with LSB in mind, but tested only under debian 7 (can also work on other dists that support LSB and init system).
This script is building debian package, but using `fpm`, so it should also build `rpm` package. (not tested).

