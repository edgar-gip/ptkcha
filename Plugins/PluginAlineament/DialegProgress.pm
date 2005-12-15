# Dialeg per a indicar el progress
# Te dues barres

use strict;

use Tk;
use Tk::DialogBox;
use Tk::ProgressBar;

use Forwarder;

package DialegProgress;

our @ISA = qw( Forwarder );


# Constructor
sub new {
    my ($classe, $pare) = @_;

    # Dialeg
    my $dialeg = $pare->Toplevel(-title => 'Alignment Process',
				 -cursor => 'clock');
    
    # Barres
    $dialeg->Label(-text => 'Fitxers', -anchor => 'nw')
	->pack(-side => 'top', -fill => 'x', -expand => 1,
	       -padx => 5, -pady => 5);
    my $barra3 =
	$dialeg->ProgressBar(-width => 20, -length => 200,
			     -from => 0, -to => 100,
			     -blocks => 20,
			     -colors => [ 0, 'blue', 25, 'DarkGreen', 50,
					  'green', 75, 'LimeGreen' ])
	    ->pack(-side => 'top', -fill => 'x', -expand => 1,
		   -padx => 5, -pady => 5);

    $dialeg->Label(-text => 'Alignment', -anchor => 'nw')
	->pack(-side => 'top', -fill => 'x', -expand => 1,
	       -padx => 5, -pady => 5);
    my $barra1 =
	$dialeg->ProgressBar(-width => 20, -length => 200,
			     -from => 0, -to => 100,
			     -blocks => 20,
			     -colors => [ 0, 'brown', 25, 'red', 50,
					  'orange', 75, 'yellow' ])
	    ->pack(-side => 'top', -fill => 'x', -expand => 1,
		   -padx => 5, -pady => 5);

    $dialeg->Label(-text => 'ED Minimization', -anchor => 'nw')
	->pack(-side => 'top', -fill => 'x', -expand => 1,
	       -padx => 5, -pady => 5);
    my $barra2 =
	$dialeg->ProgressBar(-width => 20, -length => 200,
			     -from => 0, -to => 100,
			     -blocks => 20,
			     -colors => [ 0, 'DarkBlue', 25, 'maroon', 50,
					  'violet', 75, 'pink' ])
	    ->pack(-side => 'top', -fill => 'x', -expand => 1,
		   -padx => 5, -pady => 5);

    # This
    my $this = [ $dialeg, $barra1, $barra2, $barra3, $pare ];

    # L'agrupem amb son pare i altres...
    $dialeg->group($pare);
    $dialeg->withdraw();
    $dialeg->protocol('WM_DELETE_WINDOW', sub { return });

    return bless($this, $classe);
}


# Mostrar
sub mostrar {
    my ($this) = @_;

    # Calculem on ha d'anar
    my $x = $this->[4]->rootx() + 100;
    my $y = $this->[4]->rooty() + 50;

    # Agafem el Grab
    $this->[0]->geometry("+$x+$y");
    $this->[0]->deiconify();
    $this->[0]->grab();
    $this->[0]->update();
}


# Sortir
sub sortir {
    my ($this) = @_;

    $this->[0]->grabRelease();
    $this->[0]->withdraw();
}


# Reset
sub reset {
    my ($this) = @_;

    $this->[1]->value(0);
    $this->[2]->value(0);
    $this->[3]->value(0);

    $this->[0]->update();
}


sub resetParcial {
    my ($this) = @_;

    $this->[1]->value(0);
    $this->[2]->value(0);

    $this->[0]->update();
}


# Canviar
sub canvi {
    my ($this, $idx, $val) = @_;
    
    $this->[$idx]->value($val);
    $this->[0]->update();
}


# Retornem cert
1;
