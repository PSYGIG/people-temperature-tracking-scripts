#!/bin/bash
#
#    upgrade
#    Script for upgrading (or downgrading) to a specific version of people-temperature-tracking
#
#    Copyright (C) 2020 PSYGIG株式会社
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

SCRIPTNAME=$(basename $0)
SCRIPTVER=1.0.0
SCRIPTPATH=$(dirname $0)
RELEASETAG=
VERBOSE=0

version()
{
    cat <<EOF
$SCRIPTNAME $SCRIPTVER
EOF
    exit 0
}

usage()
{
    cat <<EOF

Script for upgrading (or downgrading) to a specific version of people-temperature-tracking

Usage:
  $SCRIPTNAME [instrumentation-options] [output-options] "<command+arguments>"

Example:
  $SCRIPTNAME --release "1.0.0"

Options:
  -V, --version           Print version information.
  -h, --help              Print help.
  -r, --release           Release version to upgrade/downgrade to
  -v, --verbose           Enable verbose output
 
EOF
    exit 0
}

# Return success (0) if $1 is not empty and not the next option.
arg_ok()
{
    case "x$1" in
	x | x-* ) return 1 ;;
	* ) return 0 ;;
    esac
}

die()
{
    cat <<EOF 1>&2
$SCRIPTNAME: $*
use '$SCRIPTNAME -h' for a summary of options
EOF
    exit 1
}

while [ "$#" != 0 ]; do
  case "$1" in
    -h | --help )
      usage; exit 1;;

    -V | --version )
      version; exit 1;;

    -v | --verbose )
      VERBOSE=1
      shift ;;

    -r | --release )
      arg_ok "$2" || die "missing argument for $1"
      RELEASETAG=$2
      shift; shift ;;

    -- )
      shift; break ;;

    -* )
      die "unrecognised option $1"
      exit 1 ;;

    * )
      break ;;
  esac
done

ADDOPTS=

if [ $VERBOSE -eq 0 ]
then
    ADDOPTS=--quiet
fi

# Get new tags from remote
git fetch --tags $ADDOPTS
if [ $? -ne 0 ]
then
  echo "ERROR: Could not retrieve version list"
  exit 1
fi

if [ -z "$RELEASETAG" ]
then
  echo "Enter the version you want to upgrade (or downgrade) to: [Leave blank for latest]"
  read RELEASETAG

  if [ -z "$RELEASETAG" ]
  then
    # Get latest tag name
    RELEASETAG=$(git describe --tags `git rev-list --tags --max-count=1`)
  fi
fi

# Checkout latest tag
git checkout -f $RELEASETAG $ADDOPTS
if [ $? -ne 0 ]
then
  echo "ERROR: Unable to upgrade to version \"$RELEASETAG\""
  echo "       Check that the version exists"
  exit 1
fi

echo "Successfully upgraded to version \"$RELEASETAG\""
exit 0
