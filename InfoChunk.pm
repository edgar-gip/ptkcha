# Informacio del Chunk

use strict;

use Tk;

use Forwarder;
use Chunk;
use Projecte;

package InfoChunk;

our @ISA = qw( Forwarder );

# Constructor
sub new {
    my ($classe, $pare) = @_;

    # Creem el Panell
    # En un principi està buit
    my $frame = $pare->Frame();
    
    my $this = [ $frame, [], [], 0 ];
    return bless($this, $classe);
}


# Emplenar
sub populate {
    my ($this, $projecte) = @_;

    # Netegem tot el que hi hagi
    foreach my $widget (@{$this->[1]}) {
	$widget->gridForget();
    }

    # Llista nova
    @{$this->[1]} = ();

    # Anem afegint les caracteristiques del projecte
    my ($atributs, $isClustered) = map {
	($_->getAtributs(), $_->isClustered())
	} $projecte->getMarcatge();
    
    # Afegim les variables
    my $mida = @{$atributs} + 3;
    @{$this->[2]} = ( undef ) x $mida;
    $this->[3] = $mida;

    # Afegim l'ID
    push(@{$this->[1]},
	 $this->[0]->Label(-text => 'id: ')
	 ->grid(-column => 0, -row => 0, -sticky => 'ne'));
    push(@{$this->[1]},
	 $this->[0]->Entry(-width => 10, -state => 'disabled',
			   -textvariable => \$this->[2][0])
	 ->grid(-column => 1, -row => 0, -sticky => 'nw'));

    # Indexs per a col·locacio
    my ($col, $row);

    # Afegim el Subst si es clustered
    if ($isClustered) {
	push(@{$this->[1]},
	     $this->[0]->Label(-text => 'subst: ')
	     ->grid(-column => 2, -row => 0, -sticky => 'ne'));
	push(@{$this->[1]},
	     $this->[0]->Entry(-width => 10, -state => 'disabled',
			       -textvariable => \$this->[2][1])
	     ->grid(-column => 3, -row => 0, -sticky => 'nw'));

	$col = 4;
	$row = 0;
	
    } else {
	$col = 2;
	$row = 0;
    }
    
    # Afegim el nombre de mots
    push(@{$this->[1]},
	 $this->[0]->Label(-text => '#words: ')
	 ->grid(-column => $col, -row => $row, -sticky => 'ne'));
    push(@{$this->[1]},
	 $this->[0]->Entry(-width => 10, -state => 'disabled',
			   -textvariable => \$this->[2][2])
	 ->grid(-column => $col+1, -row => $row, -sticky => 'nw'));

    $col += 2;
    if ($col == 6) {
	$col = 0;
	++$row;
    }

    # Index de les variables
    my $idx = 3;

    # Anem afegint cada caracteristica
    foreach my $atr (@{$atributs}) {
	# Widgets
	push(@{$this->[1]},
	     $this->[0]->Label(-text => "$atr->[0] :")
	     ->grid(-column => $col, -row => $row, -sticky => 'ne'));
	push(@{$this->[1]},
	     $this->[0]->Entry(-width => 10, -state => 'disabled',
			       -textvariable => \$this->[2][$idx])
	     ->grid(-column => $col+1, -row => $row, -sticky => 'ne'));
	
	# Actualitzem Indexos
	$idx += 1;
	$col += 2;
	if ($col == 6) {
	    $col = 0;
	    $row += 1;
	}
    }
}


# Actualitzar
sub actualitzar {
    my ($this, $chunk) = @_;

    $this->[2][0] = $chunk->getId();
    $this->[2][1] = $chunk->getSubst();
    $this->[2][2] = $chunk->getNWords();

    my $atribs = $chunk->getAtributs();
    for (my $i = 3; $i < $this->[3]; ++$i) {
	$this->[2][$i] = $atribs->[$i - 3];
    }
}


# Netejar
sub clean {
    my ($this) = @_;

    for (my $i = 0; $i < $this->[3]; ++$i) {
	$this->[2][$i] = '';
    }
}


# Retornem cert
1;
