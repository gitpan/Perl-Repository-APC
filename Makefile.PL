#!perl -w -*- mode: cperl -*-

my $Id = q$Id: Makefile.PL 194 2006-02-05 23:40:23Z k $;
our $VERSION = sprintf "%.3f", 1 + substr(q$Rev: 194 $,4)/1000;

use strict;
require ExtUtils::MakeMaker;
use File::Spec;

my $version_diff = 0; # we'll have to die if this becomes true
my $version_from = File::Spec->catfile(qw(lib Perl Repository APC.pm));

if ($ARGV[0] && $ARGV[0] eq "--setversion") {
  shift @ARGV;
  open my $st, "svn st -u|" or die;
  my $dirty = 0;
  while (<$st>) {
    next if /^\?/;
    next if /^Head revision:/;
    next if /^Status against revision:/;
    print;
    $dirty++;
  }
  close $st;
  die "Not everything checked in?" if $dirty;

  # $re parses the upper boundary of the output of svnversion
  my $re = qr/(?:\d+:)?(\d+)[SM]*$/;
  my($sv_dot)  = `svnversion .`             =~ $re;
  my($sv_from) = `svn st -u -v $version_from`  =~ /^.{8}\s*(?:\d+)\s*(\d+)/;
  die "Could not determine sv_from or sv_dot"
      unless $sv_from > 0 && $sv_dot > 0;
  if ($sv_dot > $sv_from) {
    warn "setting some property to make a checkin of this file possible";
    0==system(svn => "propset",
              "cpan:release",
              "after_$sv_dot",
              $version_from) or die;
    warn "checking in to get the version up to the bleading edge";
    0==system(svn => "ci",
              "-m",
              "Property set for release after_$sv_dot",
              $version_from) or die;
    # will have to die after Makefile is rewritten:
    $version_diff = 1;
  }
  exit unless $version_diff;
}

my @exefiles;
for my $f (
           "apc-overview",
           "binsearchaperl",
           "buildaperl",
           "patchaperlup",
           "perlpatch2svn",
           "apc2svn",
          ) {
  push @exefiles, File::Spec->catfile("scripts",$f);
}

my @sign = (MM->can("signature_target") ? (SIGN => 1) : ());
ExtUtils::MakeMaker::WriteMakefile(
              'NAME'	=> 'Perl::Repository::APC',
              'VERSION_FROM' => $version_from,
              EXE_FILES => \@exefiles,
              PREREQ_PM => { "List::Util" => 0 },
              @sign,
              'dist' => {
                         DIST_DEFAULT => 'setversion README all chlog tardist',
                         COMPRESS => 'gzip -9f',
                         RCS_LABEL => '@ :',
                        },
);

if ($version_diff){
  die "
==> I had to update some \$VERSIONs <==
==> Your Makefile has been rebuilt. <==
==> Please rerun the make command.  <==
";
}

package MY;

sub postamble {
  q{setversion:
	$(PERL) Makefile.PL --setversion

chlog :: chlog-svn chlog-trad

chlog-svn :
	svn log -v https://franz.ak.mind.de/public-svn/Perl-Repository-APC > ChangeLog.svn

# got this from http://ch.tudelft.nl/~arthur/svn2cl/
chlog-trad :
	-/home/src/devel/svn/svn2cl/svn2cl-current/svn2cl.sh --strip-prefix trunk --group-by-day https://franz.ak.mind.de/public-svn/Perl-Repository-APC > ChangeLog

the-release-name :
	$(NOECHO) $(ECHO) 'version ' $(VERSION)
	$(NOECHO) $(ECHO) 'release-name ' $(DISTVNAME).tar$(SUFFIX)

release ::
	/usr/bin/perl -I../../CPAN/SVN/release-lib -S release $(DISTVNAME).tar$(SUFFIX)
	$(CP) $(DISTVNAME)/SIGNATURE ./SIGNATURE
	$(CP) $(DISTVNAME)/META.yml  ./META.yml
	rm -rf $(DISTVNAME)

}
}

sub libscan {
    my $path = $_[1];
    return '' if $path =~ /\B\.svn\b/;
    return $path;
}

sub dist_ci {
  return qq{ci :
	svn ci
};
}

# I want to keep the fresh signature here and not hidden in the
# tarball
sub dist_test {
  return q{
# if we depend on $(DISTVNAME).tar$(SUFFIX), then the rest of the
# Makefile breaks our intent to NOT remake dist
disttest :
	rm -rf $(DISTVNAME)
	tar xvzf $(DISTVNAME).tar$(SUFFIX)
	cd $(DISTVNAME) && $(ABSPERLRUN) Makefile.PL
	cd $(DISTVNAME) && $(MAKE) $(PASTHRU)
	cd $(DISTVNAME) && $(MAKE) test $(PASTHRU)

distdir ::
	$(CP) $(DISTVNAME)/SIGNATURE ./SIGNATURE
	$(CP) $(DISTVNAME)/META.yml  ./META.yml
	$(CP) $(DISTVNAME)/MANIFEST  ./MANIFEST

}
}

sub distdir {
  my $self = shift;
  my $out = $self->SUPER::distdir;
  $out =~ s/distdir :/distdir ::/g;
  return $out;
}

__END__


=head1 Valuable advice I got

http://rgarciasuarez.free.fr/perl/svnmm.html

=head1 In development

Currently I'm developing the mechanism for a convenient 'make dist'.

1. The first thing that 'make dist' has to do is making sure that
   $VERSION is right in at least one module, the VERSION_FROM module.

2. We add a target called 'setversion' to DIST_DEFAULT:

    DIST_DEFAULT => 'setversion all tardist',

3. We define the target in a postamble:

    sub MY::postamble {
      q{setversion:
            $(PERL) Makefile.PL --setversion
    }
    }

4. When the Makefile is called with --setversion, we do the following:

4.1. We verify that everything has been checked in. We allow only '?'
     in the first column of the output of 'svn st -u'. If we have
     something else, we die, halting any pending make targets.

4.2. We compare what svnversion has to say about "." and the
     VERSION_FROM module. If the upper limit of "." has a higher rev
     than the VERSION_FROM module, then we set a "cpan:release"
     property on the VERSION_FROM module and check it in. Otherwise we
     exit immediately and are done.

4.3. Then we write a new Makefile

4.4. And finally we die, so that the calling make also dies. Our
     message says, "...please rerun the make command".

5. As 'make dist' now always starts with the 'setversion' target, we
   call 'Makefile.PL --setversion' early and fail if we either have
   not checked in or our VERSION_FROM module isn't fresh enough.

6. On an immediate second call to 'make dist' the VERSION_FROM module
   is always fresh enough and the Makefile reflects the exact $VERSION
   we have in the VERSION_FROM module.


=cut


