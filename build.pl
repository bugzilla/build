#!/usr/bin/perl -w
#
use strict;
use Getopt::Long;

our %switch;
GetOptions(\%switch, 'dev|d');

sub do_command {
    print join(' ', @_), "\n";
    system(@_) && die $!;
}

my ($branch, $tag) = @ARGV;
$branch || die "first argument must be the branch nickname";
$tag || die "second argument must be the version number";

my $full_url  = "bzr://bzr.mozilla.org/bugzilla/$branch";
my $full_name = "bugzilla-$tag";
my @lightweight = $switch{'dev'} ? () : ('--lightweight');

do_command('bzr', 'co', @lightweight, "-r", "tag:$full_name", 
           $full_url, $full_name);

print "cd $full_name\n";
chdir $full_name or die "$full_name: $!";

print "Building docs...\n";
do_command("perl", "-w", "docs/makedocs.pl", "--with-pdf");

print "Installing CGI.pm...\n";
system("perl5.8.1", "install-module.pl", "CGI");
my @lib_contents = glob("lib/*");
foreach my $item (@lib_contents) {
    if ($item !~ m{^lib/(?:CGI|README)}) {
        do_command("rm", "-rf", $item);
    }
}

chdir ".." or die "..: $!";
do_command("tar", "-czf", "$full_name.tar.gz", $full_name);
