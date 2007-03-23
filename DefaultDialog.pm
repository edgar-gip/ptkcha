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

use strict;

use Tk;
use Tk::DialogBox;
use Tk::Pane;

use Forwarder;

# Classe DefaultDialog
package DefaultDialog;
our @ISA = qw( Forwarder );

# Constructor
sub new {
    my ($classe, $pare, $marcatge) = @_;

    my $atribs = $marcatge->getAtributs();
    return undef unless @{$atribs};
    
    my $dialog =
	$pare->DialogBox(-title => 'Default Values',
			 -buttons => [ 'Ok' ]);

    my $panell =
	$dialog->add('Scrolled', 'Frame',
		     -scrollbars => 'e')
	->pack(-fill => 'both', -expand => 1)
	->Subwidget('scrolled');

    my @llista;
    my $i = 0;
    foreach my $atr (@{$atribs}) {
	my $etiqueta = $panell->Label(-text => $atr->[0])
	    ->grid(-column => 0, -row => $i, -sticky => 'ne');
	my @valors = @{$atr}[1..$#{$atr}];
	my $combo = $panell->BrowseEntry(-state => 'readonly',
					 -choices => \@valors,
					 -variable => \$llista[$i])
	    ->grid(-column => 1, -row => $i, -sticky => 'nw');
	$llista[$i] = $valors[0];
	++$i;
    }
    
    my $this = [ $dialog, \@llista ];
    return bless($this, $classe);
}


# Obtenir valor
sub getValor { return $_[0]->[1][$_[1]]; }

# Obtenir
sub getAllValors { return @{$_[0]->[1]}; }

# Retornem Cert
1;
