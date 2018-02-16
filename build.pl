#!/usr/bin/env perl

use warnings;
use strict;

use Getopt::Long;
 
our %switch;
GetOptions(\%switch, 'docs|d');

sub do_command {
    print join(' ', @_), "\n";
    system(@_) && die $!;
}

my $tag = shift @ARGV;

$tag || die "second argument must be the version number (bugzilla-<version> git tag)";

# git clone https://git.mozilla.org/bugzilla/bugzilla.git
# --single-branch only checksout the branch the tag exists in
# --depth 1 is used to omit getting full history
# -b <tag_name> only clones up to the tag such as bugzilla-4.4.6
my $release_tag  = "release-$tag";
my $bugzilla_ver = "bugzilla-$tag";
my $git_url      = "https://github.com/bugzilla/bugzilla.git";

do_command('git', 'clone', $git_url, "--single-branch", "--depth", 1, "-b", $release_tag, $bugzilla_ver);

print "cd $bugzilla_ver\n";
chdir $bugzilla_ver or die "$bugzilla_ver: $!";

if ($switch{'docs'}) {
    print "Building docs...\n";
    do_command("perl", "./docs/makedocs.pl", "--with-pdf");
}

chdir ".." or die "..: $!";
do_command("tar", "-czf", "$bugzilla_ver.tar.gz", $bugzilla_ver);
