# no --remo is better default because if no new patch arrives we do
# not want to rebuild the version we have already built.

default: all

you-have-not-edited:
	@echo This Makefile is only a demo what can be done with an installed
	@echo Perl::Repository::APC. You are supposed to edit this Makefile to
	@echo your own needs, remove the default target, and then start to use it
	@echo in your daily work/cronjobs/whatever



# add the targets you want to build regularly
all: rsync-fetch build-latest build-maint-5.8


# --copy-links seems to be a good solution here, but in general I
# consider it a dangerous option (why? I had troubles when symlinks
# were renamed). Would be great if we could make up a solution without
# --copy-links. I had one in rev 64 but I do not remember what was
# wrong about that one.
rsync-fetch:
	rsync --delete -vaP --include /5.8.0 \
	     --exclude changes-latest.gz \
	     --include /5.8.1 \
	     --include /5.9.0 \
	     --exclude '/*' \
	     --copy-links \
	 rsync://ftp.linux.activestate.com/all-of-the-APC-for-mirrors-only/ \
	 APC/

build-latest:
	-buildaperl @

build-latest-with-remo:
	-buildaperl --remo @

build-maint-5.8:
	-buildaperl --branch maint-5.8 @

build-maint-5.6:
	-buildaperl --branch maint-5.6 @

build-maint-5.005:
	-buildaperl --branch maint-5.005 @

build-maint-5.004:
	-buildaperl --branch maint-5.004 @

cleanup:
	perl eg/rm-rf-allbutlatest.pl
	perl eg/thinnercache.pl --max 70 installed-perls/perl
	perl eg/thinnercache.pl --max 10 installed-perls/maint-5.8
	perl eg/trimtrees.pl installed-perls
