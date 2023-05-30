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

# Panell amb Informacio sobre el Projecte

use strict;

use Tk;
use Forwarder;

package InfoProject;

our @ISA = qw( Forwarder );

# Constructor
sub new {
    my ($classe, $main, $pare) = @_;

    # Creem el this
    my $this;

    # Omplim el Panell Superior
    my $frame = $pare->Frame();

    # First label
    $frame->Label(-text => 'Project: ')
        ->grid(-column => 0, -row => 0, -sticky => 'ne');
    my $entryPrjk = $frame->Entry(-width => 50,  -state => 'disabled')
        ->grid(-column => 1, -row => 0, -sticky => 'nw');
    $frame->Label(-text => 'Input Dir: ')
        ->grid(-column => 0, -row => 1, -sticky => 'ne');
    my $entryDirIn = $frame->Entry(-width => 50, -state => 'disabled')
        ->grid(-column => 1, -row => 1, -sticky => 'nw');
    $frame->Label(-text => 'Output Dir: ')
        ->grid(-column => 0, -row => 2, -sticky => 'ne');
    my $entryDirOut = $frame->Entry(-width => 50, -state => 'disabled')
        ->grid(-column => 1, -row => 2, -sticky => 'nw');
    $frame->Label(-text => 'Marking: ')
        ->grid(-column => 0, -row => 3, -sticky => 'ne');
    my $entryMarcat = $frame->Entry(-width => 50, -state => 'disabled')
        ->grid(-column => 1, -row => 3, -sticky => 'nw');
    $frame->Label(-text => 'Extension: ')
        ->grid(-column => 0, -row => 4, -sticky => 'ne');
    my $entryExten = $frame->Entry(-width => 50, -state => 'disabled')
        ->grid(-column => 1, -row => 4, -sticky => 'nw');

    my $selector = $frame->BrowseEntry(-state => 'disabled',
                                       -browsecmd => sub { $this->select() })
        ->grid(-column => 2, -row => 1, -sticky => 'new', -padx => 5);

    my $entryMots = $frame->Entry(-width => 20, -state => 'disabled')
        ->grid(-column => 2, -row => 2, -sticky => 'new');

    # Omplim el this
    $this = [ $frame, $main, $selector, '', '', '', '', '', '', '',
              $entryPrjk,   $entryDirIn, $entryDirOut,
              $entryMarcat, $entryMots,  $entryExten ];
    my $base = 3;

    # Actualitzem destins
    $entryPrjk  ->configure(-textvariable => \$this->[0 + $base]);
    $entryDirIn ->configure(-textvariable => \$this->[1 + $base]);
    $entryDirOut->configure(-textvariable => \$this->[2 + $base]);
    $entryMarcat->configure(-textvariable => \$this->[3 + $base]);
    $selector   ->configure(-variable     => \$this->[4 + $base]);
    $entryMots  ->configure(-textvariable => \$this->[5 + $base]);
    $entryExten ->configure(-textvariable => \$this->[6 + $base]);

    return bless($this, $classe);
}

# Actualitzar
sub actualitzar {
    my ($this, $projecte) = @_;

    # Enable
    map { $_->configure(-state => 'normal') } @{$this}[10..13,15];

    # Atributs
    @{$this}[3..6] = @{$projecte}[0..3];
    $this->[9]     = $projecte->[7];

    # Read Only
    map { $_->configure(-state => 'readonly') } @{$this}[10..13,15];

    # Activem el selector
    $this->[2]->configure(-state => 'readonly');

    # Fitxers Disponibles
    my @fitxers = $projecte->getFiles();
    $this->[2]->configure(-choices => \@fitxers);

    # Establim el primer text
    if (@fitxers) {
        $this->[1]->select($fitxers[0], 'no_save');
        $this->[7] = $fitxers[0];
    } else {
        $this->[1]->select('', 'no_save');
        $this->[7] = '';
    }
}

# Canviat
sub select {
    my ($this) = @_;

    # Forward cap a la interficie
    $this->[1]->select($this->[7]);
}

# Assignar Nombre de mots
sub setNombreMots {
    my ($this, $n) = @_;

    $this->[14]->configure(-state => 'normal');
    $this->[8] = "$n words";
    $this->[14]->configure(-state => 'readonly');
}

# Retornem Cert
1;
