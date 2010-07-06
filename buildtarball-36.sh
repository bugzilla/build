#!/bin/sh
#
echo "This script will build a Bugzilla tarball based on a given CVS tag."
if [ ! "X$1" = "X" ] ; then
  BZTAG=$1
  echo "Using CVS tag from command line: $BZTAG"
else
  echo -n "Enter the CVS tag to use: "
  read BZTAG
  if [ "X$BZTAG" = "X" ] ; then
    echo "You entered an empty string - aborting."
    exit
  fi
fi
if [ ! "X$2" = "X" ] ; then
  BZDIR=$2
  echo "Using unpack directory name from command line: $BZDIR"
else
  echo "Enter the name of the folder that should be created when the end user"
  echo -n "unpacks the tarball: "
  read BZDIR
  if [ "X$BZDIR" = "X" ] ; then
    echo "You entered an empty string - aborting."
    exit
  fi
fi

CMD="cvs -d :pserver:anonymous@cvs-mirror.mozilla.org:/cvsroot co -d $BZDIR -r $BZTAG Bugzilla"
echo $CMD
$CMD
if [ ! -e $BZDIR ] ; then
  echo "$0: CVS checkout failed"
  exit
fi

echo "cd $BZDIR"
cd $BZDIR
echo "cvs -q up -dP"
cvs -q up -dP
if [ ! -e docs/pdf ] ; then
  echo "Building docs..."
  perl -w docs/makedocs.pl --with-pdf
fi
echo "Installing CGI.pm..."
./install-module.pl CGI
echo "Removing non-essential dependencies from lib/..."
rm -rf lib/*linux*  lib/man  lib/Test lib/App lib/ExtUtils lib/TAP lib/CPAN* lib/YAML*
echo "cd .."
cd ..
echo "tar cfz ${BZDIR}.tar.gz $BZDIR"
tar cfz ${BZDIR}.tar.gz $BZDIR
echo "Done."
