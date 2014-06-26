#!/bin/bash
set -e
set -u
name="kafka"
version=${_KVERSION:-"0.8.1"}
scala_version=${_KSCALAVERSION:-"2.10"}
description="Apache Kafka is a distributed publish-subscribe messaging system."
url="https://kafka.apache.org/"
arch="all"
section="misc"
license="Apache Software License 2.0"
package_version=${_KPKGVERSION:-"-1"}
src_package="${name}_${scala_version}-${version}.tgz"
download_url="https://dist.apache.org/repos/dist/release/kafka/${version}/${src_package}"
origdir="$(pwd)"

function cleanup() {
    rm -rf ${name}*.deb
}

function bootstrap() {
    if [[ ! -f "${src_package}" ]]; then
        wget ${download_url}
    fi
    mkdir -p tmp && pushd tmp
    rm -rf ${name}
    mkdir -p ${name}
    cd ${name}
    mkdir -p build/usr/lib/${name}
    mkdir -p build/etc/default
    mkdir -p build/etc/init
    mkdir -p build/etc/${name}
    mkdir -p build/var/log/${name}
}

function build() {
    #cp ${origdir}/kafka-broker.default build/etc/default/kafka-broker
    #cp ${origdir}/kafka-broker.upstart.conf build/etc/init/kafka-broker.conf
    
    tar zxf ${origdir}/${src_package}
    cd ${name}_${scala_version}-${version}
    cp -rp config/* ../build/etc/${name}
    mv config config.old
    cp ${origdir}/log4j.properties ../build/etc/${name}
    mv * ../build/usr/lib/${name}

    if [ -f ${origdir}/kafka-server-start.sh-${version} ]; then cp ${origdir}/kafka-server-start.sh-${version} ../build/usr/lib/kafka/bin/kafka-server-start.sh;fi

    cd ../build
}

function mkdeb() {
  fpm -t deb \
    -n ${name} \
    -v ${version}${package_version} \
    --description "${description}" \
    --url="${url}" \
    -a ${arch} \
    --category ${section} \
    --vendor "" \
    --after-install ../../../kafka-broker.postinst \
    --after-remove  ../../../kafka-broker.postrm \
    --before-remove ../../../kafka-broker.prerm \
    -m "${USER}@${HOSTNAME}" \
    --deb-default ../../..//kafka-broker.default \
    --deb-upstart ../../..//kafka-broker \
    --config-files /etc/${name}/log4j.properties \
    --config-files /etc/${name}/server.properties \
    --config-files /etc/${name}/producer.properties \
    --config-files /etc/${name}/consumer.properties \
    --license "${license}" \
    --prefix=/ \
    -s dir \
    -- .
  mv kafka*.deb ${origdir}
  popd
}

function main() {
    cleanup
    bootstrap
    build
    mkdeb
}
main
