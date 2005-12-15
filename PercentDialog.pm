# Dialeg amb els Tants Per Cent i Llegenda

use strict;

use Tk;
use Tk::TixGrid;
use Tk::ItemStyle;

use Forwarder;

package PercentDialog;


our @ISA = qw( Forwarder );

# Constructor
sub new {
    my ($classe, $main, $pare) = @_;

    my $win = $pare->Toplevel(-title => "Chart");

    # Creem la interfice
    my $etiqueta = $win->Label(-text => '<Globals>')
	->pack(-side => 'top', -fill => 'x');
    my $grid = $win->Scrolled('TixGrid', -scrollbars => 'e')
	->pack(-side => 'bottom', -fill => 'both', -expand => 1)
	->Subwidget('scrolled');
    my $stylCap = $grid->ItemStyle('text',
				   -background => 'grey',
				   -foreground => 'black');
    $grid->set(0, 0, -itemtype => 'text', -text => 'Value', -style => $stylCap);
    $grid->set(1, 0, -itemtype => 'text', -text => 'Chunks', -style => $stylCap);
    $grid->sizeColumn(1, -size => 100);
    $grid->set(2, 0, -itemtype => 'text', -text => '#Words', -style => $stylCap);
    $grid->sizeColumn(2, -size => 125);
    $grid->set(3, 0, -itemtype => 'text', -text => '%', -style => $stylCap);
    $grid->sizeColumn(3, -size => 150);

    # L'agrupem amb son pare
    $win->group($pare);

    my $this = [ $win, $main, $grid, $stylCap, 0, -2, $etiqueta ];
    return bless($this, $classe);
}


# Mostrar Atributs
sub mostrarAtribut {
    my ($this, $nAtribut) = @_;

    # Si no cal redibuixar, no ho fem...
    if ($nAtribut == $this->[5]) {
	$this->updateAtribut(0);

    } else {
	$this->[5] = $nAtribut;
	$this->updateAtribut(1);
    }
}


