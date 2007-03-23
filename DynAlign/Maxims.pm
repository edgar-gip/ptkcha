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

# Comparacions i Maxims

use Exporter;

package Maxims;

use vars qw( @ISA @EXPORT_OK );

@ISA = qw( Exporter );
@EXPORT_OK = qw( max3 max3s min3 min3s );


##########################
# Comparacio de Parelles #
##########################

# Es major la parella ($v1, $c1) que ($v2, $c2)?
sub majorPar {
    my ($v1, $c1, $v2, $c2) = @_;

    return 1 if ($v1 > $v2);
    
    return 0 if ($v1 < $v2);
    
    return ($c1 > $c2);
}


# Es major o igual la parella ($v1, $c1) que ($v2, $c2)?
sub majorIgPar {
    my ($v1, $c1, $v2, $c2) = @_;

    return 1 if ($v1 > $v2);
    
    return 0 if ($v1 < $v2);
    
    return ($c1 >= $c2);
}


#############################
# Maxim/Minim de 3 parelles #
#############################

# Funció que retorna el maxim de 3 valors numèrics, i el seu index
# Dona prioritat a v3 sobre v1 i v1 sobre v2
sub max3 {
    my ($v1, $v2, $v3, $c1, $c2, $c3) = @_;

    if (majorIgPar($v1,$c1, $v2,$c2)) {
	return ($v1, 1, $c1) if majorPar($v1,$c1, $v3,$c3);

    } else {
	return ($v2, 2, $c2) if majorPar($v2,$c2, $v3,$c3);
    }

    return ($v3, 3, $c3);
}


# Funció que retorna el minim de 3 valors numèrics, i el seu index
# Dona prioritat a v3 sobre v1 i v1 sobre v2
sub min3 {
    my ($v1, $v2, $v3, $c1, $c2, $c3) = @_;

    if (!majorPar($v1,$c1, $v2,$c2)) {
	return ($v1, 1, $c1) if !majorIgPar($v1,$c1, $v3,$c3);

    } else {
	return ($v2, 2, $c2) if !majorIgPar($v2,$c2, $v3,$c3);
    }

    return ($v3, 3, $c3);
}


##########################
# Maxim/Minim de 3 reals #
##########################

# Funció que retorna el maxim de 3 valors numèrics, i el seu index
# Dona prioritat a v3 sobre v1 i v1 sobre v2
sub max3s {
    my ($v1, $v2, $v3) = @_;

    if ($v1 >= $v2) {
	return $v1 if $v1 > $v3;

    } else {
	return $v2 if $v2 > $v3;
    }
    
    return $v3;
}


# Funció que retorna el minim de 3 valors numèrics, i el seu index
# Dona prioritat a v3 sobre v1 i v1 sobre v2
sub min3s {
    my ($v1, $v2, $v3) = @_;

    if ($v1 <= $v2) {
	return $v1 if $v1 < $v3;

    } else {
	return $v2 if $v2 < $v3;
    }
    
    return $v3;
}


# Retornem Cert

1;
