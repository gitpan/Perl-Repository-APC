package Perl::Repository::APC::BAP;
use Perl::Repository::APC;

use strict;
use warnings;

my $Id = q$Id: APC.pm 19 2003-02-15 09:58:55Z k $;
our $VERSION = '1.046';

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
  my($next, $this, $last, @patches, @ver);
  my $apc = $self->{APC};
  if ($branch eq "perl") {
    $last = "0";
  } elsif (my($bv) = $branch =~ /^maint-(.*)/) {
    if ($bv eq "5.004") {
      $last = "0"
    } else {
      $last = "$bv.0";
    }
  }
  @ver = $last;
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
        die "Fatal error: patch $lev is outside the patchset for $ver\n"
            unless $last eq $ver;
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
        last if $last && $ver eq $last || @ver>1 && $ver eq $ver[-2];
      }
    }
    $last = $next;
  }
  if (defined $ver && length $ver) {
    if ($ver eq "0") {
      # always OK?
    } else {
      die "Fatal error: $ver is not part of branch $branch"
          unless grep { $_ eq $ver } @ver;
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
    die "Fatal error: patch $lev is not part of the patchset for $ver\n"
        unless grep { $_ eq $lev } @patches;
  } else {
    $lev = $patches[-1];
  }
  my $first = $patches[0];
  return ($ver,$this,$first,$lev);
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

Three values are returned: the perl version that this patch should be
leading to, the perl version we can use as a base, and the patch
number we want. Please see bap.t for examples.

=back

=head1 AUTHOR

andreas.koenig@anima.de

=head1 SEE ALSO

Perl::Repository::APC, patchaperlup, buildaperl, binsearchaperl

=cut
