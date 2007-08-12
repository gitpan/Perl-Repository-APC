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
my %never_delete = map { $_ => undef }
    (
     18352, # 5.008
     20002, # 5.009, easy to remember and well populated
     20939, # 5.008001
     21727, # 5.006001, Module::CoreList::patchlevel for 5.6.2 built
            # with 'buildaperl --branch maint-5.6/perl-5.6.2 @21727'
     22491, # 5.009001
     22552, # 5.008003 THREAD
     23004, # 5.008004 THREAD
     23023, # 5.009002, easy to remember and well populated
     23390, # 5.008005 THREAD
     24448, # 5.008006 THREAD
     26876, # 5.008007 THREAD
     27002, # 5.009003
     28966, # 5.009004
     31162, # 5.008008, my maint 5.8 installation under which I run Jifty
     31223, # 5.008008 THREAD

     16904,16905, # Locale::TextDomain
     17724,17725, # pseudo hashes
     20556,20559, # DBI 1.58 (was a bug in perl)
     22314,22315, # B::Generate 1.06
     22739,22741, # Devel::Profile 1.05
     22841,22842, # Encode::IMAPUTF7
     23767,23768, # Readonly::XS
     23963,23964, # Hatena::Keyword
     24009,24010, # Unicode::RecursiveDowngrade
     24541,24542, # Math::Pari
     24659,24660, # Class::constr
     25805,25808, # Text::Query
     26369,26370, # Class::MOP 0.40
     26454,26465, # Term::ReadPassword 0.07 (proxysubs; No useable patch between)
     26486,26487, # Class::MOP ???
     27263,27264, # JSON 1.12
     28358,28359, # encoding::source
     29025,29026, # DBIx::Class
     29317,29318, # String::Multibyte
     30487,30488, # Devel::Cover 0.61
     30677,30678, # TAP::Parser 0.52
     30979,30980, # mro, Best 0.11
     31025,31027, # Regexp::Assemble
     31251,31252, # Data::Alias,Devel::EvalContext
    );
ENDLESS: while () {
  my @dirs;
  find(sub {
         my $mname = $File::Find::name;
         $mname =~ s|\Q$root\E||;
         $File::Find::prune++ if $mname =~ tr[/][] > 2;
         return unless /perl.+\@(\d+)/;
         my $patch = $1;
         return if exists $never_delete{$patch};
         push @dirs, $File::Find::name if $mname;
       }, $root);
  my %n;

  # read them and give them a value
  warn "Found ". scalar @dirs ." deleteable perls";
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
        File::Path::rmtree($d) or die "Could not remove $d";
        if (-d $d) {
          die "ALERT: rmtree did not remove $d";
        } else {
          print "$d rmtreeed\n";
        }
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
