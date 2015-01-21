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
my $full_name = "bugzilla-$tag";
my $full_url  = "https://git.mozilla.org/bugzilla/bugzilla.git";

do_command('git', 'clone', $full_url, "--single-branch", "--depth", 1, "-b", $full_name, $full_name);

print "cd $full_name\n";
chdir $full_name or die "$full_name: $!";

if ($switch{'docs'}) {
    print "Building docs...\n";
    do_command("perl", "./docs/makedocs.pl", "--with-pdf");
}

chdir ".." or die "..: $!";
do_command("tar", "-czf", "$full_name.tar.gz", $full_name);
