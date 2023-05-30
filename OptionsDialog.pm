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

# Crear un Nou Projecte

use strict;

use Tk;
use Tk::DialogBox;

use ConfigFile;

package OptionsDialog;

# Constructor
sub new {
    my ($classe, $pare) = @_;

    # Cridem al constructor del dialeg
    my $dialeg = $pare->DialogBox(-title => 'Options',
                                  -buttons => [ "OK", 'Cancel' ]);

    # Objecte this
    my $this = [ $dialeg, '', '', '', '', 'txt' ];

    # Construïm el contingut del Dialeg
    my $panell = $dialeg->add('Frame')->pack();

    $panell->Label(-text => 'Selection Expansion: ')
        ->grid(-column => 0, -row => 0, -sticky => 'nw');
    $panell->Checkbutton(-width => 40, -variable => \$this->[1])
        ->grid(-column => 1, -row => 0, -sticky => 'new');
    $panell->Label(-text => 'Forced Writing: ')
        ->grid(-column => 0, -row => 1, -sticky => 'nw');
    $panell->Checkbutton(-width => 40, -variable => \$this->[2])
        ->grid(-column => 1, -row => 1, -sticky => 'new');
    $panell->Label(-text => 'Include Directories: ')
        ->grid(-column => 0, -row => 2, -columnspan => 2, -sticky => 'nw');
    $panell->Entry(-width => 50, -textvariable => \$this->[3])
        ->grid(-column => 0, -row => 3, -columnspan => 2, -sticky => 'new');

    return bless($this, $classe);
}

sub actualitzar {
    my ($this, $config) = @_;

    # Assignem a les Variables
    $this->[1] = $config->{'SelExp'};
    $this->[2] = $config->{'ForWri'};
    $this->[3] = $config->{'IncDir'};
}

sub Show {
    my ($this) = @_;

    return $this->[0]->Show();
}

sub getResults {
    my ($this, $config) = @_;

    $config->{'SelExp'} = $this->[1];
    $config->{'ForWri'} = $this->[2];
    $config->{'IncDir'} = $this->[3];
}

# Retornem Cert
1;
