#!perl -- -*- mode: cperl -*-

use strict;

my $REPO = $ENV{PERL_REPOSITORY_APC_REPO} || "/home/src/perl/repoperls/APC";

my $Id = q$Id: bap.t 115 2003-09-04 08:35:31Z k $;

unless (-d $REPO) {
  print "1..0 # Skipped: no repository found\n";
  exit;
}

use Perl::Repository::APC::BAP;
my $apc = Perl::Repository::APC->new($REPO);
my $bap = Perl::Repository::APC::BAP->new($apc);

my $tests = [
             [qw(perl        0@          0        5.004_50    60)],
             [qw(perl        5.004_00@   DIE                    )],
             [qw(perl        5.004_50@   5.004_50 5.004_51    98)],
             [qw(perl        5.004_57@   5.004_57 5.004_58   485)],
             [qw(perl        @60         0        5.004_50    60)],
             [qw(perl        @519        5.004_58 5.004_59   519)],
             [qw(perl        5.9.0@4677  DIE                    )],
             [qw(perl        5.6.1@18400 DIE                    )],
             [qw(perl        5.6.0@6666  5.6.0    5.7.0     6666)],
             [qw(maint-5.004 0@          0        5.004_00    32)],
             [qw(maint-5.004 5.004_00@   5.004_00 5.004_01    42)],
             [qw(maint-5.004 5.004_50@   DIE                    )],
             [qw(maint-5.004 0@          0        5.004_00    32)],
             [qw(maint-5.004 0@          0        5.004_00    32)],
             [qw(maint-5.004 0@          0        5.004_00    32)],
             [qw(maint-5.004 0@          0        5.004_00    32)],
             [qw(maint-5.6   5.6.0@      5.6.0    5.6.1     9654)],
             [qw(maint-5.6   5.6.0@7242  5.6.0    5.6.1     7242)],
            ];

print "1..", scalar @$tests, "\n";

for my $t (1..@$tests) {
  my($branch,$arg,$wrv,$wrt,$wrp) = @{$tests->[$t-1]};
  my($ver,$lev) = $arg =~ /^([^\@]*)@(\d*)$/;
  my($rv,$rt,$rfp,$rlp);
  eval {($rv,$rt,$rfp,$rlp) = $bap->translate($branch,$ver,$lev);};
  if ($@ && $wrv eq "DIE") {
    print "ok $t\n";
  } elsif ($rv eq $wrv && $rt eq $wrt && $rlp eq $wrp) {
    print "ok $t\n";
  } else {
    print "not ok $t # branch,arg,ver,lev[$branch,$arg,$ver,$lev]".
        "expected[$wrv,$wrt,$wrp]got[$rv,$rt,$rlp]\n";
  }
}

__END__

Todo: Something like

for f in 0@ 5.004_00@ 5.004_50@ 5.004_57@ @60 @519 5.9.0@4677 @ 5.6.1@18400 5.6.0@6666
do
echo INPUT: $f
./Perl-Repository-APC/scripts/buildaperl $f
done
