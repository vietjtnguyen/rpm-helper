#!/bin/bash
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <MOCK_CFG> <PKG_FOLDER>" 1>&2
  exit 1
fi

set -x
MOCK_CFG=$1
PKG_FOLDER=$2

# Backup existing rpmbuild folder just in case
if [ -e "$HOME/rpmbuild" ]; then
  rm -rf $HOME/rpmbuild.backup
  mv $HOME/rpmbuild $HOME/rpmbuild.backup
fi

# Create new rpmbuild folder and copy files from the package folder into the
# rpmbuild folder
mkdir -p $HOME/rpmbuild/{SOURCES,SPECS}
cp -r $PKG_FOLDER/* $HOME/rpmbuild/SOURCES
mv $HOME/rpmbuild/SOURCES/*.spec $HOME/rpmbuild/SPECS/

# Download sources
spectool -g -C $HOME/rpmbuild/SOURCES $HOME/rpmbuild/SPECS/*.spec
if [ $? != 0 ]; then
  exit 1
fi

# This is an older, manual way of grabbing sources
#SOURCE_BALL=$(spectool -l $HOME/rpmbuild/SPECS/*.spec | head -n 1 | rev | cut -d / -f 1 | rev)
#for SOURCE_URI in $(spectool $HOME/rpmbuild/SPECS/*.spec | perl -pe 's/Source.+?: //'); do
#  if [ "$(echo $SOURCE_URI | cut -c -4)" == "http" ]; then
#    SOURCE_FILE=$(echo $SOURCE_URI | rev | cut -d / -f 1 | rev)
#    if [ ! -e $HOME/rpmbuild/SOURCES/$SOURCE_FILE ]; then
#      pushd $HOME/rpmbuild/SOURCES
#        wget -N $SOURCE_URI
#      popd
#    fi
#  fi
#done

# Build source RPM
rpmbuild -bs $HOME/rpmbuild/SPECS/*.spec
if [ $? != 0 ]; then
  exit 1
fi

# Build the source RPM using mock
mock -r $MOCK_CFG rebuild $HOME/rpmbuild/SRPMS/*
