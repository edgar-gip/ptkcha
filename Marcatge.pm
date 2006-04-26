# Marcatge

use strict;

use XML::Parser;
use Chunk;

package Marcatge;

# Atributs
############
# 0: Llista Atributs
# 1: Llista Relacions
# 2: Haix Atributs
# 3: Haix Relacions
# 4: Clustered
# 5: Etiqueta
# 6: Colors
# 7: Plugins
# 8: Fitxer

sub new {
    my ($classe, $fitxer) = @_;

    # L'objecte (amb valors per defecte)
    my $this = [ [], [], {}, {}, 0, 'chunk', [], [], $fitxer ];

    return if $fitxer eq ''; # Marcatge buit

    # Comprovem el Fitxer
    die "Marking does not exist: $fitxer\n" if !(-e $fitxer);
    die "Marking is not readable: $fitxer\n" if !(-r $fitxer);
    
    # Parsegem
    my $parser = new XML::Parser(Style => 'Tree');
    my $arbre;
    eval {
	$arbre = $parser->parsefile($fitxer);
    };
    die "Marking file is not XML: $fitxer\n" if $@;
    
    # Creem les llistes d'Atributs i de Relacions
    die "Marking file does not contain an XML <marking>: $fitxer\n"
	if $arbre->[0] ne 'marking' && $arbre->[0] ne 'marcatge';
    
    # Busquem l'etiqueta
    $this->[5] = $arbre->[1][0]{'element'} if defined($arbre->[1][0]{'element'});
    shift(@{$arbre->[1]});
    
    # Anem llegint
    while (@{$arbre->[1]}) {
	my ($tag, $contingut) = (shift(@{$arbre->[1]}), shift(@{$arbre->[1]}));
	if ($tag eq '0') {
	    # Es text, passem d'ell
	    
	} elsif ($tag eq 'attribute' || $tag eq 'atribut') {
	    # Atributs
	    # Nom
	    my $nom = $contingut->[0]{'name'} || $contingut->[0]{'nom'};
	    my $infoAtrib = [ $nom ];
	    my $hashColors = {};
	    
	    # Valors
	    shift(@{$contingut});

	    my $i = 0;
	    while (@{$contingut}) {
		my ($tag2, $cont2)
		    = (shift(@{$contingut}), shift(@{$contingut}));
		if ($tag2 eq 'value' || $tag2 eq 'valor') {
		    # Agafem el valor
		    push(@{$infoAtrib}, $cont2->[0]{'v'});
		    $hashColors->{$cont2->[0]{'v'}} = $Chunk::colors[$i++ % @Chunk::colors];
		}
	    }
	    
	    # Ho afegim a la llista i al Haix
	    push(@{$this->[0]}, $infoAtrib);
	    push(@{$this->[6]}, $hashColors);
	    $this->[2]->{$nom} = $#{$this->[0]};
	    
	} elsif ($tag eq 'relation' || $tag eq 'relacio') {
	    # Relacions
	    # Obtenim atributs
	    my $nom = $contingut->[0]{'name'} || $contingut->[0]{'nom'};
	    my $ste = $contingut->[0]{'stereo'};
	    
	    # Ho afegim a la llista i al haix
	    push(@{$this->[1]}, [ $nom, $ste ]);
	    $this->[3]->{$nom} = $#{$this->[1]};

	} elsif ($tag eq 'clustered') {
	    # El fitxer es clustered
	    $this->[4] = 1;

	} elsif ($tag eq 'plugin') {
	    # Afegim un plugin
	    my $nom    = $contingut->[0]{'name'}  || $contingut->[0]{'nom'};
	    my $classe = $contingut->[0]{'class'} || $contingut->[0]{'classe'};
	    my $fitxer = $contingut->[0]{'file'}  || $contingut->[0]{'fitxer'};
	    
	    push(@{$this->[7]}, $nom, $classe, $fitxer);
	}
	# Espai per a ampliacions
    }
    
    return bless($this, $classe);
}


# Build Cadena
sub buildCadena {
    my ($this, $chunk) = @_;
    
    my $cadena = "<$this->[5] id=\"".$chunk->getId().'"';
    
    # Subst
    $cadena .= ' subst="'.$chunk->getSubst().'"' if $this->[4];
	   
    # Atributs
    my $valors = $chunk->getAtributs();
    my $i = 0;
    foreach my $atr (@{$this->[0]}) {
	# Nom i valor de l'atribut
	$cadena .= " $atr->[0]=\"$valors->[$i++]\"";
    }
    $cadena .= '>';

    # Relacions
    my $cadenaRels = '';
    my $relacions = $chunk->getSortints();
    for (my $i = 0; $i < @{$relacions}; $i += 2) {
	$cadenaRels .= "<rel type=\"$relacions->[$i]\" target=\""
	    .$relacions->[$i+1]->getId().'" />';
    }
    $relacions = $chunk->getBidireccionals();
    for (my $i = 0; $i < @{$relacions}; $i += 2) {
	$cadenaRels .= "<rel type=\"$relacions->[$i]\" target=\""
	    .$relacions->[$i+1]->getId().'" />';
    }
    
    $cadena .= "<rels>$cadenaRels</rels>" if $cadenaRels;

    return $cadena;
}


# Consultores

sub getAtributs  { return $_[0]->[0]; }
sub getRelacions { return $_[0]->[1]; }
sub getRelacio   { return $_[0]->[1][$_[1]]; }
sub findAtribut  { return $_[0]->[2]{$_[1]}; }
sub findRelacio  { return $_[0]->[3]{$_[1]}; }
sub isClustered  { return $_[0]->[4]; }
sub getEtiqueta  { return $_[0]->[5]; }
sub getPlugins   { return $_[0]->[7]; }
sub getFileName  { return $_[0]->[8]; }

sub colorAtribut {
    my ($this, $nAtrib, $valor) = @_;

    return $this->[6][$nAtrib]{$valor};
}


# Retornem Cert
1;