# Actualitzar
sub updateAtribut {
    my ($this, $neteja) = @_;
    my $nAtribut = $this->[5];

    # Netegem si cal
    $this->[2]->deleteRow(1, $this->[4]) if $neteja && $this->[4];

    # Marcatge
    my $marcatge = $this->[1]->getProjecte()->getMarcatge();
    
    # Actualitzem
    if ($nAtribut != -1) {
	# Comptem els chunks
	my ($totalMots, $totalChunks, $mots, $chunks) =
	    $this->comptarChunksAtrib($nAtribut, $marcatge->isClustered());

	# Mots totals
	my $docMots = $this->[1]->getMotsDocument();
	
	# Obtenim els noms dels Atributs
	my $atribut  = $marcatge->getAtributs()->[$nAtribut];

	# Nom de l'atribut
	$this->[6]->configure(-text => $atribut->[0]) if $neteja;
	
	# Per a cada valor...
	my $i;
	for ($i = 1; $i < @{$atribut}; ++$i) {
	    # Posem l'etiqueta si cal netejar
	    if ($neteja) {
		my $color = $marcatge->colorAtribut($nAtribut, $atribut->[$i]);
		my $stylPropi = $this->[2]->ItemStyle('text',
						      -foreground => $color);
		$this->[2]->set(0, $i, -itemtype => 'text',
				-text => $atribut->[$i], -style => $stylPropi);
	    }

	    if ($marcatge->isClustered()) {
		# Hem de posar les barres
		my ($tmpC, $tmpM);
		$tmpC = $chunks->{$atribut->[$i]};
		$tmpM = $mots->{$atribut->[$i]};
		
		$this->[2]->set(1, $i, -itemtype => 'text',
				-text => "$tmpC->[0] ($tmpC->[1])",
				-style => $this->[3]);
		$this->[2]->set(2, $i, -itemtype => 'text',
				-text => "$tmpM->[0] ($tmpM->[1]/$tmpM->[2])",
				-style => $this->[3]);
		my @pcnt = map { pasento($_, $docMots) } @{$tmpM};
		$this->[2]->set(3, $i, -itemtype => 'text',
				-text => "$pcnt[0] ($pcnt[1]/$pcnt[2]) %",
				-style => $this->[3]);
		
	    } else {
		# Directament
		$this->[2]->set(1, $i, -itemtype => 'text',
				-text => $chunks->{$atribut->[$i]},
				-style => $this->[3]);
		$this->[2]->set(2, $i, -itemtype => 'text',
				-text => $mots->{$atribut->[$i]},
				-style => $this->[3]);
		my $pcnt = pasento($mots->{$atribut->[$i]}, $docMots);
		$this->[2]->set(3, $i, -itemtype => 'text',
				-text => "$pcnt %",
				-style => $this->[3]);
	    }
	}

	# El darrer
	$this->[2]->set(0, $i, -itemtype => 'text',
			-text => 'TOTAL', -style => $this->[3]) if $neteja;

	if ($marcatge->isClustered()) {
	    # Posem barres
	    $this->[2]->set(1, $i, -itemtype => 'text',
			    -text => "$totalChunks->[0] ($totalChunks->[1])",
			    -style => $this->[3]);
	    $this->[2]->set(2, $i, -itemtype => 'text',
			    -text => "$totalMots->[0] ($totalMots->[1]/$totalMots->[2])",
			    -style => $this->[3]);
	    my @pcnt = map { pasento($_, $docMots) } @{$totalMots};
	    $this->[2]->set(3, $i, -itemtype => 'text',
			    -text => "$pcnt[0] ($pcnt[1]/$pcnt[2]) %",
			    -style => $this->[3]);

	} else {
	    # Directament
	    $this->[2]->set(1, $i, -itemtype => 'text',
			    -text => $totalChunks,
			    -style => $this->[3]);
	    $this->[2]->set(2, $i, -itemtype => 'text',
			    -text => $totalMots,
			    -style => $this->[3]);
	    my $pcnt = pasento($totalMots, $docMots);
	    $this->[2]->set(3, $i, -itemtype => 'text',
			    -text => "$pcnt %",
			    -style => $this->[3]);
	}

	$this->[4] = $i;
	
    } else { # nAtribut == -1
	# Comptem els chunks
	my ($totalMots, $totalChunks)
	    = $this->comptarChunks($marcatge->isClustered());
    
	# Mots totals
	my $docMots = $this->[1]->getMotsDocument();
	
	# Etiquetes
	if ($neteja) {
	    $this->[6]->configure(-text => '<Globals>');
	    $this->[2]->set(0, 1, -itemtype => 'text',
			    -text => 'MARCAT', -style => $this->[3]);
	}

	if ($marcatge->isClustered()) {
	    $this->[2]->set(1, 1, -itemtype => 'text',
			    -text => "$totalChunks->[0] ($totalChunks->[1])",
			    -style => $this->[3]);
	    $this->[2]->set(2, 1, -itemtype => 'text',
			    -text => "$totalMots->[0] ($totalMots->[1]/$totalMots->[2])",
			    -style => $this->[3]);
	    my @pcnt = map { pasento($_, $docMots) } @{$totalMots};
	    $this->[2]->set(3, 1, -itemtype => 'text',
			    -text => "$pcnt[0] ($pcnt[1]/$pcnt[2]) %",
			    -style => $this->[3]);
	    
	    $this->[4] = 1;

	} else {
	    $this->[2]->set(1, 1, -itemtype => 'text',
			    -text => $totalChunks,
			    -style => $this->[3]);
	    $this->[2]->set(2, 1, -itemtype => 'text',
			    -text => $totalMots,
			    -style => $this->[3]);
	    my $pcnt = pasento($totalMots, $docMots);
	    $this->[2]->set(3, 1, -itemtype => 'text',
			    -text => "$pcnt %",
			    -style => $this->[3]);
	    
	    $this->[4] = 1;
	}
    }
}
 

