#!/usr/bin/perl -w

use strict;
sub dosys {
  print "@_\n";
  system @_;
}
sub do_diff {
    my ($major, $minor, $micro) = @_;

    my $latest_ver = "$major.$minor.$micro";
    my $latest = "bugzilla-$latest_ver";
    my $base = "bugzilla-$major.$minor";

    my @prior_micro = map { ".$_" } (1..$micro-1);
    foreach my $this ('', @prior_micro) {
        my $diffing = "$base$this";
        dosys("diff -urN --exclude=CVS --exclude=*.pdf --exclude=lib/*"
              . " --exclude=.bzr"
              . " $diffing $latest > $diffing-to-$latest_ver.diff");
        dosys("gzip $diffing-to-$latest_ver.diff");
        dosys("diff -urN --exclude=CVS --exclude=lib/* --exclude=docs"
              . " --exclude=.bzr"
              . " $diffing $latest > $diffing-to-$latest_ver-nodocs.diff");
        dosys("gzip $diffing-to-$latest_ver-nodocs.diff");
    }
}

my @tarballs = glob('./bugzilla-*.tar.gz');

foreach my $tarball (@tarballs) {
    if ($tarball =~ /bugzilla-(\d)\.(\d+)\.(\d+).tar.gz/) {
        my ($major, $minor, $micro) = ($1, $2, $3);
        next if $minor % 2; # Don't do odd-numbered releases
        do_diff($major, $minor, $micro);
    }
}
