#!/usr/bin/perl -w

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
my $savedspc = 0;
my $usedspc = 0;
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
            return unless $candstat[0] == $refstat[0]; # different file system
            return if $candstat[1] == $refstat[1];     # already same inode
            if (unlink $basename and link $first, $basename) {
              $savedspc += $refstat[7];
            } else {
              die "ERROR: first[$first]cand[$cand]![$!]";
            }
          } else {
            $MD5{$md5} = $cand;
            my $size =  -s $cand;
            warn "size undefined" unless defined $size;
            warn "usedspc undefined" unless defined $usedspc;
            $usedspc += $size;
          }
          my $uniq_files = keys %MD5;
          return if ($uniq_files % 100 || $reported{$uniq_files}++);
          my $usedspc_fmt = $usedspc;
          $usedspc_fmt =~ s/(\d)(?=(\d{3})+$)/$1_/g;
          my $savedspc_fmt = $savedspc;
          $savedspc_fmt =~ s/(\d)(?=(\d{3})+$)/$1_/g;
          printf(
                 "\runiq_files[%d]files[%d]usedspc[%s]savedspc[%s]",
                 $uniq_files,
                 $files,
                 $usedspc_fmt,
                 $savedspc_fmt
                );
        },
        no_chdir => 1,
       },
       $root
      );
  last if $Signal;
}
my $uniq_files = keys %MD5;
my $usedspc_fmt = $usedspc;
$usedspc_fmt =~ s/(\d)(?=(\d{3})+$)/$1_/g;
my $savedspc_fmt = $savedspc;
$savedspc_fmt =~ s/(\d)(?=(\d{3})+$)/$1_/g;
printf(
       "\runiq_files[%d]files[%d]usedspc[%s]savedspc[%s]",
       $uniq_files,
       $files,
       $usedspc_fmt,
       $savedspc_fmt
      );
print "\nDONE\n";

__END__

=head1 NAME

trimtrees - traverse directories, find identical files, replace with hard links

=head1 SYNOPSIS

 trimtrees.pl directory...

=head1 DESCRIPTION

Traverse all directories named on the command line, compute MD5
checksums and find files with identical MD5. IF they are equal, do a
real comparison if they are equal and if so, replace the second of two
files with a hard link to the first one.

=cut

