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

# Alineador Complex

use strict;

use DynAlign::DynAlign;
use DynAlign::DefaultCompare;
use DynAlign::MEDCompare;

package ComplexAlign;

use vars qw( @ISA );
@ISA = qw( DynAlign );

# Constructor
sub new {
    my ($classe) = @_;

    # Funcio de comparacio
    my $funcio = new DefaultCompareNoCase(0,1,1);

    # Heretem el constructor de DynAlign
    my $this = DynAlign::new($classe, $funcio);

    # A part, afegim un alineador per a dur a terme el MED
    my $alignFill = new DynAlign(new MEDCompare());

    # L'afegim a l'objecte
    push(@{$this}, $alignFill, $funcio);

    return $this;
}

# Alinear
# Alinear dues llistes
#
# Retorna la puntuació i les dues llistes alineades
# (amb undef a les posicions a saltar)
# aixi com el nombre de misAligns, skips1 i skip2
# en el cas que es cridi en context de llista

sub alinear {
    my ($this, $llista1, $llista2) = @_;

    # Si estem en context escalar, cridem la funcio especifica
    # (L'heretem de DynAlign)
    if (!wantarray()) {
        return $this->alinearEscalar($llista1, $llista2, 'min');
    }

    # Si no, comencem cridant la versio que hem heretat
    # -> Busquem mínim WER
    my ($resultat, $l1, $l2) =
        $this->DynAlign::alinear($llista1, $llista2, 'min');

    # A continuació, busquem alineaments en MED
    my (@seccio1, @seccio2);
    my $medAligner = $this->[3];
    my $funcioCmp  = $this->[4];

    # Els comptadors que teniem no son bons
    my ($skip1, $skip2, $misAlign) = (0, 0, 0, 0);

    my @out1 = ();
    my @out2 = ();

    my $pos = 0;
    my $mida = @{$l1};

    # print STDERR (join('/',@{$l1}), "\n", join('/',@{$l2}));

    # Aqui tambe fem callback
    my $periode   = $mida * $this->[2];
    my $countdown = $periode;
    my $callback  = $this->[1];
    my $nPeriode  = 0;

    while ($pos < $mida) {
        my ($mot1, $mot2) = ($l1->[$pos], $l2->[$pos]);

        # Comprovem els 2 mots...
        if (!defined($mot1)) {
            # Afegim a la seccio

            # print STDERR "Saltem ASR: $mot2\n";
            push(@seccio2, $mot2);

        } elsif (!defined($mot2)) {
            # Afegim a la seccio

            # print STDERR "Saltem Real: $mot1\n";
            push(@seccio1, $mot1);

        } elsif ($funcioCmp->esMisAlign($mot1, $mot2)) {
            # Afegim a les seccions

            # print STDERR "Saltem Ambdos: $mot1/$mot2\n";
            push(@seccio1, $mot1);
            push(@seccio2, $mot2);

        } else {
            # Son iguals -> Sincronitzacio
            # Cal alinear el que tinguessim darrere
            if (@seccio1 && @seccio2) {
                # Hi ha alguna cosa
                # Busquem el subcami de minima MED

                # print STDERR ("Alineem: (",
                #             join(' ', @seccio1), ") i (",
                #             join(' ', @seccio2), ")\n");

                my ($vret, $lt1, $lt2, $sk1, $sk2, $mis) =
                    $medAligner->alinear(\@seccio1, \@seccio2, 'min');

                # Afegim a les llistes que portavem fins ara
                push(@out1, @{$lt1});
                push(@out2, @{$lt2});

                # Actualitzem comptadors
                $skip1 += $sk1;
                $skip2 += $sk2;
                $misAlign += $mis;

                # Netejem les seccions
                @seccio1 = ();
                @seccio2 = ();

            } elsif (@seccio1) {
                # Hi ha hagut un seguit de delecions
                push(@out1, @seccio1);
                push(@out2, (undef) x @seccio1);

                $skip1 += @seccio1;
                @seccio1 = ();

            } elsif (@seccio2) {
                # Hi ha hagut un seguit d'insercions
                push(@out2, @seccio2);
                push(@out1, (undef) x @seccio2);

                $skip2 += @seccio2;
                @seccio2 = ();
            }

            #print STDERR "Sincronitzem a: $mot1/$mot2\n";

            # Afegim l'element igual a les llistes
            push(@out1, $mot1);
            push(@out2, $mot2);
        }
        $pos++;

        if ($callback && --$countdown < 0) {
            &{$callback}(++$nPeriode);
            $countdown += $periode;
        }
    }

    # Mirem la darrera seccio
    if (@seccio1 && @seccio2) {
        # Hi ha alguna cosa
        # Busquem el subcami de minima MED
        my ($vret, $lt1, $lt2, $sk1, $sk2, $mis) =
            $medAligner->alinear(\@seccio1, \@seccio2, 'min');

        # Afegim a les llistes que portavem fins ara
        push(@out1, @{$lt1});
        push(@out2, @{$lt2});

        # Actualitzem comptadors
        $skip1 += $sk1;
        $skip2 += $sk2;
        $misAlign += $mis;

    } elsif (@seccio1) {
        # Hi ha hagut un seguit de delecions
        push(@out1, @seccio1);
        push(@out2, (undef) x @seccio1);

        $skip1 += @seccio1;

    } elsif (@seccio2) {
        # Hi ha hagut un seguit d'insercions
        push(@out2, @seccio2);
        push(@out1, (undef) x @seccio2);

        $skip2 += @seccio2;
    }

    # Hem acabat!
    &{$callback}('END') if $callback;

    my $nouResultat = $skip1 + $skip2 + $misAlign;
    # print STDERR "$resultat/$nouResultat\n";

    return ($nouResultat, \@out1, \@out2, $skip1, $skip2, $misAlign);
}
