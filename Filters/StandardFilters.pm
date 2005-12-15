# Built-in filters

use strict;

use Filter;


#######
# UTF #
#######

package Filters::FilterUtf;

our @ISA = qw( FilterLineByLine );

# Reset
sub reset {
    my ($this) = @_;
    
    # State variable
    $this->[1] = 0;
}


# Filtre Utf
sub filterLine {
    my ($this, $linia, $noPunct) = @_;
    
    my $afegit;
    while ($linia) {
	# print "Mirant $linia en estat $estat...\n";
	
	# Segons l'estat en que estem
	if ($this->[1] == 0) {
	    # Fora d'un TAG
	    # Mirem si n'hi ha algun
	    if ($linia =~ /\s*\</) {
		# El que hi hagi abans, ho enganxem
		if ($`) {
		    $afegit = $this->eliminarMarques($`, $noPunct); 
		    $this->[0] .= $this->prepararImpXML($afegit)." "
			if $afegit;
		}
		
		$linia = $';
		$this->[1] = 1;
		
	    } else {
		$afegit = $this->eliminarMarques($linia, $noPunct);
		$this->[0] .= $this->prepararImpXML($afegit)." "
		    if $afegit;
		$linia = '';
	    }
	    
	} else {
	    # Dins d'un TAG
	    # Mirem de sortir-ne
	    if ($linia =~ /\>\s*/) {
		# Agafem el que hi hagi després
		$linia = $';
		$this->[1] = 0;
		
	    } else {
		# Consumim tota la linia sense fer res
		$linia = '';
	    }
	}
    }
}


# Eliminar les marques SGML
sub eliminarMarques {
    my ($this, $linia, $noPunct) = @_;
    
    # Marques de no paraula
    $linia =~ s/(\s|^)[\*\{\%](\w+)//g;
    
    # Marques d'una paraula
    $linia =~ s/(\s|^)[\@\^\+](\w)/$1$2/g;
    
    # Sigles
    $linia =~ s/\_//g;
    
    # Puntuacio
    $linia =~ s/[\.\,\?\!]+(\s|$)/$1/g if $noPunct;
			    
    # BackGround
    $linia =~ s/\[\[[^\]]+\]\]//g;
    $linia =~ s/\[[^\]]+\]//g;

    # Espais a l'inici, al final i dobles
    $linia =~ s/^\s+//;
    $linia =~ s/\s+^//;
    $linia =~ s/\s\s+/ /g;

    # print "Afegirem $linia...\n";
    return $noPunct ? lc($linia) : $linia;
}



##########
# UTF_NP #
##########

package Filters::FilterUtfNp;
    
our @ISA = qw( Filters::FilterUtf );


# Only overloads this function
sub filterLine {
    my ($this, $line) = @_;

    return $this->Filters::FilterUtf::filterLine($line, 1);
}



#######
# YAM #
#######

package Filters::FilterYam;

our @ISA = qw( FilterLineByLine );


# Reset
sub reset {
    my ($this) = @_;
    
    # State variable
    $this->[1] = 0;
}


# Filtrar Yam
sub filterLine {
    my ($this, $linia) = @_;

    # Linia en blanc?
    if (!$linia) {
	$this->[0] .= "\n";
	return;
    }

    # Altrament
    my @parts = split(' ', $linia);
    if ($parts[2] =~ /^B\-(.+)$/) {
	# Comença una nova NE
	if ($this->[1]) {
	    # Tanquem l'anterior
	    $this->[0] .= "</ne>";
	}

	# Comencem la nostra
	$this->[0] .= " <ne classe=\"$1\">".$this->prepararImpXML($parts[0]);
	$this->[1] = 1;

    } elsif ($parts[2] =~ /^I(:?\-(.+))?$/) {
	if (!$this->[1]) {
	    # N'obrim una de dummy -> Error Yamcha!
	    $this->[0] .= " <ne classe=\"$1\">";
	    $this->[1] = 1;
	}
	
	$this->[0] .= " ".$this->prepararImpXML($parts[0]);
	
    } else {
	# Cal tancar?
	if ($this->[1]) {
	    $this->[0] .= "</ne>";
	    $this->[1] = 0;
	}
	
	$this->[0] .= " ".$this->prepararImpXML($parts[0]);
    }
}



#######
# TXT #
#######

package Filters::FilterTxt;

our @ISA = qw( FilterLineByLine );


# Filtrar Text
sub filterLine {
    my ($this, $cadena) = @_;

    # Coses que poden fer petar l'XML
    # -> Han de venir del ViaVoice
    $cadena =~ s/\s*\&\s*/ ampersand /g;
    $cadena =~ s/\s*\<\s*/ is less than /g;
    $cadena =~ s/\s*\>\s*/ is greater than /g;
    $cadena =~ s/\s*¢\s*/ cent /g;

    return $cadena;
}



# Return true
1;
