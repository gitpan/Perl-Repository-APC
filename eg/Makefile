# no --remo is better default because if no new patch arrives we do
# not want to rebuild the version we have already built.

# insert the perl versions you want to mirror regularly
PERLWANTED=5.9.0 5.8.1

# add the targets you want to build regularly
all: rsync-fetch build-latest build-maint-5.8

rsync-fetch:
	for f in ${PERLWANTED} ; do \
	  rsync --delete -vaP \
          rsync://ftp.linux.activestate.com/all-of-the-APC-for-mirrors-only/$$f/diffs/ \
          APC/$$f/diffs/ ;\
	done

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

