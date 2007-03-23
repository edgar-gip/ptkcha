# Copyright (C)  Edgar Gonzàlez i Pellicer
#
# This file is part of PTkChA
#  
# PTkChA is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software 
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

# Chunk

use strict;

use Interficie;

package Chunk;

# Colors
our @colors = ( 'red', 'orange', 'darkgreen',
		'navy', 'maroon', 'magenta', 'dark gray',
		'salmon', 'gold', 'gray', 'lime green',
		'orchid', 'tomato', 'black',
		'olive drab', 'tan', 'medium blue' );

# Atributs
# 0: FreePos
# 1: [ Index Inici ]
# 2: [ Index Final ]
# 3: Index Inici
# 4: Index Final
# 5: Id
# 6: Subst
# 7: Atributs
# 8: Relacions Entrants
# 9: Relacions Sortints
# 10:Relacions Bidireccionals
# 11:Color
# 12:nWords
# 13:internalSubst

sub new {
    my ($classe, $freepos, $intSubst) = @_;

    my $this = [ $freepos, undef, undef, undef, undef,
		 undef, undef, [], [], [],
		 [], undef, 0, $intSubst ];

    return bless($this, $classe);
}


# Consultores
sub getPos           { return $_[0]->[0]; }
sub getStart         { return $_[0]->[3]; }
sub getRange         { return ($_[0]->[3], $_[0]->[4]); }
sub getId            { return $_[0]->[5]; }
sub getSubst         { return $_[0]->[6]; }
sub getAtributs      { return $_[0]->[7]; }
sub getEntrants      { return $_[0]->[8]; }
sub getSortints      { return $_[0]->[9]; }
sub getBidireccionals{ return $_[0]->[10];}
sub getColor         { return $_[0]->[11];}
sub getNWords        { return $_[0]->[12];}
sub getInternalSubst { return $_[0]->[13];}


# Assignar un Rang
sub assignarRang {
    my ($this, $text, @rang) = @_;

    # Obtenim el rang del Tag
    my @idx1 = split(/\./, $rang[0]);
    my @idx2 = split(/\./, $rang[1]);

    @{$this}[1..4] = ( \@idx1, \@idx2, $rang[0], $rang[1] );

    # Calculem de pas el nombre de mots
    $this->[12] = 0;
    foreach my $mot (split(/ /, $text)) {
	++$this->[12] if $mot;
    }
}


# Assignar Atributs
sub assignarAtributs {
    my ($this, $atributs, $marcatge, $substos, $hashIds) = @_;

    # Anem recorrent
    while (my ($clau, $valor) = each(%{$atributs})) {
	if ($clau eq 'id') {
	    # Id, el guardem per a les relacions
	    $this->[5] = $valor;
	    $hashIds->{$valor} = $this;

	} elsif ($clau eq 'subst') {
	    # Som clusterats ?
	    next unless $marcatge->isClustered();

	    # Informacio del subst
	    if (exists($substos->[$valor])) {
		# Es un antic
		my $chunkRef = $substos->[$valor];
		
		$this->[13] = $chunkRef->[13];
		$this->[11] = $chunkRef->[11];
		
	    } else {
		# El meu color
		$this->[11] = $colors[$this->[0] % @colors];
		
		# L'assignem com a representant
		$substos->[$valor] = $this;
	    }
	    
	} else { # Altres atributs
	    my $idx = $marcatge->findAtribut($clau);
	    $this->[7][$idx] = $valor if defined($idx);
	}
    }

    # Si no hem assignat color, l'hi posem
    $this->[11] = $colors[$this->[0] % @colors] unless $this->[11];
}


# Construir Pendents
sub construirPendents {
    my ($this, $relacions, $marcatge, $hashRef) = @_;

    return unless $relacions;
    
    # Ens saltem els atributs del tag <rels>
    shift(@{$relacions});
    
    while (@{$relacions}) {
	my ($tag, $info) = (shift(@{$relacions}), shift(@{$relacions}));
	if ($tag eq 'rel') {
	    my $tipus = $info->[0]{'tipus'} || $info->[0]{'type'};
	    my $desti = $info->[0]{'desti'} || $info->[0]{'target'};
	    
	    my $numRel = $marcatge->findRelacio($tipus);
	    if (defined($numRel)) {
		my $stereo = $marcatge->getRelacio($numRel)->[1];
		if ($stereo eq 'uni') {
		    push(@{$hashRef->{$this->[5]}[1]}, $tipus, $desti);
		    push(@{$hashRef->{$desti}[0]}, $tipus, $this);

		} else {
		    push(@{$hashRef->{$this->[5]}[2]}, $tipus, $desti);
		    # L'altre sentit ja ho farà
		}
	    }
	}
    }
}


