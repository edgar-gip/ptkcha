all: fig_all ptkcha.pdf

# LaTeX
%.pdf: %.dvi
	dvipdf $<

%.dvi: %.tex
	latex $*
	bibtex $*
	latex $*
	latex $*

# Clean
clean: fig_clean
	rm -f ptkcha.aux ptkcha.bbl ptkcha.blg ptkcha.dvi ptkcha.log ptkcha.toc

# fig/ subdir
fig_all:
	$(MAKE) -C fig

fig_clean:
	$(MAKE) -C fig clean
