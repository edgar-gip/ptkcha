# Dialeg per a canviar un hash
# Edgar Gonzalez i Pellicer

use strict;

use Tk;
use Tk::DialogBox;

use Forwarder;

package HashDialog;

our @ISA = qw( Forwarder );

# Constructor
sub new {
    my ($classe, $pare, $refHash) = @_;
    
    # Cridem al constructor del dialeg
    my $dialeg = $pare->DialogBox(-title => 'Opcions',
				  -buttons => [ "D'Acord", 'Cancel·lar' ]);

    # Keys
    my @claus = sort(keys(%{$refHash}));
    
    # Objecte this
    my $this = [ $dialeg, \@claus ];

    # Construïm el contingut del Dialeg
    my $panell = $dialeg->add('Frame')->pack();

    my $row = 0;
    foreach my $clau (@claus) {
	$panell->Label(-text => $clau )
	    ->grid(-column => 0, -row => $row, -sticky => 'ne');
	$panell->Entry(-width => 40, -textvariable => \$this->[$row + 2])
	    ->grid(-column => 1, -row => $row, -sticky => 'new');
	++$row;
    }

    return bless($this, $classe);
}


# Actualitzar
sub actualitzar {
    my ($this, $refHash) = @_;

    my $idx = 2;
    foreach my $clau (@{$this->[1]}) {
	$this->[$idx++] = $refHash->{$clau};
    }
}


# Obtenir Resultats
sub getResults {
    my ($this, $refHash) = @_;

    my $idx = 2;
    foreach my $clau (@{$this->[1]}) {
	$refHash->{$clau} = $this->[$idx++];
    }
}


# Retornem cert
1;

