# Copyright (C) 2005-2011  Edgar Gonzàlez i Pellicer
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

# Alineador de les marques XML de dos documents
# no tenen perquè ser iguals

use strict;

use DynAlign::ComplexAlign;

package Alineador;

# constructor
sub new {
    my ($classe) = @_;

    # L'unic que té és un ComplexAlign i el callback
    my $cplx = new ComplexAlign();
    return bless([ $cplx, undef, 0 ], $classe);
}

# Alinear els tags d'un text amb un altre de no taggejat
# Retorna el segon text alineat
sub alinear {
    my ($this, $text1, $text2) = @_;

    my @llista1 = splitAmbTags($text1);
    my @llista2 = splitSenseTags($text2);

    my @marquesDeTags = ();
    my @llista1Neta   = ();
    my $j = 0;
    for (my $i = 0; $i < @llista1; $i++) {
        if ($llista1[$i] =~ /^\s?\<.+\>\s?$/) { # Es un tag
            # Afegim la parella <tag> <posicio>
            push(@marquesDeTags, $llista1[$i], $j);
        } else {
            push(@llista1Neta, $llista1[$i]);
            ++$j;
        }
    }

    # print join('/', @llista1Neta), "\n", join('/', @llista2), "\n";

    my ($punts, $listOut1, $listOut2, $skip1, $skip2, $mis) =
        $this->[0]->alinear(\@llista1Neta, \@llista2);

    # Reconstruim
    my $sortida = '';
    my ($j, $i) = (0, 0);
    my $calEspai = 0;
    for ($i = 0; @marquesDeTags && $i < @{$listOut1};) {
        if ($marquesDeTags[1] == $j && defined($listOut1->[$i])) {
            $sortida .= $marquesDeTags[0];
            $calEspai = 0;
            shift(@marquesDeTags);
            shift(@marquesDeTags);

        } else {
            if (defined($listOut2->[$i])) {
                $sortida .= ' ' if $calEspai;
                $sortida .= $listOut2->[$i];
                $calEspai = 1;
            }

            ++$j if defined($listOut1->[$i]);
            ++$i;
        }
    }

    # Han quedat mots o marques
    if (@marquesDeTags) {
        while (@marquesDeTags) {
            $sortida .= shift(@marquesDeTags);
            shift(@marquesDeTags);
        }
    } else {
        while ($i < @{$listOut2}) {
            if (defined($listOut2->[$i])) {
                $sortida .= ' ' if $calEspai;
                $sortida .= $listOut2->[$i];
                $calEspai = 1;
            }
            ++$i;
        }
    }

    return $sortida;
}

# Split amb tags
sub splitAmbTags {
    my ($cadena) = @_;

    my @resultat = ();

    # Eliminem els "\n"
    $cadena =~ s/\n/ /g;

    # Anem fent
    while ($cadena =~ /\s?\<[^\>]+\>\s?/) {
        push(@resultat, split(' ', $`));
        push(@resultat, $&);
        $cadena = $';
    }

    push(@resultat, split(' ', $cadena));

    return @resultat;
}

# Split sense Tags
sub splitSenseTags {
    my ($cadena) = @_;

    # Eliminem els "\n"
    $cadena =~ s/\n/ /g;

    # Anem fent
    return split(' ', $cadena);
}

# Set Callback
sub setCallback {
    my ($this, $callback, $fraccio) = @_;

    $this->[0]->setCallback($callback, $fraccio);
}

# Retornem cert
1;
