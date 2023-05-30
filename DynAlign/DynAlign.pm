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

# Alineador amb programació Dinàmica

use strict;

use DynAlign::DefaultCompare;
use DynAlign::Maxims;

package DynAlign;

use vars qw( $defaultComp );

# Funció de Comparació per Defecte
$defaultComp = new DefaultCompare();

# Constructor
sub new {
    my ($classe, $comp) = @_;

    # Valors per Defecte
    $comp = $defaultComp if !defined($comp);

    return bless([ $comp, undef, 0 ], $classe);
}

# Callback
sub setCallback {
    my ($this, $rutina, $fraccio) = @_;

    $this->[1] = $rutina;
    $this->[2] = $fraccio;
}

# Alinear dues llistes
#
# Retorna la puntuació i les dues llistes alineades
# (amb undef a les posicions a saltar)
# aixi com el nombre de misAligns, skips1 i skip2
# en el cas que es cridi en context de llista
sub alinear {
    my ($this, $llista1, $llista2, $mode) = @_;

    # Atributs per defecte
    $mode = 'max' if !defined($mode);

    # Si estem en context escalar, cridem la funcio especifica
    if (!wantarray()) {
        return $this->alinearEscalar($llista1, $llista2, $mode);
    }

    my $funcioDecisio;
    if ($mode eq 'max') {
        $funcioDecisio = \&Maxims::max3;
    } elsif ($mode eq 'min') {
        $funcioDecisio = \&Maxims::min3;
    } else {
        die 'Mode de Treball Incorrecte';
    }

    # Atributs de l'Objecte
    my ($func) = @{$this};

    # Mida de les llistes
    my ($mida1, $mida2) = ($#{$llista1}+1, $#{$llista2}+1);

    # Matriu de Valors
    my $matrix1 = [ [ ] ];

    # Matriu de Recorregut (1 = Dreta, 2 = Avall, 3 = Diagonal)
    my $matrix2 = [ [ ] ];

    # Matriu de Coincidencies
    my $matrix3 = [ [ ] ];

    # Construim les matrius
    my ($i, $j);

    # Countdown
    my $periode   = $mida2 * $this->[2];
    my $countdown = $periode - 1;
    my $callback  = $this->[1];
    my $nPeriode  = 0;

    # Primera Filera
    $matrix1->[0][0] = 0;
    $matrix2->[0][$i] = 1;
    $matrix3->[0][$i] = 0;

    for ($i = 0; $i < $mida1; ++$i) {
        $matrix1->[0][$i+1] = $matrix1->[0][$i]
            + $func->skip($llista1->[$i]);
        $matrix2->[0][$i+1] = 1;
        $matrix3->[0][$i+1] = 0;
    }

    # Auxiliars
    my ($v1,$v2,$v3,$c1,$c2,$c3,$millorv,$dirv,$coinsv);
    my ($moti, $motj);

    # Bucle Principal
    for ($j = 0; $j < $mida2; ++$j) {
        $motj = $llista2->[$j];

        $matrix1->[$j+1][0] = $matrix1->[$j][0]
            + $func->skip($motj);
        $matrix2->[$j+1][0] = 2;
        $matrix3->[$j+1][0] = 0;

        for ($i = 0; $i < $mida1; ++$i) {
            $moti = $llista1->[$i];

            $v1 = $matrix1->[$j+1][$i] + $func->skip($moti);
            $v2 = $matrix1->[$j][$i+1] + $func->skip($motj);
            $v3 = $matrix1->[$j][$i] +
                $func->aplicar($moti, $motj);

            $c1 = $matrix3->[$j+1][$i];
            $c2 = $matrix3->[$j][$i+1];
            $c3 = $matrix3->[$j][$i];
            $c3 += 1 unless $func->esMisAlign($moti, $motj);

            ($millorv, $dirv, $coinsv) =
                &{$funcioDecisio}($v1, $v2, $v3,
                                  $c1, $c2, $c3);

            $matrix1->[$j+1][$i+1] = $millorv;
            $matrix2->[$j+1][$i+1] = $dirv;
            $matrix3->[$j+1][$i+1] = $coinsv;
        }

        if ($callback && --$countdown < 0) {
            &{$callback}(++$nPeriode);
            $countdown += $periode;
        }
    }

    # Mostrar Matriu
    # mostrarMatrix($matrix1, 10);

    # Guardem el Resultat
    my $resultat = $matrix1->[$mida2][$mida1];

    # Alliverem la memoria de les matrius
    $matrix1 = 0;
    $matrix3 = 0;

    # Comptatge
    my ($skip1, $skip2, $misAlign) = (0, 0, 0);

    # Construïm el retorn
    my @align1 = ();
    my @align2 = ();

    ($j, $i) = ($mida2, $mida1);
    while ($i != 0 || $j != 0) {
        my $actual = $matrix2->[$j][$i];

        if ($actual == 1) {
            # Hem d'anar a l'esquerra, skip consumint llista 1
            push(@align1, $llista1->[--$i]);
            push(@align2, undef);
            ++$skip1;

        } elsif ($actual == 2) {
            # Hem d'anar amunt, skip consumint llista 2
            push(@align1, undef);
            push(@align2, $llista2->[--$j]);
            ++$skip2;

        } else {
            # En diagonal consumint ambdues
            push(@align1, $llista1->[--$i]);
            push(@align2, $llista2->[--$j]);

            ++$misAlign
                if $func->esMisAlign($llista1->[$i], $llista2->[$j]);
        }
    }

    # Invertim les llistes
    my @ralign1 = reverse(@align1);
    my @ralign2 = reverse(@align2);

    # Ja hem acabat
    &{$callback}('END') if $callback;

    # Retornem
    return ($resultat, \@ralign1, \@ralign2, $skip1, $skip2, $misAlign);
}

# Alinear dues llistes
#
# Versio Escalar: Nomes retorna la puntuacio
sub alinearEscalar {
    my ($this, $llista1, $llista2, $mode) = @_;

    my $funcioDecisio;
    if ($mode eq 'max') {
        $funcioDecisio = \&Maxims::max3s;
    } elsif ($mode eq 'min') {
        $funcioDecisio = \&Maxims::min3s;
    } else {
        die 'Mode de Treball Incorrecte';
    }

    # Atributs de l'Objecte
    my ($func) = @{$this};

    # Mida de les llistes
    my ($mida1, $mida2) = ($#{$llista1}+1, $#{$llista2}+1);

    # Matriu de Valors
    my $matrix1 = [ [ ] ];

    # Construim la matriu
    my ($i, $j);

    # Countdown
    my $periode   = $mida2 * $this->[2];
    my $countdown = $periode - 1;
    my $callback  = $this->[1];
    my $nPeriode  = 0;

    # Primera Filera
    $matrix1->[0][0] = 0;

    for ($i = 0; $i < $mida1; ++$i) {
        $matrix1->[0][$i+1] = $matrix1->[0][$i]
            + $func->skip($llista1->[$i]);
    }

    # Auxiliars
    my ($v1,$v2,$v3);
    my ($moti, $motj);

    # Bucle Principal
    for ($j = 0; $j < $mida2; ++$j) {
        $motj = $llista2->[$j];

        $matrix1->[$j+1][0] = $matrix1->[$j][0]
            + $func->skip($motj);

        for ($i = 0; $i < $mida1; ++$i) {
            $moti = $llista1->[$i];

            $v1 = $matrix1->[$j+1][$i] + $func->skip($moti);
            $v2 = $matrix1->[$j][$i+1] + $func->skip($motj);
            $v3 = $matrix1->[$j][$i] +
                $func->aplicar($moti, $motj);

            $matrix1->[$j+1][$i+1] = &{$funcioDecisio}($v1, $v2, $v3);
        }

        if ($callback && --$countdown < 0) {
            &{$callback}(++$nPeriode);
            $countdown += $periode;
        }
    }

    # Mostrar la Matriu
    # mostrarMatrix($matrix1);

    # Ja hem acabat!
    &{$callback}('END') if $callback;

    # Retornem el Resultat
    return $matrix1->[$mida2][$mida1];
}

# Mostrar la matriu
sub mostrarMatrix {
    my ($matrix, $num) = @_;

    # Per a cada filera...
    map {
        # ...escribim cada columna
        map { print "$_ "; }  @{$_}[0..$num];
        print "\n";

    } @{$matrix}[0..$num];
}

# Retornem Cert
1;
