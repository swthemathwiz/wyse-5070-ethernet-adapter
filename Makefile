#
# Copyright (c) Stewart Whitman, 2020-2021.
#
# File:    Makefile
# Project: Dell Wyse 5070 2nd Ethernet Adapter Adapter
# License: CC BY-NC-SA 4.0 (Attribution-NonCommercial-ShareAlike)
# Desc:    Makefile for directory
#

NAME = wyse-5070-ethernet-adapter

OPENSCAD = openscad

SRCS = \
	commell-nic.scad \
	realtek-nic.scad \
	winyao-nic.scad \
	primitives.scad \
	smidge.scad \
	hash.scad \
	wyse-blank.scad \
	wyse-ethernet.scad

BUILDS = \
	wyse-commell-adapter.scad \
	wyse-winyao-adapter.scad \
	wyse-realtek-adapter.scad \
	wyse-filler.scad

EXTRAS = \
	Makefile \
	README.md \
	LICENSE.txt \

TARGETS = $(BUILDS:.scad=.stl)
IMAGES = $(BUILDS:.scad=.png)
ICONS = $(BUILDS:.scad=.icon.png)

DEPDIR := .deps
DEPFLAGS = -d $(DEPDIR)/$*.d

COMPILE.scad = $(OPENSCAD) -o $@ $(DEPFLAGS)
RENDER.scad = $(OPENSCAD) -o $@ --render --colorscheme=Tomorrow
RENDERICON.scad = $(RENDER.scad) --imgsize=128,128

.PHONY: all images icons clean distclean

all: $(TARGETS)

images: $(IMAGES)

icons : $(ICONS)

%.stl : %.scad
%.stl : %.scad $(DEPDIR)/%.d | $(DEPDIR)
	$(COMPILE.scad) $<

%.png : %.scad
	$(RENDER.scad) $<

%.icon.png : %.scad
	$(RENDERICON.scad) $<

clean:
	rm -f *.stl *.bak *.png

distclean: clean
	rm -rf $(DEPDIR)

$(DEPDIR): ; @mkdir -p $@

DEPFILES := $(TARGETS:%.stl=$(DEPDIR)/%.d)
$(DEPFILES):

include $(wildcard $(DEPFILES))
