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

# Dialeg Dependencies

use Tk;
use Tk::DialogBox;

use Forwarder;

package DialegLlista;

our @ISA = qw( Forwarder );

# constructor
sub new {
    my ($classe, $finestraPare, $titol, $ample, $botons) = @_;
    $ample  ||= 30;
    $botons ||= [ "Ok" ];

    my $dialog =
        $finestraPare->DialogBox(-title => $titol,
                                 -buttons => $botons );
    my $llista = $dialog->add('Scrolled', 'Listbox',
                              -scrollbars => 'e',
                              -selectmode => 'single',
                              -width => $ample)
        ->pack(-fill => 'both', -expand => 1)
        ->Subwidget('scrolled');

    my $this = [ $dialog, $llista ];
    return bless($this, $classe);
}

# Netejar la llista
sub netejarLlista {
    my ($this) = @_;

    $this->[1]->delete(0, 'end');
}

# Afegir element
sub afegirElement {
    my ($this, $cadena) = @_;

    $this->[1]->insert('end', $cadena);
}

# Retornem Cert
1;
