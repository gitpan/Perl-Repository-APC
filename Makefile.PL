=pod

Valuable advice from http://rgarciasuarez.free.fr/perl/svnmm.html

=cut

my $Id = q$Id: Makefile.PL 48 2003-02-25 11:45:17Z k $;

use strict;
require ExtUtils::MakeMaker;

# svn info -R | perl -0777 -ne 'use List::Util qw(max); print max(/^Last Changed Rev: (\d+)/gm), "\n"'

my $version_diff = 0;

if ($ARGV[0] eq "--setversion") {
  shift @ARGV;
  open SVN, "svn info -R |" or die;
  my $info;
  {
    local $/;
    $info = <SVN>;
    close SVN or die;
  }
  require List::Util;
  my $v = List::Util::max($info =~ /^Last Changed Rev: (\d+)/gm);
  $v /= 1000;
  $v += 1;
  open MANI, "MANIFEST" or die;
  local @ARGV;
  while (<MANI>) {
    my($f) = /^(\S+)/;
    next unless $f =~ /\.pm$/;
    push @ARGV, $f;
  }
  close MANI;
  local $^I = "~";
  warn "ARGV[@ARGV] v[$v] I[$^I]";
  while (<>) {
    if (/^our \$VERSION = '([\d\.]*)';$/) {
      my $found_version = $1 || 0;
      $version_diff++ if $found_version != $v;
      print "our \$VERSION = '$v';\n";
      next;
    }
    print;
  }
  exit unless $version_diff;
}

ExtUtils::MakeMaker::WriteMakefile(
              'NAME'	=> 'Perl::Repository::APC',
              'VERSION_FROM' => 'lib/Perl/Repository/APC.pm',
              EXE_FILES => [
                            "scripts/apc-overview",
                            "scripts/binsearchaperl",
                            "scripts/buildaperl",
                            "scripts/patchaperlup",
                            "scripts/perlpatch2svn",
                            "scripts/apc2svn",
                           ],
              'dist' => {
                         DIST_DEFAULT => 'setversion ChangeLog all tardist',
                         COMPRESS => 'gzip -9f',
                         CI => 'false',
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


sub MY::postamble {
  q{ChangeLog: Makefile
	touch $@
	chmod +w $@
	svn log -v > $@

setversion:
	$(PERL) Makefile.PL --setversion
}
}

sub MY::libscan {
    my $path = $_[1];
    return '' if $path =~ /\B\.svn\b/;
    return $path;
}
