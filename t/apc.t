# -*- mode: cperl -*-

my $REPO = "/usr/sources/perl/repoperls/APC";

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..19\n"; }
END {print "not ok 1\n" unless $loaded;}
use Perl::Repository::APC;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

eval { Perl::Repository::APC->new };
if ($@) {
  print "ok 2\n";
} else {
  print "not ok 2\n";
}

if (-d $REPO) {
  my $apc = Perl::Repository::APC->new($REPO);
  print "ok 3\n";
  my $pver;
  $pver = $apc->get_to_version("perl",7100);
  print "not " unless $pver eq "5.7.1";
  print "ok 4\n";
  $pver = $apc->get_from_version("perl",7100);
  print "not " unless $pver eq "5.7.0";
  print "ok 5\n";
  $pver = $apc->get_from_version("maint-5.005",1656);
  print "not " unless $pver eq "5.005_00";
  print "ok 6\n";
  $pver = $apc->get_from_version("maint-5.6",12823);
  print "not " unless $pver eq "5.6.1";
  print "ok 7\n";
  $pver = $apc->get_from_version("perl",12823);
  print "not " unless $pver eq "5.7.2";
  print "ok 8\n";
  eval {$pver = $apc->get_from_version("perl",12822);}; # does not exist
  print "not " unless $@;
  print "ok 9\n";

  my $range;
  $range = $apc->version_range("perl",17600,17700);
  print "not " unless @$range == 2;
  print "ok 10 # [@$range]\n";
  $range = $apc->patch_range("perl",17600,17700);
  print "not " unless @$range == 73;
  print "ok 11 # [@$range]\n";

  my $closest;
  $closest = $apc->closest("perl",">",12821);
  print "not " unless $closest == 12823;
  print "ok 12 # $closest\n";
  $closest = $apc->closest("perl","<",12821);
  print "not " unless $closest == 12818;
  print "ok 13 # $closest\n";

  eval {$closest = $apc->closest("perl",">",999999990);};
  print "not " unless $@;
  print "ok 14\n";
  eval {$closest = $apc->closest("perl","<",0);};
  print "not " unless $@;
  print "ok 15\n";

  my $next;
  $next = $apc->first_in_branch("maint-5.004");
  print "not " unless $next eq "5.004_00";
  print "ok 16 # $next\n";
  $next = $apc->first_in_branch("perl");
  print "not " unless $next eq "5.004_50";
  print "ok 17 # $next\n";
  $next = $apc->next_in_branch("5.6.0");
  print "not " unless $next eq "5.7.0";
  print "ok 18 # $next\n";

  $range = $apc->patches("5.7.1");
  my $res = @$range;
  print "not " unless $res == 1820;
  print "ok 19 # $res\n"

} else {

  warn "\n\n\aSkipping tests! If you want to run the tests against your copy
  of APC, please fix variable \$REPO in t/apc.t\n\n";

  for (3..19) {
    print "ok $_\n";
  }
}
