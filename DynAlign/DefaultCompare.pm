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

# Funcio de Comparacio per Defecte

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
