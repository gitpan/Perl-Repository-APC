use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
              'NAME'	=> 'Perl::Repository::APC',
              'VERSION_FROM' => 'lib/Perl/Repository/APC.pm', # finds $VERSION
              EXE_FILES => [
                            "scripts/patchaperlup",
                            "scripts/buildaperl",
                            "scripts/binsearchaperl",
                           ],
);
