#!/bin/sh
set -e
# Build images for:
# * RPi 1
# * RPi 2

# Use option -b <branch> to change branch name
#   and      -v <versionnumber> (only relevant for zip file)

DO_BRANCH=""
DO_VERSION=""

while getopts "b:v:" opt; do
  case $opt in
    b)
      echo "Using branch $OPTARG"
      DO_BRANCH="BRANCH=$OPTARG"
      if test -d ./piratebox-ws ; then
        echo ".. Updateing repository"
        cd ./piratebox-ws
        git pull
        git checkout $OPTARG
        git pull
        cd -
      fi
      ;;
    v)
      echo "Using version $OPTARG"
      DO_VERSION="VERSION=$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done


mkdir -p images
for arch in "rpi" "rpi2" ; do
  make dist ARCH=$arch $DO_BRANCH $DO_VERSION
  sync
  mv *.img.zip images
  make clean ARCH=$arch $DO_BRANCH $DO_VERSION
done
