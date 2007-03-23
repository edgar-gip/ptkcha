# Copyright (C)  Edgar Gonzàlez i Pellicer
#
# This file is part of PTkChA
#  
# PTkChA is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software 
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

# Comparacio per Minimum Edit Distance

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
