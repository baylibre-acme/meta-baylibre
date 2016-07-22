#
# Copyright (c) BayLibre 2016
# 
# Please create a link to this file from
# the project toplevel, and invoke with
# make from there.
#
# ln -s meta-baylibre/Makefile Makefile
#


BUILD_SCRIPT := meta-baylibre/build.sh

SHELL := /bin/bash
MY_BUILDDIR ?= build
OUTDIR = $(MY_BUILDDIR)
IMAGENAME ?= baylibre-acme-image

# Set number of threads
NUM_THREADS ?= 16

.PHONY: $(MY_BUILDDIR)

COMMON_ARGS := ${BUILD_SCRIPT} \
                                -p poky/ \
                                -o meta-openembedded/ \
                                -x "kernel/.git" \
                                -j $(NUM_THREADS) \
                                -t $(NUM_THREADS) \
				-i $(IMAGENAME)

COMMON_BIN := \
                ${COMMON_ARGS} \
                -m beaglebone-acme \
                -b $(MY_BUILDDIR) \

all: sdcard

distclean:
	rm -rf $(MY_BUILDDIR)

clean:
	-@cd $(MY_BUILDDIR) && bitbake -c clean  u-boot
	-@cd $(MY_BUILDDIR) && bitbake -c clean  $(IMAGENAME)
	-@cd $(MY_BUILDDIR) && bitbake -c clean  linux-yocto-mainline
	-@cd $(MY_BUILDDIR) && bitbake -c clean  acme-utils

$(MY_BUILDDIR):
	$(COMMON_BIN)

sdcard: $(MY_BUILDDIR)
	mkdir -p $(OUTDIR)
	source poky/oe-init-build-env && bitbake -e > ../$(OUTDIR)/$(IMAGENAME).env
	source poky/oe-init-build-env && ../poky/scripts/wic create ../meta-baylibre/sdimage-bootpart.wks -e $(IMAGENAME) -o $(CURDIR)/$(OUTDIR)
