# Funcio de Comparacio per Defecte
# Edgar Gonzalez i Pellicer, 2004

use strict;

# Funció per Defecte
package DefaultCompare;

# Constructor
sub new {
    my ($class, $match, $mismatch, $skip) = @_;

    $match    = 1 if !defined($match);
    $mismatch = 0 if !defined($mismatch);
    $skip     = 1 if !defined($skip);

    return bless([ $match, $mismatch, $skip ], $class);
}


# Aplicar la funció
sub aplicar {
    my ($this, $valor1, $valor2) = @_;

    return $this->[ ($valor1 eq $valor2) ? 0 : 1 ];
}


# Cost de fer un skip
sub skip {
    my ($this, $mot) = @_;

    return $this->[2];
}


# Es un MisAlign?
sub esMisAlign {
    my ($this, $valor1, $valor2) = @_;

    return ($valor1 ne $valor2);
}


# Funció per Defecte, però sense Case
package DefaultCompareNoCase;

use vars qw( @ISA );

@ISA = qw( DefaultCompare );

# Heretem el Constructor

# Aplicar la funció
sub aplicar {
    my ($this, $valor1, $valor2) = @_;

    ($valor1, $valor2) = (lc($valor1), lc($valor2));
    return $this->[ ($valor1 eq $valor2) ? 0 : 1 ];
}

# Heretem el cost de skip

# Es un MisAlign
sub esMisAlign {
    my ($this, $valor1, $valor2) = @_;

    return (lc($valor1) ne lc($valor2));
}


# Retornem Cert
1;
