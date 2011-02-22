all: fig_all ptkcha.ps.gz

# LaTeX
%.ps.gz: %.ps
	gzip -f $<

%.ps: %.dvi
	dvips -o $@ $<

%.dvi: %.tex
	wraplatex $<

# Clean
clean:
	rm -f ptkcha.ps.gz ptkcha.log ptkcha.dvi ptkcha.aux

# fig/ subdir
fig_all:
	cd fig; $(MAKE)

fig_clean:
	cd fig; $(MAKE) clean