# Assignar relacions
sub assignarRelacions {
    my ($this, $pendents, $hashIds) = @_;

    # Assignem les que estaven pendents
    push(@{$this->[8]}, @{$pendents->[0]}) if $pendents->[0];
    push(@{$this->[9]}, @{$pendents->[1]}) if $pendents->[1];
    push(@{$this->[10]},@{$pendents->[2]}) if $pendents->[2];
}


# Atributs per defecte
sub atributsPerDefecte {
    my ($this, $defaultWin) = @_;

    # Posem els valors
    push(@{$this->[7]}, $defaultWin->getAllValors());

    # Assignem el color
    $this->[11] = $colors[$this->[0] % @colors];	
}


# set Atrib
sub setAtrib {
    my ($this, $num, $valor) = @_;

    $this->[7][$num] = $valor;
    
    # Indiquem a la interficie que ens hem modificat
    $Interficie::singleton->setModificat();
}


# Afegir una relacio
sub addRel {
    my ($this, $nom, $ste, $desti) = @_;

    if ($ste eq 'uni') {
	# Comprovem que no hi sigui ja
	for (my $i = 0; $i < @{$this->[9]}; $i += 2) {
	    return if $this->[9][$i] eq $nom
		&& $this->[9][$i + 1] eq $desti;
	}

	# No hi era...
	push(@{$this->[9]}, $nom, $desti);
	push(@{$desti->[8]}, $nom, $this);

	# Indiquem a la interficie que ens hem modificat
	$Interficie::singleton->setModificat();

    } else {
	# Comprovem que no hi sigui ja
	for (my $i = 0; $i < @{$this->[10]}; $i += 2) {
	    return if $this->[10][$i] eq $nom
		&& $this->[10][$i + 1] eq $desti;
	}

	# No hi era...
	push(@{$this->[10]}, $nom, $desti);
	push(@{$desti->[10]}, $nom, $this);

	# Indiquem a la interficie que ens hem modificat
	$Interficie::singleton->setModificat();
    }
}


# Eliminar Relacio
sub eliminarRel {
    my ($this, $nom, $dir, $desti) = @_;

    # Segons la relacio
    my ($idx, $idxA);

    if ($dir eq 'in') {
	($idx, $idxA) = (8, 9);
    } elsif ($dir eq 'out') {
	($idx, $idxA) = (9, 8);
    } else { # bi
	($idx, $idxA) = (10, 10);
    }

    # Busquem
    for (my $i = 0; $i < @{$this->[$idx]}; $i += 2) {
	if ($this->[$idx][$i] eq $nom
	    && $this->[$idx][$i+1] == $desti) {
	    # Els eliminem
	    splice(@{$this->[$idx]}, $i, 2);
	    last;
	}
    }

    # Busquem el reciproc
    for (my $i = 0; $i < @{$desti->[$idxA]}; $i += 2) {
	if ($desti->[$idxA][$i] eq $nom
	    && $desti->[$idxA][$i+1] == $this) {
	    # Els eliminem
	    splice(@{$desti->[$idxA]}, $i, 2);
	    last;
	}
    }

    # Indiquem a la interficie que ens hem modificat
    $Interficie::singleton->setModificat();
}


# Netejar les estructures abans d'esborrar-se
sub esborrar {
    my ($this) = @_;

    foreach my $idxs ([8, 9], [9, 8], [10, 10]) {
	my ($idx, $idxA) = @{$idxs};

	# Recorrem totes les relacions del tipus
	for (my $i = 0; $i < @{$this->[$idx]}; $i += 2) {
	    my $nom   = $this->[$idx][$i];
	    my $desti = $this->[$idx][$i+1];
	    
	    # Busquem el reciproc
	    for (my $i = 0; $i < @{$desti->[$idxA]}; $i += 2) {
		if ($desti->[$idxA][$i] eq $nom
		    && $desti->[$idxA][$i+1] == $this) {
		    # Els eliminem
		    splice(@{$desti->[$idxA]}, $i, 2);
		    last;
		}
	    }
	}
    }

    # Esborrem les llistes
    $this->[8]  = undef;
    $this->[9]  = undef;
    $this->[10] = undef;

    # Indiquem a la interficie que ens hem modificat
    $Interficie::singleton->setModificat();
}


# Retornem Cert
1;
