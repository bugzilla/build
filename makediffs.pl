#!/usr/bin/perl -w

use strict;

use File::Temp qw(tmpnam);

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

	# Move the $base/lib and $diffing/lib to temporary locations
	# so we don't include them in the diffs
	my $latest_tempdir_name  = tmpnam();
        my $diffing_tempdir_name = tmpnam();
	dosys("mv $latest/lib $latest_tempdir_name");
	dosys("mv $diffing/lib $diffing_tempdir_name");

        dosys("diff -urN --exclude=CVS --exclude=*.pdf --exclude=.bzr"
              . " $diffing $latest > $diffing-to-$latest_ver.diff");
        dosys("gzip $diffing-to-$latest_ver.diff");
        dosys("diff -urN --exclude=CVS --exclude=docs --exclude=.bzr"
              . " $diffing $latest > $diffing-to-$latest_ver-nodocs.diff");
        dosys("gzip $diffing-to-$latest_ver-nodocs.diff");

	# Move the lib directories back
	dosys("mv $latest_tempdir_name $latest/lib");
        dosys("mv $diffing_tempdir_name $diffing/lib");
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
