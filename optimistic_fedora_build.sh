#!/bin/bash
if [ -z "$1" ]; then
  echo "Usage: $0 <PACKAGE_NAME>" 1>&2
  exit 1
fi

set -x
PACKAGE_NAME=$1

if [ ! -e $PACKAGE_NAME ]; then
  git clone https://src.fedoraproject.org/git/rpms/$PACKAGE_NAME.git
  if [ $? != 0 ]; then
    exit 1;
  fi
fi

EL_VERSION=$(rpm --eval "%{dist}" | perl -pe 's/.*?(\d+).*/\1/')
ARCH=$(uname -m)
./build.sh /etc/mock/epel-${EL_VERSION}-${ARCH}.cfg $PACKAGE_NAME
