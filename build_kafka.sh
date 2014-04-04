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

    mkdir -p build/opt/kafka     # for package
    mkdir -p build/var/lib/kafka # for kafka messages storage
    mkdir -p build/etc/default
    #mkdir -p build/etc/init     # for upstart conf on ubuntu
    mkdir -p build/etc/init.d    # for init script on debian
    mkdir -p build/var/log/kafka # for log files
    # used a link to /opt/kafka/config instead of mkdir -p build/etc/kafka
    # used /var/run/ to store kafka.pid
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

    mv ${BINARY_PACKAGE}/* build/opt/kafka
    # we don't need windows binaries in deb package
    # symbolic link to configs is created in postinst script    
}

function apply_configs(){
    cp "${ORIG_DIR}/etc/default/kafka" "build/etc/default/kafka"

    # Service
    cp "${ORIG_DIR}/etc/init.d/kafka" "build/etc/init.d/kafka"
    # TODO: Ubuntu option?
    #cp "${ORIG_DIR}/kafka-broker.upstart.conf" "build/etc/init/kafka-broker.conf"

    cp ${ORIG_DIR}/log4j.properties build/opt/kafka/config/
    
    # symlink from /etc/kafka -> /opt/kafka/config is made in postinst
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
    --before-install ${ORIG_DIR}/kafka.preinst \
    --after-install ${ORIG_DIR}/kafka.postinst \
    --after-remove ${ORIG_DIR}/kafka.postrm \
    -m "${USER}" \
    --config-files /etc/default/kafka \
    --config-files /etc/init.d/kafka \
    --prefix=/ \
    -d "default-jre" \
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
