use ExtUtils::MakeMaker;

my $Id = q$Id: Makefile.PL 36 2003-02-18 10:16:01Z k $;

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

WriteMakefile(
              'NAME'	=> 'Perl::Repository::APC',
              'VERSION' => $VERSION,
              EXE_FILES => [
                            "scripts/apc-overview",
                            "scripts/binsearchaperl",
                            "scripts/buildaperl",
                            "scripts/patchaperlup",
                           ],
              'dist' => {
                         DIST_DEFAULT => 'ChangeLog all tardist',
                         COMPRESS => 'gzip -9f'
                        },
);

sub MY::postamble {
  q{ChangeLog: Makefile
	touch $@
	chmod +w $@
	svn log -v > $@
}
}

