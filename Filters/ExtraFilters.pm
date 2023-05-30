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

# Built-in filters
# Extra Ones

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
                    $this->[0] .= "$afegit " if $afegit;
                }

                $linia = $';
                $this->[1] = 1;

            } else {
                $afegit = $this->eliminarMarques($linia, $noPunct);
                $this->[0] .= "$afegit " if $afegit;
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

    $this->Filters::FilterUtf::filterLine($line, 1);
}

#############
# Via Voice #
#############

package Filters::FilterVia;

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

    $this->[0] .= $cadena;
}

# Return true
1;
