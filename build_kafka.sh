#!/bin/bash
set -e
set -u

PKG_NAME="kafka"
VERSION="0.8.1"
DESCRIPTION="Apache Kafka is a distributed publish-subscribe messaging system."
URL="https://kafka.apache.org/"
ARCH="all"
SECTION="misc"
LICENSE="Apache Software License 2.0"
SRC_PACKAGE="kafka-${VERSION}-src.tgz"
DOWNLOAD_URL="https://dist.apache.org/repos/dist/release/kafka/${VERSION}/${SRC_PACKAGE}"
ORIG_DIR="$(pwd)"
BUILD_VERSION=

usage() {
    echo "Usage: $0 -b \"<build version>\" -h"
    echo "    -h Prints this message"
    echo "    -b Build version string, ex: ubuntu1"
}

while getopts ":b:h" NAME; do
    case "$NAME" in
        b)
            BUILD_VERSION=${OPTARG}
            ;;
        h)
            usage
            exit 0
            ;;
        *)
            echo "Unkown option: $OPTARG"
            echo ""
            usage
            exit 1
            ;;
    esac
done

if [ "x$BUILD_VERSION" = "x" ]; then
    echo "No build version was supplied"
    echo ""
    usage
    exit 1
fi

#_ MAIN _#
function cleanup() {
    rm -rf "${PKG_NAME}*.deb"
}

function bootstrap() {
    if [[ ! -f "$SRC_PACKAGE" ]]; then
        wget "$DOWNLOAD_URL"
    fi

    mkdir -p tmp && pushd tmp
    rm -rf kafka

    mkdir -p kafka
    cd kafka

    mkdir -p build/usr/lib/kafka
    mkdir -p build/etc/default
    #mkdir -p build/etc/init
    mkdir -p build/etc/init.d
    mkdir -p build/etc/kafka
    mkdir -p build/var/log/kafka
}

function build() {
    tar zxf "${ORIG_DIR}/${SRC_PACKAGE}"
    cd "kafka-${VERSION}-src"

    # TODO: in new kafka 0.8.1 gradlew is used! -> Update
    ./sbt update
    ./sbt package
    ./sbt assembly-package-dependency

    # apply patch with KAFKA_HEAP_OPTS extensibility tweak
    patch -p0 < "${ORIG_DIR}/kafka-bin.patch"

    cp -rp config/* ../build/etc/kafka
    mv config config.old
    cp ${ORIG_DIR}/log4j.properties ../build/etc/kafka
    # or ?
    #mv config/log4j.properties config/server.properties ../build/etc/kafka

    mv * ../build/usr/lib/kafka
    cd ../build
}

function build_from_binary(){
    BINARY_PACKAGE=kafka_2.9.2-0.8.1
    
    wget https://dist.apache.org/repos/dist/release/kafka/0.8.1/${BINARY_PACKAGE}.tgz
    tar -xzf ${BINARY_PACKAGE}.tgz

    cd ${BINARY_PACKAGE}

    cp -rp config/* ../build/etc/kafka

    mv config config.old
    mv * ../build/usr/lib/kafka
    cd ../
}

function apply_configs(){

    cp "${ORIG_DIR}/kafka-broker.default" "build/etc/default/kafka-broker"
    cp "${ORIG_DIR}/kafka-broker.postinst" "build/kafka-broker.postinst"
    
    # Service
    cp "${ORIG_DIR}/kafka-broker.init-script.sh" "build/etc/init.d/kafka"
    #cp "${ORIG_DIR}/kafka-broker.upstart.conf" "build/etc/init/kafka-broker.conf"

    cp ${ORIG_DIR}/log4j.properties build/etc/kafka
}

function mkdeb() {

  cd build

  fpm -t deb \
    -n "$PKG_NAME" \
    -v "${VERSION}-${BUILD_VERSION}" \
    --description "$DESCRIPTION" \
    --url="$URL" \
    -a "$ARCH" \
    --category "$SECTION" \
    --vendor "" \
    --license "$LICENSE" \
    --after-install ./kafka-broker.postinst \
    -m "${USER}" \
    --config-files /etc/default/kafka-broker \
    --config-files /etc/init.d/kafka \
    --prefix=/ \
    -s dir \
    -- .
  mv kafka*.deb ${ORIG_DIR}
  popd
}

function main() {
    cleanup
    bootstrap
    #build_from_sources
    build_from_binary
    apply_configs 
    mkdeb
}

main
