#!/usr/bin/make -f

fontpath=/usr/share/fonts/truetype/malayalam
fonts=Manjari-Regular Manjari-Thin Manjari-Bold
features=features
PY=python2.7
version=0.1
buildscript=tools/build.py
default: compile
all: compile webfonts test

compile: clean
	@for font in `echo ${fonts}`;do \
		echo "Generating $$font.otf";\
		$(PY) $(buildscript) $$font.sfd $(features)/$$font.fea $(version) > /dev/null 2>&1;\
	done;

webfonts:compile
	@echo "Generating webfonts";
	@for font in `echo ${fonts}`;do \
		sfntly -w $${font}.otf $${font}.woff;\
		[ -x `which woff2_compress` ] && woff2_compress $${font}.otf;\
	done;

install: compile
	@for font in `echo ${fonts}`;do \
		install -D -m 0644 $${font}.otf ${DESTDIR}/${fontpath}/$${font}.otf;\
	done;

test: compile
# Test the fonts
	@for font in `echo ${fonts}`; do \
		echo "Testing font $${font}";\
		hb-view $${font}.otf --font-size 14 --margin 100 --line-space 1.5 --foreground=333333  --text-file tests/tests.txt --output-file tests/$${font}.pdf;\
	done;
clean:
	@rm -rf *.otf *.woff *.woff2 *.sfd-*