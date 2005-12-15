# Crear un Nou Projecte

use strict;

use Tk;
use Tk::DialogBox;
use Tk::DirSelect;
use Tk::FileSelect;

use Projecte;

package NewProjectDialog;

# Constructor
sub new {
    my ($classe, $pare, $filterManager) = @_;

    # Cridem al constructor del dialeg
    my $dialeg = $pare->DialogBox(-title => 'New Project',
				  -buttons => [ "OK", 'Cancel' ]);

    # Objecte this
    my $this = [ $dialeg, '', '', '', '', 'txt', 'txt' ];

    # Construïm el contingut del Dialeg
    my $panell = $dialeg->add('Frame')->pack();

    $panell->Label(-text => 'Name: ')
	->grid(-column => 0, -row => 0, -sticky => 'ne');
    $panell->Entry(-width => 40, -textvariable => \$this->[1])
	->grid(-column => 1, -row => 0, -sticky => 'new');
    $panell->Label(-text => 'Input Directory: ')
	->grid(-column => 0, -row => 1, -sticky => 'ne');
    $panell->Entry(-width => 40, -textvariable => \$this->[2])
	->grid(-column => 1, -row => 1, -sticky => 'new');
    $panell->Button(-text => '...', -command => sub { $this->canvi(2, "Input Directory", 'dir') })
	->grid(-column => 2, -row => 1, -sticky => 'nw');
    $panell->Label(-text => 'Output Directory: ')
	->grid(-column => 0, -row => 2, -sticky => 'ne');
    $panell->Entry(-width => 40, -textvariable => \$this->[3])
	->grid(-column => 1, -row => 2, -sticky => 'new');
    $panell->Button(-text => '...', -command => sub { $this->canvi(3, 'Output Directory', 'dir') })
	->grid(-column => 2, -row => 2, -sticky => 'nw');
    $panell->Label(-text => 'Marking: ')
	->grid(-column => 0, -row => 3, -sticky => 'ne');
    $panell->Entry(-width => 40, -textvariable => \$this->[4])
	->grid(-column => 1, -row => 3, -sticky => 'new');
    $panell->Button(-text => '...', -command => sub { $this->canvi(4, 'Marking', 'file') })
	->grid(-column => 2, -row => 3, -sticky => 'nw');

    my $filters = [ $filterManager->getFilters() ];
    $panell->Label(-text => 'Format: ')
	->grid(-column => 0, -row => 4, -sticky => 'ne');
    $panell->BrowseEntry(-state => 'readonly', -choices => $filters,
			 -variable => \$this->[5])
	->grid(-column => 1, -row => 4, -sticky => 'new');

    $panell->Label(-text => 'File Extension: ')
	->grid(-column => 0, -row => 5, -sticky => 'ne');
    $panell->Entry(-width => 40, -textvariable => \$this->[6])
	->grid(-column => 1, -row => 5, -sticky => 'new');
    
    return bless($this, $classe);
}


sub populate {
    my ($this, $nom, $dirIn, $dirOut, $marcatge, $format, $extensio) = @_;

    # Valors per defecte
    $nom      ||= '';
    $dirIn    ||= '';
    $dirOut   ||= '';
    $marcatge ||= '';
    $format   ||= 'txt';
    $extensio ||= 'txt';

    # Assignem a les Variables
    @{$this}[1..6] = ($nom, $dirIn, $dirOut, $marcatge, $format, $extensio);
}


sub Show {
    my ($this) = @_;

    return $this->[0]->Show();
}


sub getParams {
    my ($this) = @_;

    return @{$this}[1..6];
}


sub canvi {
    my ($this, $pos, $miss, $mode) = @_;

    my $vInicial = $this->[$pos];

    my $result;
    if ($mode eq 'dir') {
	$result = $this->[0]->DirSelect(-title => $miss)->Show($vInicial);

    } elsif ($vInicial =~ /(.+\/)[^\/]*$/) { # Es 'file' relatiu
	$result = $this->[0]->FileSelect(-directory => $1)->Show();

    } else {
	$result = $this->[0]->FileSelect(-directory => '.')->Show();
    }

    if ($result) {
	$this->[$pos] = $result;
    }
}


# Retornem Cert
1;
