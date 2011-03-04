all: fig_all ptkcha.ps.gz ptkcha.pdf

# LaTeX
%.pdf: %.dvi
	dvipdf $<

%.ps.gz: %.ps
	gzip -f $<

%.ps: %.dvi
	dvips -o $@ $<

%.dvi: %.tex
	wraplatex $<

# Clean
clean: fig_clean
	rm -f ptkcha.ps.gz ptkcha.log ptkcha.dvi ptkcha.aux

# fig/ subdir
fig_all:
	$(MAKE) -C fig

fig_clean:
	$(MAKE) -C fig clean
