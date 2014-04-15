kafka-deb-packaging
===================

Simple debian packaging for Apache Kafka 0.8.1, 

Kafka user management
-----

According to debian guidelines kafka user will not be dropped on package deletion - only locked (postrm script)
On installation of a package user will be created, if not exists. If exists - unlocked.

Kafka folders
---

- Pid storage: `/var/run/*.pid`
- Kafka working path (message logs): `/var/lib/kafka`, also this is `$HOME` for kafka user...
- Kafka binaries path: `/opt/kafka`
- Kafka configuration: `/etc/kafka` linked to `/opt/kafka/config`
- Kafka init script (debian): `/etc/init.d/kafka`
- Kafka "default" : `/etc/default/kafka` 

Question about binary locations
---

Following [Filesystem Hierarchy Standard](http://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard)  [here](http://www.pathname.com/fhs/): `/opt` is for programs that are not packaged and don't follow the standards. You'd just put all the libraries there together with the program.

Some other scripts on github have kafka packaged to `/usr/lib/kafka` (and they have `bin`, and `libs` inside), this approach does not comply with FHS.

So, it was decided to use `/opt/kafka`. Configs are linked from `/etc` and init script is in `/etc/init.d/*`

Logging
---

Kafka is using `slf4j`, and there is `log4j` config in `/opt/kafka/config`

Kafka heap optimization:
---
`KAFKA_HEAP_OPTS` is set in `/etc/default/kafka`, as well as ulimits. These configs are pulled by init script. Kafka opens lots of files, so in most cases ulimit for opened files should be changed from default.

Distribution support
---

Yet this script was developed with LSB in mind, but tested only under debian 7 (can also work on other dists that support LSB and init system).
This script is building debian package, but using `fpm`, so it should also build `rpm` package. (not tested).

