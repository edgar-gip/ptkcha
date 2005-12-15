# Opertura d'un Projecte

use strict;

use Tk;
use Tk::DialogBox;

use ProjectManager;

package OpenProjectDialog;

# Constructor
sub new {
    my ($classe, $pare, $projectManager) = @_;

    # Cridem al constructor del dialeg
    my $dialeg = $pare->DialogBox(-title => 'Open Project',
				  -buttons => [ "OK", 'Cancel' ]);
    
    # Construïm el contingut del Dialeg
    my $megawidget = $dialeg->add('Scrolled',
				  'Listbox',
				  -scrollbars => 'e',
				  -selectmode => 'single')
	->pack(-fill => 'both', -expand => 1);
    my $llista = $megawidget->Subwidget('scrolled');

    # Objecte this
    my $this = [ $dialeg, $projectManager, $llista ];

    return bless($this, $classe);
}


# Change title
sub setTitle {
    my ($this, $title) = @_;

    $this->[0]->title($title);
}


# Mostrar
sub Show {
    my ($this) = @_;

    # Llista
    my $llista = $this->[2];

    # Netejem la llista
    $llista->delete(0, 'end');

    # Obtenim els projectes
    foreach my $p (@{$this->[1]}) {
	$llista->insert('end', $p->getNom());
    }

    return $this->[0]->Show();
}


# Elecció feta
sub getParams {
    my ($this) = @_;

    my @seleccio = $this->[2]->curselection();
    return $seleccio[0];
}


# Retornem Cert
1;
