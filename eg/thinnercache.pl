#!/usr/bin/perl -w

=pod

Schlage Perl Directories im /usr/local/ Directory zum Loeschen vor.
Based on Distance between neighbors. Born out of duenneresdone.pl

=cut

use strict;

use List::Util qw(reduce);
use File::Find;

use Getopt::Long;
our %Opt;
GetOptions(\%Opt, qw(max=i));

use Config;
my $max = 0;

my $root = shift or die "Usage: $0 directory";
die "Directory $root not found" unless -d $root;

my %no;
ENDLESS: while () {
  my @dirs;
  find(sub {
         my $mname = $File::Find::name;
         $mname =~ s|\Q$root\E||;
         $File::Find::prune++ if $mname =~ tr[/][] > 2;
         return unless /perl.+\@(\d+)/;
         push @dirs, $File::Find::name if $mname;
       }, $root);
  my %n;

  # read them and give them a value
  warn "Found ". scalar @dirs ." perls";
  for my $dirent (@dirs) {
    next unless $dirent =~ m|/perl.+\@(\d+)|;
    next if exists $no{$dirent};
    $n{$dirent} = $1;
  }

  # sort them by value
  my @n = sort { $n{$a} <=> $n{$b} } keys %n;

  # we do not want to delete first and last one
  pop @n; shift @n;

  # group them by the difference to the next lower
  my %diff;
  for my $n (1..$#n) {
    my $diff = $n{$n[$n]} - $n{$n[$n-1]};
    $max = $diff if $diff > $max;
    $diff{$diff}{$n[$n]} = undef;
  }

  my $done;
  local($|) = 1;
 OUTER: for (my $i = 0; $i <= $max; $i++) {
    $done++ if $i == $max;
    next OUTER unless exists $diff{$i};
    # for my $d (sort { $n{$a} <=> $n{$b} } keys %{$diff{$i}}) {
  INNER: for my $d (reduce { $n{$a} < $n{$b} ? $a : $b } keys %{$diff{$i}}) {
      printf "unlink %s (distance %d) [Nyq]? ", $d, $i;
      my $ans;
      if ($Opt{max}) {
        sleep 1;
        if (@dirs > $Opt{max}) {
          $ans = "y";
        } else {
          $ans = "q";
        }
        print $ans, "\n";
        sleep 1;
      } else {
        $ans = <>;
      }
      if ($ans =~ /^y/i) {
        require File::Path;
        File::Path::rmtree($d);
        # unlink "done/$d" or die "Could not unlink $d: $!";

        print "$d rmtreeed\n";
      } elsif ($ans =~ /^q/i) {
        $done++;
      } else {
        print "Nothing done.\n";
        $no{$d} = undef;
      }
      last INNER;
    }
    last OUTER;
  }

  last ENDLESS if $done;
}
