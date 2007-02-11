# Ruuning without --remo is a good default because if no new patch
# arrives we do not want to rebuild the version we have already built.
# By not removing it, we block patchaperlup if it tries again.

# good place to change the default config as you like it:
# CONFIG=--config='-Dinstallusrbinperl=n -Uversiononly -Doptimize=-g -des -Duse64bitint -Dusedevel -Dnoextensions="Encode"'
CONFIG=--config='-Dinstallusrbinperl=n -Uversiononly -Doptimize=-g -des -Duse64bitint -Dusedevel'
# CONFIG=--config='-Dinstallusrbinperl=n -Uversiononly -des -Duse64bitint -Dusedevel'

default: all

you-have-not-edited:
	@echo This Makefile is only a demo what can be done with an installed
	@echo Perl::Repository::APC. You are supposed to edit this Makefile to
	@echo your own needs, remove the default target, and then start to use it
	@echo in your daily work/cronjobs/whatever



# add the targets you want to build regularly
all: rsync-fetch build-latest-with-modules build-maint-5.8


# --copy-links seems to be a good solution here, but in general I
# consider it a dangerous option (why? I had troubles when symlinks
# were renamed). Would be great if we could make up a solution without
# --copy-links. I had one in rev 64 but I do not remember what was
# wrong about that one.

# please study this command carefully, it's often outdated. It depends
# on decisions that are not predictable, and you may end up with an
# incomplete copy of the APC.
rsync-fetch:
	rsync --delete -vabP --include /5.8.0 \
	     --exclude changes-latest.gz \
	     --include /5.\[689\]\* \
	     --exclude '/*' \
	     --copy-links \
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
	@DATE=`date +%Y%m%dT%H%M` ; buildaperl $(CONFIG) @ > buildaperl.$$DATE.out 2>&1 && sleep 1 && perl -nle 'exec $$1, "-le", "chdir q{/home/k/sources/CPAN/SVK/trunk};do q{Makefile.PL};exec q{make}, q{megainstall}" if m|\s(/home/src/perl/repoperls/installed-perls/perl/.*/bin/perl)$$|' buildaperl.$$DATE.out ; grep '^Info:' buildaperl.$$DATE.out ; echo $$DATE
	date

build-latest-in-loop:
	while true; do $(MAKE) rsync-fetch; $(MAKE) build-latest-with-modules; sleep 5400; done

build-latest-with-remo:
	-buildaperl --remo @

build-maint-5.8:
	-buildaperl --branch maint-5.8 $(CONFIG) @

build-maint-5.6:
	-buildaperl --branch maint-5.6 $(CONFIG) @

build-maint-5.6.3:
	-buildaperl  --branch maint-5.6/perl-5.6.3 $(CONFIG) @

build-maint-5.005:
	-buildaperl --branch maint-5.005 $(CONFIG) @

build-maint-5.004:
	-buildaperl --branch maint-5.004 $(CONFIG) @

cleanup:
	perl eg/rm-rf-allbutlatest.pl
	-zsh -c 'rmdir installed-perls/*/*(/) >& /dev/null'
	perl eg/thinnercache.pl --max 1024 installed-perls/perl
	perl eg/thinnercache.pl --max 32 installed-perls/maint-5.8
	perl eg/thinnercache.pl --max 8 installed-perls/maint-5.6/perl-5.6.2
	perl eg/trimtrees.pl installed-perls
