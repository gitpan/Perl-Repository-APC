#!/usr/bin/perl

use warnings;
use strict;

opendir my($dh), "." or die;
my(@found, @delete, %f);

for my $dirent (readdir $dh) {
  next unless $dirent =~ m{^ perl - ([pm]) - [^@]+? @ ([\d]+) $ }x;
  $f{$1}{$2} = $dirent;
  # warn "considering dirent[$dirent]";
}
for my $k (sort keys %f) {
  my @f = sort {$a <=> $b} keys %{$f{$k}};
  # warn "k[$k]f[@f]";
  for my $k2 (0..$#f) {
    push @found, $f{$k}{$f[$k2]};
    push @delete, $f{$k}{$f[$k2]} if $k2 < $#f;
  }
}
print "found[@found]\n";
print @delete ? "delete[@delete]\n" : "nothing to delete\n";

use File::Find;

if (@delete) {
  find({
        wanted => sub {
          lstat;
          if (-l _) {
            unlink $_;
          } elsif (-d _) {
            rmdir $_;
            print "rm $File::Find::name\n";
          } elsif (-f _) {
            unlink $_;
          }
        },
        bydepth => 1,
       }, @delete);
  rmdir $_ for @delete;
}
