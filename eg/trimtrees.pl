#!/usr/bin/perl -w

# 2002-10-01: free space on /usr/local: before: 759184 kB, after: 5155980

# a few changes while it was running, so no guarantee, it still works

use strict;
use Digest::MD5 qw(md5);
use File::Find;
use File::Compare qw(compare);
use Cwd;

my @dirs = @ARGV or die "Usage: $0 directories";
our $Signal = 0;
$SIG{INT} = sub {
  warn "Caught SIGINT; please stand by, I'm leaving as soon as possible...\n";
  $Signal++;
};


undef $/;
our %MD5;
my %reported;
my $files = 0;
my $dirs = @dirs;
my $savedspace = 0;
my $usedspace = 0;
my $WD = Cwd::cwd;
$| = 1;
for my $diri (0..$#dirs) {
  my $root = $dirs[$diri];
  find(
       {
        wanted => sub {
          if ($Signal){
            $File::Find::prune = 1;
            return;
          }
          return unless -f;
          my $basename = $_;
          open my $fh, "<", $basename;
          my $data = <$fh>;
          my $md5 = md5 $data;
          $files++;
          my $cand = $File::Find::name;
          if (my $first = $MD5{$md5}) {
            $first = File::Spec->file_name_is_absolute($first) ?
                $first : File::Spec->catfile($WD, $first);
            my(@refstat) = stat($first);
            die "illegal refstat[@refstat]first[$first]" unless $refstat[1];
            die "Sensation, $first and $cand are not equal with same MD5"
                if compare $first, $basename;
            my(@candstat) = stat($basename);
            return if $candstat[1] == $refstat[1];
            if (unlink $basename and link $first, $basename) {
              $savedspace += $refstat[7];
              # my $savedspace_fmt = $savedspace;
              # $savedspace_fmt =~ s/(\d)(?=(\d{3})+$)/$1_/g;
              # print "\rLN: $first -> $cand size[$refstat[7]]savedspace[$savedspace_fmt]";
            } else {
              die "ERROR: first[$first]cand[$cand]![$!]";
            }
          } else {
            $MD5{$md5} = $cand;
            my $size =  -s $cand;
            warn "size undefined" unless defined $size;
            warn "usedspace undefined" unless defined $usedspace;
            $usedspace += $size;
          }
          my $keys = keys %MD5;
          return if ($keys % 100 || $reported{$keys}++);
          my $usedspace_fmt = $usedspace;
          $usedspace_fmt =~ s/(\d)(?=(\d{3})+$)/$1_/g;
          my $savedspace_fmt = $savedspace;
          $savedspace_fmt =~ s/(\d)(?=(\d{3})+$)/$1_/g;
          print "\rkeys[$keys]files[$files]usedspace[$usedspace_fmt]savedspace[$savedspace_fmt]";
        },
        no_chdir => 1,
       },
       $root
      );
  last if $Signal;
}
my $keys = keys %MD5;
my $usedspace_fmt = $usedspace;
$usedspace_fmt =~ s/(\d)(?=(\d{3})+$)/$1_/g;
my $savedspace_fmt = $savedspace;
$savedspace_fmt =~ s/(\d)(?=(\d{3})+$)/$1_/g;
print "\rkeys[$keys]files[$files]usedspace[$usedspace_fmt]savedspace[$savedspace_fmt]\nDONE\n";
