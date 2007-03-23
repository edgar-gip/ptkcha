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

# Dialeg d'Alineament de Projectes

use strict;

use Tk;
use Tk::DialogBox;

use Forwarder;
use Projecte;

package DialegAlineament;

our @ISA = qw( Forwarder );


# Constructor
# Atributs
###########
# 0: Dialeg
# 1: projecte/directori
# 2: combo projecte
# 3: projecte escollit
# 4: combo format
# 5: entry directori
# 6: nom directori
# 7: botoDir
# 8: extensio escollit
# 9: entry fitxer
#10: nom fitxer
#11: boto fitxer

sub new {
    my ($classe, $pare) = @_;

    # Dialeg
    my $dialeg = $pare->DialogBox(-title => 'Alignment',
				  -buttons => [ "OK", 'Cancel' ]);
    
    # This
    my $this = [ $dialeg ];

    # Etiqueta
    $dialeg->add('Label', -text => 'Align with...')
	->pack(-side => 'top', -fill => 'x', -expand => 1, -padx => 2, -pady => 2);

    # Frame Superior
    my $frame1 = $dialeg->add('Frame',
			      -borderwidth => 2,
			      -relief => 'groove')
	->pack(-side => 'top', -fill => 'both', -expand => 1, -padx => 2, -pady => 2);
    my $radio1 = $frame1->Radiobutton(-text => 'Project',
				      -anchor => 'w',
				      -value => 'projecte',
				      -command => sub { $this->setMode() })
	->grid(-row => 0, -column => 0, -sticky => 'w');
    my $combo1 = $frame1->BrowseEntry(-state => 'readonly')
	->grid(-row => 1, -column => 0, -sticky => 'new');

    # Frame Inferio
    my $frame2 = $dialeg->add('Frame',
			      -borderwidth => 2,
			      -relief => 'groove')
	->pack(-side => 'top', -fill => 'both', -expand => 1, -padx => 2, -pady => 2);
    my $radio2 = $frame2->Radiobutton(-text => 'Directory',
				      -anchor => 'w',
				      -value => 'directori',
				      -command => sub { $this->setMode() })
	->grid(-row => 0, -column => 0, -sticky => 'nw');
    my $entry = $frame2->Entry(-width => 40,
			       -state => 'disabled')
	->grid(-row => 1, -column => 0, -sticky => 'nw');
    my $boto = $frame2->Button(-text => '...',
			       -command => sub { $this->triarDirectori() },
			       -state => 'disabled')
	->grid(-row => 1, -column => 1, -sticky => 'ne');
    my $combo2 = $frame2->BrowseEntry(-label => 'Extension',
				      -choices => [ '.txt', '.xml', '.sum', '<none>' ],
				      -state => 'disabled')
	->grid(-row => 2, -column => 0, -columnspan => 2, -sticky => 'new');
    

    # Tercer frame
    my $frame3 = $dialeg->add('Frame',
			      -borderwidth => 2,
			      -relief => 'groove')
	->pack(-side => 'top', -fill => 'both', -expand => 1, -padx => 2, -pady => 2);
    my $radio3 = $frame3->Radiobutton(-text => 'File',
				      -anchor => 'w',
				      -value => 'fitxer',
				      -command => sub { $this->setMode() })
	->grid(-row => 0, -column => 0, -sticky => 'nw');
    my $entryF = $frame3->Entry(-width => 40,
				-state => 'disabled')
	->grid(-row => 1, -column => 0, -sticky => 'nw');
    my $botoF  = $frame3->Button(-text => '...',
				 -command => sub { $this->triarFitxer() },
				 -state => 'disabled')
	->grid(-row => 1, -column => 1, -sticky => 'ne');
    

    # Afegim atributs
    push(@{$this}, 'projecte', $combo1,
	 '', $combo2, $entry, 
	 '', $boto, '',
	 $entryF, '', $botoF);

    # Radios
    $radio1->configure(-variable => \$this->[1]);
    $radio2->configure(-variable => \$this->[1]);
    $radio3->configure(-variable => \$this->[1]);

    # Combos i entries
    $combo1->configure(-variable => \$this->[3]);
    $entry->configure(-textvariable => \$this->[6]);
    $combo2->configure(-variable => \$this->[8]);
    $entryF->configure(-textvariable => \$this->[10]);

    # Retornem
    return bless($this, $classe);
}


# Actualitzar
sub actualitzar {
    my ($this, $main) = @_;

    my $i = 0;
    my @projs = map { (++$i).": ".($_->getNom()) } @{$main->getProjectManager()};
    $this->[3] = $projs[0];
    $this->[2]->configure(-choices => \@projs);
}


# Triar el directori
sub triarDirectori {
    my ($this) = @_;

    my $vInicial = $this->[6];
    
    my $result;
    $result = $this->[0]->DirSelect(-title => 'Directory')->Show($vInicial);

    if ($result) {
	$this->[6] = $result;
    }
}


# Triar el fitxer
sub triarFitxer {
    my ($this) = @_;

    my $vInicial = $this->[10];
 
    my $result;
    if ($vInicial =~ /(.+\/)[^\/]*$/) { # Es 'file' relatiu
	$result = $this->[0]->FileSelect(-directory => $1)->Show();
	
    } else {
	$result = $this->[0]->FileSelect(-directory => '.')->Show();
    }
    
    if ($result) {
	$this->[10] = $result;
    }
}


# Canvia la radio
sub setMode {
    my ($this) = @_;

    if ($this->[1] eq 'projecte') {
	$this->[2]->configure(-state => 'readonly');
	$this->[4]->configure(-state => 'disabled');
	$this->[5]->configure(-state => 'disabled');
	$this->[7]->configure(-state => 'disabled');
	$this->[9]->configure(-state => 'disabled');
	$this->[11]->configure(-state =>'disabled');

    } elsif ($this->[1] eq 'directori') {
	$this->[2]->configure(-state => 'disabled');
	$this->[4]->configure(-state => 'normal');
	$this->[5]->configure(-state => 'normal');
	$this->[7]->configure(-state => 'normal');
	$this->[9]->configure(-state => 'disabled');
	$this->[11]->configure(-state =>'disabled');
	
    } else { #this->[1] eq 'fitxer'
	$this->[2]->configure(-state => 'disabled');
	$this->[4]->configure(-state => 'disabled');
	$this->[5]->configure(-state => 'disabled');
	$this->[7]->configure(-state => 'disabled');
	$this->[9]->configure(-state => 'normal');
	$this->[11]->configure(-state =>'normal');
    }


}


# Retornem Cert
1;

