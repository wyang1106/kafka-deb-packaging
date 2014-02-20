kafka-deb-packaging
===================

Simple debian packaging for Apache Kafka 0.8.0, with a few patches

kafka-bin.patch contains the following fixes

- The shell helper scripts are patched to be allow for overriding environment variables set within them
- The `kafka-run-class.sh` script no longer forcefully creates the log dir it believes should be used