sub comptarChunks {
    my ($this, $isClustered) = @_;

    if ($isClustered) {
	my @totalMots = (0, 0, 0);
	my @totalChunks = (0, 0);

	my %substs = ();
	foreach my $ch ($this->[1]->getChunks()) {
	    # Fins aqui igual
	    my $mots = $ch->getNWords();
	    $totalMots[0] += $ch->getNWords();
	    ++$totalChunks[0];

	    # Obtenim el subst
	    my $subst = $ch->getSubst();
	    if (!exists($substs{$subst})) {
		# Nou
		$substs{$subst} = [ $mots, $mots ];
		++$totalChunks[1];
	    } elsif ($mots < $substs{$subst}->[0]) {
		$substs{$subst}->[0] = $mots;
	    } elsif ($mots > $substs{$subst}->[1]) {
		$substs{$subst}->[1] = $mots;
	    }
	}
	
	# Sumem tots els substs
	while(my ($k, $v) = each(%substs)) {
	    # print "$k $v->[0] $v->[1]\n";
	    $totalMots[1] += $v->[0];
	    $totalMots[2] += $v->[1];
	}

	return (\@totalMots, \@totalChunks);

    } else {
	my $totalMots = 0;
	my $totalChunks = 0;
	foreach my $ch ($this->[1]->getChunks()) {
	    $totalMots += $ch->getNWords();
	    ++$totalChunks;
	}

	return ($totalMots, $totalChunks);
    }
}


sub comptarChunksAtrib {
    my ($this, $nAtribut, $isClustered) = @_;

    # Comptem els chunks
    my %mots = ();
    my %chunks = ();
    
    if ($isClustered) {
	my @totalMots = (0, 0, 0);
	my @totalChunks = (0, 0);

	my %substs = ();
	foreach my $ch ($this->[1]->getChunks()) {
	    # Fins aqui igual
	    my $atrib = $ch->getAtributs()->[$nAtribut];
	    my $nmots = $ch->getNWords();

	    # Augmentem els mots
	    $mots{$atrib}->[0] += $nmots;
	    $totalMots[0] += $nmots;

	    # Augmentem els chunks
	    ++$chunks{$atrib}->[0];
	    ++$totalChunks[0];

	    # Obtenim el subst
	    my $subst = $ch->getSubst();
	    if (!exists($substs{$atrib}->{$subst})) {
		# Nou
		$substs{$atrib}->{$subst} = [ $nmots, $nmots ];
		++$chunks{$atrib}->[1];
		++$totalChunks[1];
	    } elsif ($nmots < $substs{$atrib}->{$subst}[0]) {
		$substs{$atrib}->{$subst}[0] = $nmots;
	    } elsif ($nmots > $substs{$atrib}->{$subst}[1]) {
		$substs{$atrib}->{$subst}[1] = $nmots;
	    }
	}
	
	# Sumem tots els substs
	while(my ($atrib, $h) = each(%substs)) {
	    while(my ($k, $v) = each(%{$h})) {
		# print "$k $v->[0] $v->[1]\n";
		$totalMots[1] += $v->[0];
		$totalMots[2] += $v->[1];

		$mots{$atrib}->[1] += $v->[0];
		$mots{$atrib}->[2] += $v->[1];
	    }
	}
	return (\@totalMots, \@totalChunks, \%mots, \%chunks);

    } else {
	
	my $totalMots = 0;
	my $totalChunks = 0;
	foreach my $ch ($this->[1]->getChunks()) {
	    $mots{$ch->getAtributs()->[$nAtribut]} += $ch->getNWords();
	    $totalMots += $ch->getNWords();
	    ++$chunks{$ch->getAtributs()->[$nAtribut]};
	    ++$totalChunks;
	}

	return ($totalMots, $totalChunks, \%mots, \%chunks);
    }
}


# Percent
sub pasento {
    return int($_[0] * 10000 / $_[1]) / 100 if $_[1];
    return '-';
}


# Retornem Cert

1;

