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

rm -rf "${PKG_NAME}*.deb"
if [[ ! -f "$SRC_PACKAGE" ]]; then
    wget "$DOWNLOAD_URL"
fi

mkdir -p tmp && pushd tmp
rm -rf kafka

mkdir -p kafka
cd kafka

mkdir -p build/usr/lib/kafka
mkdir -p build/etc/default
mkdir -p build/etc/init
mkdir -p build/etc/kafka

cp "${ORIG_DIR}/kafka-broker.default" "build/etc/default/kafka-broker"
cp "${ORIG_DIR}/kafka-broker.upstart.conf" "build/etc/init/kafka-broker.conf"

tar zxf "${ORIG_DIR}/${SRC_PACKAGE}"
cd "kafka-${VERSION}-src"

./sbt update
./sbt package
./sbt assembly-package-dependency

patch -p0 < "${ORIG_DIR}/kafka-bin.patch"

mv config/log4j.properties config/server.properties ../build/etc/kafka
mv * ../build/usr/lib/kafka
cd ../build

fpm -t deb \
    -n "$PKG_NAME" \
    -v "${VERSION}-${BUILD_VERSION}" \
    --description "$DESCRIPTION" \
    --url="$URL" \
    -a "$ARCH" \
    --category "$SECTION" \
    --vendor "" \
    --license "$LICENSE" \
    -m "${USER}@localhost" \
    --prefix=/ \
    -s dir \
    -- .

mv kafka*.deb "$ORIG_DIR"
popd
