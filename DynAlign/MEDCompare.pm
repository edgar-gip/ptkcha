# Comparacio per Minimum Edit Distance
# Edgar Gonzalez i Pellicer, 2004

# Per a fer la MED, fem un altre DynAlign
# (un DynAlign dins un DynAlign, oh!)

use strict;

use DynAlign::DefaultCompare;
use DynAlign::DynAlign;


package MEDCompare;

use vars qw( @ISA );
@ISA = qw( DefaultCompare );

# Constructor
sub new {
    my ($class) = @_;
    
    my $comparador = new DynAlign(new DefaultCompare(0,1,1));
    return bless([ $comparador ], $class);
}


# Aplicar la funció
sub aplicar {
    my ($this, $valor1, $valor2) = @_;

    my $llista1 = str2list($valor1);
    my $llista2 = str2list($valor2);
    return $this->[0]->alinear($llista1, $llista2, 'min');
}


# Es un MisAlign?
sub esMisAlign {
    my ($this, $valor1, $valor2) = @_;

    return ($valor1 ne $valor2);
}


# Fer un skip
sub skip {
    my ($this, $valor) = @_;

    return length($valor);
}


# Transformar una cadena a llista
sub str2list {
    my ($cadena) = @_;

    my @result = map { lc(substr($cadena, $_, 1)); } (0..length($cadena)-1);
    return \@result;
}
