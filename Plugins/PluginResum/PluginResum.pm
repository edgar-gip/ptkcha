# Plugin per a resum

use Plugin;
use Tk;

use Plugins::PluginResum::DialegLlista;
use Plugins::PluginResum::DialegResum;

package PluginResum;

our @ISA = qw( Plugin );

# Constructor
# Rep com a parametre una instancia de la interficie principal
sub new {
    my ($classe, $main) = @_;

    # Dialeg
    my $dialeg = new DialegResum($main->[3], $main);

    # Construim el dialegLlista
    my $llista = new DialegLlista($main->[3], 'Dependency Checking',
				  30);

    return bless([ $dialeg, $main, $llista ], $classe);
}


# Destructor
sub free {
    # my ($this) = @_;
}


# Crear Menu
# Rep com a parametre el pare
sub makeMenu {
    my ($this, $pare) = @_;

    my $menu = $pare->Menu(-tearoff => 0);
    $menu->add('command', -label => 'Generate Summary...',
	       -command => sub { $this->generarResum() } );
    $menu->add('separator');
    $menu->add('command', -label => 'Check Dependencies',
	       -command => sub { $this->checkDependencies(1) } );

    return $menu;
}


# Generar un resum
sub generarResum {
    my ($this) = @_;

    # Comencem comprovant les dependencies
    return if !$this->checkDependencies(0);

    $this->[0] = new DialegResum($main->[3], $main) unless Tk::Exists($this->[0]);
    $this->[0]->mostrar();
}


# Comprovar les Dependencies
sub checkDependencies {
    my ($this, $info) = @_;

    # Netegem la llista
    $this->[2]->netejarLlista();

    # Comprovem les dependències...
    my $totOk = 1;

    # Busquem atribut pes
    my $idxPes = $this->[1]->getProjecte()
	->getMarcatge()->findAtribut('weight');
    
    # Recorrem la llista de chunks
    foreach my $ch ($this->[1]->getChunks()) {
	# Pes
	my $elMeuPes = $ch->getAtributs()->[$idxPes];

	# Comprovem que el pes dels chunks de què depèn sigui major
	my $sortints = $ch->getSortints();
	for (my $i = 0; $i < @{$sortints}; $i += 2) {
	    if ($sortints->[$i] eq 'depen' &&
		$elMeuPes < $sortints->[$i + 1]->getAtributs()->[$idxPes]) {
		
		# Afegim a la llista l'error
		$this->[2]->afegirElement("Chunk ".$ch->getId()." (weight $elMeuPes) ");
		$this->[2]->afegirElement(" depends on Chunk ".$sortints->[$i + 1]->getId()." (weight ".$sortints->[$i + 1]->getAtributs()->[$idxPes].")!");
		# Error
		$totOk = 0;
	    }
	}
    }

    if ($totOk) {
	if ($info) {
	    $this->[2]->afegirElement("All dependencies OK!");
	    $this->[2]->Show();
	}
    } else {
	$this->[2]->Show();
    }

    return $totOk;
}


# Retornem cert
1;
