#
# Copyright (c) Stewart Whitman, 2020.
#
# File:    Makefile
# Project: Dell Wyse 5070 2nd Ethernet Adapter Adapter
# License: CC BY-NC-SA 4.0 (Attribution-NonCommercial-ShareAlike)
# Desc:    Makefile for directory 
#

OPENSCAD = openscad

SRCS = \
	commell-nic.scad \
	realtek-nic.scad \
	primitives.scad \
	smidge.scad \
	hash.scad \
	wyse-blank.scad

BUILDS = \
	wyse-ethernet.scad \
	wyse-filler.scad
 
TARGETS = $(BUILDS:.scad=.stl)

IMAGES = $(BUILDS:.scad=.png)

DEPDIR := .deps
DEPFLAGS = -d $(DEPDIR)/$*.d

COMPILE.scad = $(OPENSCAD) -o $@ $(DEPFLAGS)
RENDER.scad = $(OPENSCAD) -o $@

all: $(TARGETS)

images: $(IMAGES)

%.stl : %.scad
%.stl : %.scad $(DEPDIR)/%.d | $(DEPDIR)
	$(COMPILE.scad) $<

%.png : %.scad
	$(RENDER.scad) $<

clean:
	rm -f *.stl *.bak *.png

distclean: clean
	rm -rf $(DEPDIR)

$(DEPDIR): ; @mkdir -p $@

DEPFILES := $(TARGETS:%.stl=$(DEPDIR)/%.d)
$(DEPFILES):

include $(wildcard $(DEPFILES))
