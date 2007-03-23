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

use strict;

use Tk;

package ProjectPopUp;

our %icoSte = ( bi => '<->', uni => '->', equiv => '=' );


# Constructor
sub new {
    my ($classe, $main, $pare) = @_;

    # Creem el menu
    my $menu = $pare->Menu(-tearoff => 0, -title => 'Chunk');
    
    # Retornem
    return bless([ $menu, $main, undef, undef, undef ], $classe);
}


# Popular
sub populate {
    my ($this, $projecte) = @_;

    # Netegem l'objecte
    splice(@{$this}, 2);

    # Netegem el menu
    $this->[0]->delete(0, 'end');

    # Obtenim els atributs
    my $atributs = $projecte->getMarcatge()->getAtributs();
    
    if (@{$atributs} == 1) {
	# Afegim només una categoria
	my ($nom, @valors) = @{$atributs->[0]};
	$this->[0]->add('command', -label => $nom);

	my $menuDesti = $this->[0];
	my $quants    = 0;
	foreach my $v (@valors) {
	    $menuDesti->add('radiobutton',
			    -value => $v, -label => $v,
			    -variable => \$this->[5],
			    -command => sub { $this->setAtrib(0); });

	    if (++$quants > 15) {
		my $nouMenu = $menuDesti->Menu(-tearoff => 0,
					       -title => "$quants...");
		$menuDesti->add('cascade', -label => 'More',
				-menu => $nouMenu);

		$menuDesti = $nouMenu;
		$quants    = 0;
	    }
	}
	
    } elsif (@{$atributs} > 1) {
	# Afegim tot de cascades

	my $idx = 0;
	foreach my $atr (@{$atributs}) {
	    my ($nom, @valors) = @{$atr};
	    my $menufill = $this->[0]->Menu(-tearoff => 0,
					    -title => $nom);

	    my $menuDesti = $menufill;
	    my $quants    = 0;
	    foreach my $v (@valors) {
		my $nIdx = $idx;
		$menuDesti->add('radiobutton',
				-value => $v, -label => $v,
				-variable => \$this->[$idx + 5],
				-command => sub { $this->setAtrib($nIdx); });

		if (++$quants > 15) {
		    my $nouMenu = $menuDesti->Menu(-tearoff => 0,
						   -title => "$quants...");
		    $menuDesti->add('cascade', -label => 'More',
				    -menu => $nouMenu);
		    
		    $menuDesti = $nouMenu;
		    $quants    = 0;
		}
	    }
	    
	    $this->[0]->add('cascade', -label => $nom,
			    -menu => $menufill);
	    ++$idx;
	}
	
    } else { # Si no hi ha atributs
	$this->[0]->add('command', -label => 'Without Attributes');
    }


    # Relacions?
    my $relacions = $projecte->getMarcatge()->getRelacions();
    
    if (@{$relacions}) {
	# Afegim el separador
	$this->[0]->add('separator');

	# Creem el menu
	my $menurel = $this->[0]->Menu(-tearoff => 0);

	# Per a cada relacio
	my $idx = 0;
	foreach my $rel (@{$relacions}) {
	    $menurel->add('command', -label => "$rel->[0] ($icoSte{$rel->[1]})",
			  -command => sub { $this->addRel($rel->[0], $rel->[1]) });
	}
	
	$this->[0]->add('cascade', -label => 'Relate',
			-menu => $menurel);
    }
    

    # Clustered
    if ($projecte->getMarcatge()->isClustered()) {
	# Afegim el separador
	$this->[0]->add('separator');

	# Afegim l'Opcio
	$this->[0]->add('command', -label => 'Add to Group',
			-command => sub { $this->afegirChunk() });
    }
    
    # Opcio Comuna
    $this->[0]->add('separator');
    $this->[0]->add('command', -label => 'Delete',
		    -command => sub { $this->esborrarChunk() });
}


# Mostrar
sub Post {
    my ($this, $chunk, $x, $y) = @_;
    
    # Triem els atributs del Chunk
    @{$this}[5..$#{$this}] = @{$chunk->getAtributs()};
    
    # Marquem que es el Chunk Actual
    $this->[2] = $chunk;
    
    # Postegem
    $this->[0]->Post($x, $y);
}


# Establir l'Atribut
sub setAtrib {
    my ($this, $num) = @_;

    $this->[2]->setAtrib($num, $this->[$num + 5]);
    $this->[1]->notificarCanviAtribut($num, $this->[2]);
}


# Afegir una relacio
sub addRel {
    my ($this, $nom, $stereo) = @_;

    # Ens guardem la Rel
    $this->[3] = $nom;
    $this->[4] = $stereo;
    $this->[1]->changeMode('triarRel');
}


# Afegir un chunk (clustering)
sub afegirChunk {
    my ($this) = @_;
    
    # Activem el mode clustering
    $this->[1]->changeMode('triarSubst');
}


# Esborrar un chunk
sub esborrarChunk {
    my ($this) = @_;

    $this->[1]->esborrarChunk($this->[2]);
    $this->[2] = undef;
}


# Chunk actiu
sub getActiveChunk { return $_[0]->[2]; }

# Relacio activa
sub getActiveRel { return ($_[0]->[3], $_[0]->[4]); }

# Retornem Cert
1;
