# no --remo is better default because if no new patch arrives we do
# not want to rebuild the version we have already built.

you-have-not-edited:
	@echo This Makefile is only a demo what can be done with an installed
	@echo Perl::Repository::APC. You are supposed to edit this Makefile to
	@echo your own needs, remove the default target, and then start to use it
	@echo in your daily work/cronjobs/whatever



# add the targets you want to build regularly
all: rsync-fetch build-latest build-maint-5.8

rsync-fetch:
	rsync --delete -vaP --include /5.8.0 \
             --include /5.8.1 \
             --include /5.9.0 \
             --include /perl-current-diffs \
             --exclude '/*' \
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

