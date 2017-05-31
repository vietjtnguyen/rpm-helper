This repository contains scripts that help simplify the RPM packaging process given a package spec repository/folder like those found on https://src.fedoraproject.org/cgit/rpms/.

# `build.sh`

## Setup

This script uses [`mock`](https://github.com/rpm-software-management/mock/wiki) to build the packages in a clean environment. It also uses `spectool` to download sources from an RPM spec. You will need to install both before using this script.

```
sudo yum install mock rpmdevtools
```

## Usage

```
Usage: ./build.sh <MOCK_CFG> <PKG_FOLDER>
```

This script does the following:

1. Looks for a `*.spec` file in the provided folder
2. Establishes a default RPM build folder (`$HOME/rpmbuild`)
3. Copies the contents of the folder into `$HOME/rpmbuild/SOURCES` (to make sure it grabs any patches or auxiliary files needed to build the RPM)
4. Moves any `*.spec` files from `$HOME/rpmbuild/SOURCES` into `$HOME/rpmbuild/SPECS`
5. Downloads sources specified in the SPEC file into `$HOME/rpmbuild/SOURCES`
6. Builds a source RPM from `$HOME/rpmbuild`
7. Builds the source RPM using `mock` and the provided `mock` configuration file

Steps 2 through 5 are all about establishing a standard RPM build folder layout.

If anything works magically you'll get an RPM in the end located in your `mock` configuration's results location.

A standard `mock` configuration for something like CentOS 7 would be `/etc/mock/epel-7-x86_64.cfg`.

## Example

The following example utilizes `build.sh` to build the `python34-Pint` package.

```
git clone https://github.com/vietjtnguyen/rpm-helper.git
cd rpm-helper
git clone https://github.com/vietjtnguyen/fzf-rpm.git
./build.sh /etc/mock/epel-7-x86_64.cfg ./fzf-rpm
```

# `optimistic_fedora_build.sh`

## Usage

```
Usage: ./optimistic_fedora_build.sh <PACKAGE_NAME>
```

This takes advantage of `build.sh` and the Fedora packaging repositories:

> http://pkgs.fedoraproject.org/

Basically those repositories are structured in a way that `build.sh` can automatically process if they're not complicated (thus the "optimistic" name).

## Example

Say you're stuck on Enterprise Linux 7 and you need a package that isn't available or up-to-date. You think to yourself "this package should be in Fedora land so maybe I can backport it." You browse around https://src.fedoraproject.org/cgit/rpms/ and find it (say [`zeromq`](http://pkgs.fedoraproject.org/cgit/rpms/zeromq.git/), note this is already available in EPEL). To try packaging the latest and greatest from Fedora land but built with respect to your environment simply run the following:

```
./optimistic_fedora_build.sh zeromq
```

A lot of stuff is going to happen but by the end of it you'll hopefully magically have some working RPMs in the `mock` results folder (`/var/lib/mock/epel-7-x86_64/result`).
