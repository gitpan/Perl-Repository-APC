package Perl::Repository::APC::BAP;
use Perl::Repository::APC;

use strict;
use warnings;

my $Id = q$Id: BAP.pm 124 2003-09-14 05:12:13Z k $;
our $VERSION = sprintf "%.3f", 1 + substr(q$Rev: 124 $,4)/1000;

sub new {
  unless (@_ == 2){
    require Carp;
    Carp::croak(sprintf "Not enough arguments for %s -> new ()\n", __PACKAGE__);
  }
  my $proto   =  shift;
  my $class   =  ref $proto || $proto;

  my $apc =  shift;
  my $self;

  $self->{APC} = $apc;

  bless $self => $class;
}

sub translate {
  my($self,$branch,$ver,$lev) = @_;
  die sprintf "%s -> translate called without a branch argument", __PACKAGE__
      unless $branch;
  my($next, $this, $prev, @patches, @ver);
  my $apc = $self->{APC};
  if ($branch eq "perl") {
    $prev = "0";
  } elsif (my($bv) = $branch =~ /^maint-(.*)/) {
    # maintainance nightmare: we currently (rev 123) have no access to
    # any metadata that tell us the perl we need
    if ($bv eq "5.004") {
      $prev = "0";
    } elsif ($branch =~ /\//) { # currently only "maint-5.6/perl-5.6.2"
      if ($branch eq "maint-5.6/perl-5.6.2") {
        $prev = "5.6.1";
      } else {
        die "Illegal value for branch[$branch]"; # carp doesn't make it better
      }
    } else {
      $prev = "$bv.0"; # 5.6 -> 5.6.0 etc.
    }
  }
  @ver = $prev;
  for (
       $next = $apc->first_in_branch($branch);
       $next;
       $next = $apc->next_in_branch($next)
      ) {
    $this = $next;
    @patches = @{$apc->patches($next)};
    push @ver, $next;
    if ($lev && $lev >= $patches[0] && $lev <= $patches[-1]){
      if (defined $ver && length $ver &&
          grep { $_ eq $ver } @ver) {
        unless ($prev eq $ver){
          die "Fatal error: patch $lev is outside the patchset for $ver\n";
        }
      }
      last;
    } elsif (defined $ver && length($ver)) {
      if ($ver eq "0") {
        if ($ver[0] eq "0") {
          last;
        } else {
          die "Fatal error: 0 is not starting point for branch $branch\n";
        }
      } else {
        last if $prev && $ver eq $prev || @ver>1 && $ver eq $ver[-2];
      }
    }
    $prev = $next;
  }
  if (defined $ver && length $ver) {
    if ($ver eq "0") {
      # always OK?
    } else {
      unless (grep { $_ eq $ver } @ver){
        die "Fatal error: $ver is not part of branch $branch";
      }
    }
  } else {
    if (@ver > 1) {
      $ver = $ver[-2];
    } elsif (@ver == 1) {
      $ver = $ver[0];
      $ver =~ s/1$/0/;
    } else {
      die "Could not determine base perl version";
    }
  }
  if ($lev) {
    unless (grep { $_ eq $lev } @patches){
      my @neighbors = $self->neighbors($lev,\@patches);
      my $tellmore;
      if (@neighbors) {
        if (@neighbors == 1) {
          $tellmore = "$neighbors[0] would be";
        } else {
          $tellmore = "$neighbors[0] or $neighbors[1] would be";
        }
      } else {
        $tellmore = "Range is from $patches[0] to $patches[-1]";
      }
      die "Fatal error: patch $lev is not part of the patchset for $ver
    ($tellmore)\n";
    }
  } else {
    $lev = $patches[-1];
  }
  my $first = $patches[0];
  return ($ver,$this,$first,$lev);
}

sub neighbors {
  my($self,$x,$arr) = @_;
  return if $x < $arr->[0];
  return if $x > $arr->[-1];
  my @res;
  for my $i (0..$#$arr) {
    if ($arr->[$i] < $x) {
      $res[0] = $arr->[$i];
    } elsif ($arr->[$i] > $x) {
      $res[1] ||= $arr->[$i];
      last;
    } else {
      # must not happen
      die "Panic: neighbors called with matching element";
    }
  }
  @res;
}

1;

__END__

=head1 NAME

Perl::Repository::APC::BAP - Transform the argument to buildaperl

=head1 SYNOPSIS

  use Perl::Repository::APC::BAP;
  my $apc = Perl::Repository::APC->new("/path/to/APC");
  my $bap = Perl::Repository::APC::BAP->new($apc);
  my($version,$prev_version,$patchlevel) = $bap->transform("perl");

=head1 DESCRIPTION

The constructor new() takes a single argument, a Perl::Repository::APC
object. The resulting object has the following methods:

=over

=item * translate($branch,$version,$patch)

$branch is one of C<perl>, C<maint-5.004>, C<maint-5.005>,
C<maint-5.6>, C<maint-5.8>, or any other branch that is part of the
APC. $version is the perl version we want as a base. $patch is a patch
number that B<must> also be available in the local copy of APC.

$branch is a mandatory argument, $version and $patch can be omitted.
If $version is omitted and $patch is given, translate() finds the
proper version. If patch is omitted and $version is given, translate()
finds the most recent patch for that base. If both are omitted,
translate() finds the newest values available for both version and
patch for that branch. If both are given, translate() checks if the
values are legal and dies if they aren't.

Four values are returned: the perl version that this patch should be
leading to, the perl version we can use as a base, and the first and
the last patch number we want. Please see bap.t for examples.

=back

=head1 AUTHOR

andreas.koenig@anima.de

=head1 SEE ALSO

Perl::Repository::APC, patchaperlup, buildaperl, binsearchaperl

=cut
