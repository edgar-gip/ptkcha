FIGs = $(wildcard *.fig)
EPSs = $(patsubst %.fig,%.eps,$(FIGs))

all: $(EPSs)

%.eps: %.fig
	fig2dev -Leps $< $@

clean:
	rm -f $(EPSs)