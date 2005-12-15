# Plugin per Alinear dos corpus

use strict;

use Plugin;
use Plugins::PluginAlineament::Alineador;
use Plugins::PluginAlineament::DialegAlineament;
use Plugins::PluginAlineament::DialegProgress;

use Plugins::PluginResum::DialegLlista;


package PluginAlineament;

our @ISA = qw( Plugin );


# Constructor
# Rep com a parametre una instancia de la interficie principal
sub new {
    my ($classe, $main) = @_;

    # Dialeg
    my $dialeg = new DialegAlineament($main->[3]);

    # Alineador
    my $ali = new Alineador();
    
    # Progres
    my $progres = new DialegProgress($main->[3]);

    # LlistaErrors
    my $dllista = new DialegLlista($main->[3], 'Alignment Generation');

    # This
    my $this = [ $dialeg, $main, $ali, 0, $progres, $dllista ];

    # Callback
    $ali->setCallback(sub { $this->progres(@_) }, 0.05);
    
    return bless($this, $classe);
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
    $menu->add('command', -label => 'Align Project...',
	       -command => sub { $this->alinear() } );

    return $menu;
}


# Alinear Projectes
sub alinear {
    my ($this) = @_;
    
    $this->[0]->actualitzar($this->[1]);
    if ($this->[0]->Show() eq "OK") {
	my $mode = $this->[0][1];
	
	($mode eq 'projecte' and $this->alignProject())
	    or
	($mode eq 'directori' and $this->alignDir())
	    or
	($mode eq 'fitxer' and $this->alignFile());
    }	    
}


# Alinear Projectes
sub alignProject {
    my ($this) = @_;

    # Busquem el projecte d'origen
    my $nprojecte = $this->[0][3];
    my $projecteOrig  = $this->[1]->getProjectManager()
	->cercarProjecte($nprojecte);

    if (!$projecteOrig) {
	# Error!
	$this->[1]->mostrarError("Project\n$nprojecte\ndoes not exist!");
	return;       
    }

    # Busquem els fitxers
    my $projecte = $this->[1]->getProjecte();
    my @files    = $projecte->getFiles();
    
    # Agafem la llista d'errors
    $this->[5]->netejarLlista();
    my $hiHaError = 0;
    
    # Anem alineant
    $this->[4]->reset();
    $this->[4]->mostrar();
    
    my $i = 0;
    my $incr = 100 / @files;
    foreach my $actual (@files) {
	my $textO;
	eval {
	    $textO = $projecteOrig->loadFile($actual);
	};

	if ($@) {
	    $this->[5]->afegirElement("Can't read source");
	    $this->[5]->afegirElement(" of $actual");
	    $hiHaError = 1;

	} else {
	    # No hi ha hagut error
	    eval {
		my $textAct = $projecte->loadFile($actual);
		$textAct =~ s/\<[^\>]+\>//g;
		
		$this->[3] = 1;
		$this->[4]->resetParcial();
		
		my $textNou = $this->[2]->alinear($textO, $textAct);
		
		$projecte->saveFile($actual, $textNou);
	    };

	    if ($@) {
		$this->[5]->afegirElement('Error generating alignment');
		$this->[5]->afegirElement(" for $actual");
		$hiHaError = 1;
	    }
	    
	}
	
	$i += $incr;
	$this->[4]->canvi(3, $i);
    }
    
    # Tanquem el dialeg de progres
    $this->[4]->sortir();
    
    # Hi ha hagut error?
    $this->[5]->Show() if $hiHaError;
    
    # Recarreguem el fitxer actual
    $this->[1]->revert(1);
}


# Alinear directori
sub alignDir {
    my ($this) = @_;

    # Busquem el fitxer d'origen
    my $directori = $this->[0][6];
    my $extensio  = $this->[0][8];
    
    # Busquem els fitxers
    my $projecte = $this->[1]->getProjecte();
    my @files    = $projecte->getFiles();

    # Agafem la llista d'errors
    $this->[5]->netejarLlista();
    my $hiHaError = 0;

    # Anem alineant
    $this->[4]->reset();
    $this->[4]->mostrar();
    
    my $i = 0;
    my $incr = 100 / @files;
    foreach my $actual (@files) {
	my $origen;
	if ($extensio ne '<cap>') {
	    $origen = "$directori/$actual$extensio";
	} else {
	    $origen = "$directori/$actual";
	}
	
	my $textO = $this->llegirFitxer($origen);
	if (defined($textO)) {
	    # No hi ha hagut error
	    eval {
		my $textAct = $projecte->loadFile($actual);
		$textAct =~ s/\<[^\>]+\>//g;
		
		$this->[3] = 1;
		$this->[4]->resetParcial();
		
		my $textNou = $this->[2]->alinear($textO, $textAct);
		
		$projecte->saveFile($actual, $textNou);
	    };

	    if ($@) {
		$this->[5]->afegirElement('Error generating alignment');
		$this->[5]->afegirElement(" for $actual");
		$hiHaError = 1;
	    }

	} else {
	    $this->[5]->afegirElement("Can't read file");
	    $this->[5]->afegirElement(" $origen");
	    $hiHaError = 1;
	}
	
	$i += $incr;
	$this->[4]->canvi(3, $i);
    }
    
    # Tanquem el dialeg de progres
    $this->[4]->sortir();
    
    # Hi ha hagut error?
    $this->[5]->Show() if $hiHaError;
    
    # Recarreguem el fitxer actual
    $this->[1]->revert(1);
}


# Alinear amb fitxer
sub alignFile {
    my ($this) = @_;

    my $origen = $this->[0][10];
    
    # Obrim el fitxer
    my $textO = $this->llegirFitxer($origen);
    if (!defined($textO)) {
	# Error!
	$this->[1]->mostrarError("File\n$origen\ndoes not exist!");
	return;
    }
    
    # Obtenim el fitxer actual i n'esborrem els tags
    my $textAct = '';
    $this->[1]->getTextActual(\$textAct);
    
    $textAct =~ s/\<[^\>]+\>//g;
	    
    # Alineem
    $this->[3] = 1;
    $this->[4]->reset();
    $this->[4]->mostrar();
	    
    my $textNou = $this->[2]->alinear($textO, $textAct);
    
    $this->[4]->sortir();
    
    # Esborrem el contingut del text central
    $this->[1][2]->delete("1.0", 'end');
    
    # Establim el nou text!
    eval {
	$this->[1]->establirText($textNou);
    };
    
    $this->[1]->mostrarError($@) if $@;
    
    # Indiquem que l'hem modificat
    $this->[1]->setModificat();
}


# Progres
sub progres {
    my ($this, $t) = @_;

    if ($t eq 'END') {
	$this->[4]->canvi($this->[3], 100);
	++$this->[3];
    } else {
	$this->[4]->canvi($this->[3], $t * 5);
    }
}


# Llegir un fitxer
sub llegirFitxer {
    my ($this, $origen) = @_;
    
    my $forig = new IO::File("< $origen")
	or return undef;
    
    # Llegim tot el seu contingut
    my $text = '';
    while (my $linia = $forig->getline()) {
	chomp($linia);
	$text .= "$linia ";
    }
    $forig->close();
    
    return $text;
}


# Retornem Cert
1;
