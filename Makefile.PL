my $Id = q$Id: Makefile.PL 41 2003-02-20 10:59:16Z k $;

my($vversion);
if ($ARGV[0] eq "--verifyversion") {
  shift @ARGV;
  $vversion = shift @ARGV;
}

my $VERSION = 0;
open MAN, "MANIFEST" or die;
while (<MAN>) {
  my($f) = /^(\S+)/;
  open F, $f or next;
  while (<F>) {
    next unless /\$Id:\s+\S+\s+(\d+)\s+\d{4}-\d{2}-\d{2}\s+/;
    $VERSION = $1 if $1 > $VERSION;
    last;
  }
}
$VERSION /= 1000;
$VERSION += 1;

if ($vversion && $VERSION == $vversion) {
  exit;
}

require ExtUtils::MakeMaker;

ExtUtils::MakeMaker::WriteMakefile(
              'NAME'	=> 'Perl::Repository::APC',
              'VERSION' => $VERSION,
              EXE_FILES => [
                            "scripts/apc-overview",
                            "scripts/binsearchaperl",
                            "scripts/buildaperl",
                            "scripts/patchaperlup",
                            "scripts/perlpatch2svn",
                            "scripts/apc2svn",
                           ],
              'dist' => {
                         DIST_DEFAULT => 'myversioncheck ChangeLog all tardist',
                         COMPRESS => 'gzip -9f'
                        },
);

if ($vversion && $VERSION != $vversion) {
  die "
         VERSION $VERSION != $vversion
==> Your Makefile has been rebuilt. <==
==> Please rerun the make command.  <==
";
}

sub MY::postamble {
  q{ChangeLog: Makefile
	touch $@
	chmod +w $@
	svn log -v > $@

myversioncheck:
	$(PERL) Makefile.PL --verifyversion $(VERSION)
}
}

