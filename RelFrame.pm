use strict;

use Tk;

use Forwarder;

package RelFrame;

our @ISA = qw( Forwarder );

# Atributs
############
# 0: Canvas
# 1: Menu
# 2: Text
# 3: Chunk actual
# 4: Nom Relacio Actual
# 5: Tipus Actual
# 6: Chunk desti actual
# 7: main

# Constructor
sub new {
    my ($classe, $main, $pare) = @_;

    my $this = [];
    my $canvas = $pare->Scrolled('Canvas', -scrollbars => 'e',
				 -width => 100);
    my $menu   = $canvas->Menu(-tearoff => 0, -title => 'Relacio');
    $menu->add('command', -label => 'Delete Relation',
	       -command => sub { $this->eliminarRel(); });

    push(@{$this}, $canvas, $menu, undef, undef, undef, undef, undef, $main);
    return bless($this, $classe);
}


# Actualitzar
sub actualitzar {
    my ($this, $chunk) = @_;

    # Ens guardem el chunk actual
    $this->[3] = $chunk;

    # Creem el quadre que correspon al Chunk
    my $idRec = $this->[0]->createRectangle(40, 20, 90, 40,
					    -outline => 'black',
					    -fill => $chunk->getColor());
    $this->[0]->createText(65, 30, -anchor => 'center',
			   -fill => 'white', -text => $chunk->getId());

    $this->[0]->bind($idRec, '<Button-1>', sub { $this->zoom($chunk); });
    

    # Anem creant els quadres de les relacions
    my $xrel = 20;
    my $yrel = 60;

    # Entrants
    my $llistaRel = $chunk->getEntrants();
    for (my $i = 0; $i < @{$llistaRel}; $i += 2) {
	$idRec = $this->[0]->createRectangle(40, $yrel, 90, $yrel + 20,
					     -outline => 'black',
					     -fill => $llistaRel->[$i+1]->getColor());
	$this->[0]->createText(65, $yrel + 10, -anchor => 'center',
			       -fill => 'white',
			       -text => $llistaRel->[$i+1]->getId());
	$this->[0]->createText(42, $yrel - 1, -anchor => 'sw',
			       -fill => 'black',
			       -text => $llistaRel->[$i]);
	$this->[0]->createLine(40, 15 + $xrel, $xrel, 15 + $xrel,
			       $xrel, $yrel + 10, 40, $yrel + 10,
			       -fill => 'blue', -arrow => 'first');

	my $chunkD = $llistaRel->[$i + 1];
	my $nom    = $llistaRel->[$i];
	$this->[0]->bind($idRec, '<Button-1>', sub { $this->zoom($chunkD); });
	$this->[0]->bind($idRec, '<Button-3>',
			 [ sub { $this->prepararEliminar($nom, 'in', $chunkD, @_); },
			   Tk::Ev('X'), Tk::Ev('Y') ]);
	
	$xrel -= 1;
	$yrel += 40;
    }

    # Sortints
    $llistaRel = $chunk->getSortints();
    for (my $i = 0; $i < @{$llistaRel}; $i += 2) {
	$idRec = $this->[0]->createRectangle(40, $yrel, 90, $yrel + 20,
					     -outline => 'black',
					     -fill => $llistaRel->[$i+1]->getColor());
	$this->[0]->createText(65, $yrel + 10, -anchor => 'center',
			       -fill => 'white',
			       -text => $llistaRel->[$i+1]->getId());
	$this->[0]->createText(42, $yrel - 1, -anchor => 'sw',
			       -fill => 'black',
			       -text => $llistaRel->[$i]);
	$this->[0]->createLine(40, 15 + $xrel, $xrel, 15 + $xrel,
			       $xrel, $yrel + 10, 40, $yrel + 10,
			       -fill => 'red', -arrow => 'last');

	my $chunkD = $llistaRel->[$i + 1];
	my $nom    = $llistaRel->[$i];
	$this->[0]->bind($idRec, '<Button-1>', sub { $this->zoom($chunkD); });
	$this->[0]->bind($idRec, '<Button-3>',
			 [ sub { $this->prepararEliminar($nom, 'out', $chunkD, @_); },
			   Tk::Ev('X'), Tk::Ev('Y') ]);

	$xrel -= 1;
	$yrel += 40;
    }

    # Bis
    my $llistaRel = $chunk->getBidireccionals();
    for (my $i = 0; $i < @{$llistaRel}; $i += 2) {
	$idRec = $this->[0]->createRectangle(40, $yrel, 90, $yrel + 20,
					     -outline => 'black',
					     -fill => $llistaRel->[$i+1]->getColor());
	$this->[0]->createText(65, $yrel + 10, -anchor => 'center',
			       -fill => 'white',
			       -text => $llistaRel->[$i+1]->getId());
	$this->[0]->createText(42, $yrel - 1, -anchor => 'sw',
			       -fill => 'black',
			       -text => $llistaRel->[$i]);
	$this->[0]->createLine(40, 15 + $xrel, $xrel, 15 + $xrel,
			       $xrel, $yrel + 10, 40, $yrel + 10,
			       -fill => 'green', -arrow => 'both');

	my $chunkD = $llistaRel->[$i + 1];
	my $nom    = $llistaRel->[$i];
	$this->[0]->bind($idRec, '<Button-1>', sub { $this->zoom($chunkD); });
	$this->[0]->bind($idRec, '<Button-3>',
			 [ sub { $this->prepararEliminar($nom, 'bi', $chunkD, @_); },
			   Tk::Ev('X'), Tk::Ev('Y') ]);

	$xrel -= 1;
	$yrel += 40;
    }
}


# Netejar
sub clean {
    my ($this) = @_;

    $this->[0]->delete('all');
}


# Set germa text
sub setGerma { $_[0]->[2] = $_[1]; }


# Zoom
sub zoom {
    my ($this, $chunk) = @_;
    
    # Li diem al text que ensenyi el que toca
    $this->[2]->see($chunk->getStart());
}


# Preparar eliminar
sub prepararEliminar {
    my ($this, $nom, $tipus, $chunkD, $rot, $x, $y) = @_;

    # Guardem la informacio d'Actual
    $this->[4] = $nom;
    $this->[5] = $tipus;
    $this->[6] = $chunkD;

    $this->[1]->Post($x, $y);
}


# Eliminar Rel
sub eliminarRel {
    my ($this) = @_;

    # Obtenim el que hem d'eliminar i eliminem
    $this->[3]->eliminarRel($this->[4], $this->[5], $this->[6]);

    # Indiquem que hem modificat el document
    $this->[7]->[17] = 1;

    # Redibuixem
    $this->clean();
    $this->actualitzar($this->[3]);
}


# Retornem Cert
1;
