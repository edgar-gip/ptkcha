# Llista de Chunks

use strict;

use Symbol;
use Tk;

use Chunk;


package LlistaChunks;

# Constructor
sub new {
    my ($classe) = @_;
    
    # Es un typeglob
    my $this = Symbol::gensym();

    # A la part scalar guardarem si som clusterats
    # A la part de llista, guardarem els chunks
    # A la part haix, altra informacio
    ${*$this} = 0;
    @{*$this} = ();
    ${*$this}{'subst_id'} = 0;

    return bless($this, $classe);
}


# Netejar
sub clean {
    my ($this) = @_;

    @{*$this} = ();
}


# setClustered
sub setClustered {
    my ($this, $mode) = @_;

    ${*$this} = $mode ? 1 : 0;
}


# Renumerar els Chunks
sub renumerarChunks {
    my ($this) = @_;

    # Agafem la llista de chunks i l'ordenem
    # Comparem els indexs de l'origen
    my @nousChunks = sort {
	($a->[1][0] <=> $b->[1][0])
	    or
	($a->[1][1] <=> $b->[1][1])
	
    } grep {
	$_;
	
    } @{*$this};
    
    if (${*$this}) {
	# Mapping de clusters a subst
	my %mapping = ();
	my $nextSubst = 1;
	
	for (my $i = 0; $i < @nousChunks; ++$i) {
	    $nousChunks[$i]->[5] = $i + 1;
	    my $subst = $mapping{$nousChunks[$i]->[13]};
	    if (defined($subst)) {
		$nousChunks[$i]->[6] = $subst;
	    } else {
		$nousChunks[$i]->[6] = $nextSubst;
		$mapping{$nousChunks[$i]->[13]} = $nextSubst++;
	    }
	}

    } else {
	# Senzillament renumerem IDs
	for (my $i = 0; $i < @nousChunks; ++$i) {
	    $nousChunks[$i]->[5] = $i + 1;
	}
    }
}


# Trobar Solapament
sub trobarSolapament {
    my ($this, $iniRang, $fiRang) = @_;

    my ($solapament, $qui, $iniNou, $fiNou) = ('', -1, '', '');
    for (my $i = 0; $i < @{*$this}; ++$i) {
	my $chunk = ${*$this}[$i];
	if ($chunk) {
	    # No es un chunk esborrat
	    if (leIdx($chunk->[1], $iniRang)) {
		if (leIdx($fiRang, $chunk->[2])) {
		    # Esta inclos -> Ja podem retornar-ho
		    return ('inclusio', $chunk, $iniRang, $fiRang);

		} elsif (ltIdx($iniRang, $chunk->[2])) {
		    # Es una extensio -> Mirem que no hi hagi ja algo
		    if ($solapament) {
			return ('multiple', -1);
		    } else {
			($solapament, $qui, $iniNou, $fiNou) =
			    ('extensio', $chunk, $chunk->[1], $fiRang );
		    }
		} 
		# Si no, senzillament no té overlap 
		
	    } elsif (ltIdx($chunk->[1], $fiRang)) {
		if (ltIdx($chunk->[2], $fiRang)) {
		    # Extensio per les dues bandes
		    if ($solapament) {
			return ('multiple', -1);
		    } else {
			($solapament, $qui, $iniNou, $fiNou) =
			    ('extensio', $chunk, $iniRang, $fiRang );
		    }	
		    
		} else {
		    # Extensio per una sola banda
		    if ($solapament) {
			return ('multiple', -1);
		    } else {
			($solapament, $qui, $iniNou, $fiNou) =
			    ('extensio', $chunk, $iniRang, $chunk->[2] );
		    }	
		}
		
	    }
	    # Si no, senzillament no té overlap
	}
    }

    return ($solapament, $qui, $iniNou, $fiNou);
}


# Comparacio d'Indexos
sub ltIdx {
    my ($a, $b) = @_;
    
    return 1 if $a->[0] < $b->[0];
    return 0 if $a->[0] > $b->[0];
    return $a->[1] < $b->[1];
}


# Comparacio d'Indexos
sub leIdx {
    my ($a, $b) = @_;
    
    return 1 if $a->[0] < $b->[0];
    return 0 if $a->[0] > $b->[0];
    return $a->[1] <= $b->[1];
}


# Nou Chunk
sub newChunk {
    my ($this) = @_;

    my $freepos = 0;
    $freepos++ while ($freepos < @{*$this} && ${*$this}[$freepos]);

    ${*$this}[$freepos] = new Chunk($freepos, ${*$this}{'subst_id'}++);
    return ${*$this}[$freepos];
}


# Nou Chunk Sequencial (per a la carrega inicial)
sub newChunkSeq {
    my ($this) = @_;

    my $freepos = @{*$this};
    ${*$this}[$freepos] = new Chunk($freepos, ${*$this}{'subst_id'}++);
    return ${*$this}[$freepos];
}


# Esborrar el Chunk
sub esborrarChunk {
    my ($this, $num) = @_;

    ${*$this}[$num]->esborrar() if ${*$this}[$num];
    ${*$this}[$num] = 0;
}


# Un chunk se n'annexiona un altre
sub annexionar {
    my ($this, $menjat, $menjador, $color, $text) = @_;

    foreach my $ch (@{*$this}) {
	if ($ch &&
	    $ch->[13] == $menjat) {
	    $ch->[13] = $menjador;
	    $ch->[11] = $color;
	    $text->tagConfigure("chunk$ch->[0]",
				-background => $color);
	}
    }
}


# Get chunk
sub getChunk {
    my ($this, $idx) = @_;
    
    return ${*$this}[$idx];
}


# Get chunk
sub getChunks {
    my ($this) = @_;

    return sort { $a->[5] <=> $b->[5] } grep { $_ } @{*$this};
}


# Retornem Cert
1;
