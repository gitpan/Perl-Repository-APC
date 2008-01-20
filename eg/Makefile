# Ruuning without --remo is a good default because if no new patch
# arrives we do not want to rebuild the version we have already built.
# By not removing it, we block patchaperlup if it tries again.

# Set the default config:
CONFIG=--config='-Dinstallusrbinperl=n -Uversiononly -Dusedevel -des  -Ui_db                                         '
# CONFIG=--config='-Dinstallusrbinperl=n -Uversiononly -Dusedevel -des  -Ui_db                            -Duse64bitint'
# CONFIG=--config='-Dinstallusrbinperl=n -Uversiononly -Dusedevel -des  -Ui_db              -Doptimize=-g              '
# CONFIG=--config='-Dinstallusrbinperl=n -Uversiononly -Dusedevel -des  -Ui_db              -Doptimize=-g -Duse64bitint'
# CONFIG=--config='-Dinstallusrbinperl=n -Uversiononly -Dusedevel -des  -Ui_db -Dusethreads                            '
# CONFIG=--config='-Dinstallusrbinperl=n -Uversiononly -Dusedevel -des  -Ui_db -Dusethreads               -Duse64bitint'
# CONFIG=--config='-Dinstallusrbinperl=n -Uversiononly -Dusedevel -des  -Ui_db -Dusethreads -Doptimize=-g              '
# CONFIG=--config='-Dinstallusrbinperl=n -Uversiononly -Dusedevel -des  -Ui_db -Dusethreads -Doptimize=-g -Duse64bitint'

# ATTN: relocateableinc does not work with mod_perl 1.30 (RT #30300)
# CONFIG=--config='-Dinstallusrbinperl=n -Uversiononly -Dusedevel -des -Duse64bitint -Duserelocatableinc                           '
# CONFIG=--config='-Dinstallusrbinperl=n -Uversiononly -Dusedevel -des -Duse64bitint -Duserelocatableinc               -Dusethreads'
# CONFIG=--config='-Dinstallusrbinperl=n -Uversiononly -Dusedevel -des -Duse64bitint -Duserelocatableinc -Doptimize=-g             '
# CONFIG=--config='-Dinstallusrbinperl=n -Uversiononly -Dusedevel -des -Duse64bitint -Duserelocatableinc -Doptimize=-g -Dusethreads'

# CONFIG=--config='-Dinstallusrbinperl=n -Uversiononly -Dusedevel -des -Duse64bitint -Doptimize=-g                 -Dnoextensions="Encode"'

PATCHLEVEL=999999

default: all

you-have-not-edited:
	@echo This Makefile is only a demo what can be done with an installed
	@echo Perl::Repository::APC. You are supposed to edit this Makefile to
	@echo your own needs, remove the default target, and then start to use it
	@echo in your daily work/cronjobs/whatever



# add the targets you want to build regularly
all: rsync-fetch build-latest-with-modules build-maint-5.8


# please study this command carefully, it's often outdated. It depends
# on decisions that are not predictable, and you may end up with an
# incomplete copy of the APC.
rsync-fetch:
	rsync --delete -vabP --include /5.8.0 \
	     --exclude changes-latest.gz \
	     --include /5.\[689\]\* \
	     --include /perl-\*-diffs \
	     --exclude '/*' \
	 rsync://public.activestate.com/all-of-the-APC-for-mirrors-only/ \
	 APC/

rsync-fetch-perl-current-directory:
	rsync --delete -vabP \
	 rsync://public.activestate.com/all-of-the-APC-for-mirrors-only/perl-current/ \
	 APC/perl-current/

rsync-fetch-perl-current-dot-patch-file:
	rsync -vb \
	 rsync://public.activestate.com/all-of-the-APC-for-mirrors-only/perl-current/.patch \
	 APC/perl-current/

what-is-current-patchlevel: rsync-fetch-perl-current-dot-patch-file
	cat APC/perl-current/.patch

build-latest:
	-buildaperl $(CONFIG) @

# %FT%T is shorter but has the colons
build-latest-with-modules:
	date
	@DATE=`date +%Y%m%dT%H%M` ; echo $$DATE; buildaperl $(CONFIG) @ > logs/buildaperl.$$DATE.out 2>&1 && sleep 1 && perl -nle 'exec $$1, "-le", "chdir q{/home/sand/CPAN-SVN};do q{Makefile.PL};exec q{make}, q{megainstall}" if m|\s(/home/src/perl/repoperls/installed-perls/perl/.*/bin/perl)$$|' logs/buildaperl.$$DATE.out ; grep '^Info:' logs/buildaperl.$$DATE.out ; echo $$DATE
	date

build-maint-5.8-with-modules:
	date
	@DATE=`date +%Y%m%dT%H%M` ; buildaperl --writedotpatch --branch maint-5.8 $(CONFIG) @ > logs/buildaperl.$$DATE.out 2>&1 && sleep 1 && perl -nle 'exec $$1, "-le", "chdir q{/home/sand/CPAN-SVN};do q{Makefile.PL};exec q{make}, q{megainstall}" if m!\s(/home/src/perl/repoperls/installed-perls/(?:perl|maint-5.8)/.*/bin/perl)$$!' logs/buildaperl.$$DATE.out ; grep '^Info:' logs/buildaperl.$$DATE.out ; echo $$DATE
	date

build-latest-in-loop:
	while true; do $(MAKE) rsync-fetch; $(MAKE) build-latest-with-modules; $(MAKE) sleep; done

sleep:
	sleep `expr 2 '*' 3600`

build-latest-with-remo:
	-buildaperl --remo @

build-maint-5.8:
	-buildaperl --branch maint-5.8 $(CONFIG) @

build-maint-5.6:
	-buildaperl --branch maint-5.6 $(CONFIG) @

build-maint-5.6.3:
	-buildaperl --branch maint-5.6/perl-5.6.3 $(CONFIG) @

build-maint-5.005:
	-buildaperl --branch maint-5.005 $(CONFIG) @

build-maint-5.004:
	-buildaperl --branch maint-5.004 $(CONFIG) @

build-custom-blead:
	@echo PATCHLEVEL=$(PATCHLEVEL)
	-buildaperl $(CONFIG) @$(PATCHLEVEL)

cleanup:
	perl eg/rm-rf-allbutlatest.pl
	-zsh -c 'rmdir installed-perls/*/*(/) >& /dev/null'
	perl eg/thinnercache.pl installed-perls/perl
	perl eg/thinnercache.pl --max 64 installed-perls/maint-5.8
	perl eg/thinnercache.pl --max 8 installed-perls/maint-5.6/perl-5.6.2
	: considered harmful: perl eg/trimtrees.pl --maxlinks=1 installed-perls
