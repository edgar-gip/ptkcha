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

# Dialeg amb informacio d'un projecte

use strict;

use Tk::DirSelect;
use Tk::FileSelect;

package ProjectDialog;

our @ISA = qw( Forwarder );

# Constructor
sub new {
    my ($classe, $pare, $project) = @_;

    # Cridem al constructor del dialeg
    my $dialeg = $pare->DialogBox(-title => 'Project',
				  -buttons => [ "OK", 'Cancel' ]);
    
    # Objecte this
    my $this = [ $dialeg, '', '', '', '', 'txt', 'txt' ];
    
    # Construïm el contingut del Dialeg
    my $status = $dialeg->add('Label')->pack(-side => 'top');
    my $panell = $dialeg->add('Frame')->pack(-side => 'top');

    $panell->Label(-text => 'Name: ')
	->grid(-column => 0, -row => 0, -sticky => 'ne');
    my $eName = $panell->Entry(-width => 40, -textvariable => \$this->[1])
	->grid(-column => 1, -row => 0, -sticky => 'new');

    $panell->Label(-text => 'Input Directory: ')
	->grid(-column => 0, -row => 1, -sticky => 'ne');
    my $eInDir = $panell->Entry(-width => 40, -textvariable => \$this->[2])
	->grid(-column => 1, -row => 1, -sticky => 'new');
    $panell->Button(-text => '...', -command => sub { $this->canvi(2, "Input Directory", 'dir') })
	->grid(-column => 2, -row => 1, -sticky => 'nw');

    $panell->Label(-text => 'Output Directory: ')
	->grid(-column => 0, -row => 2, -sticky => 'ne');
    my $eOutDir = $panell->Entry(-width => 40, -textvariable => \$this->[3])
	->grid(-column => 1, -row => 2, -sticky => 'new');
    $panell->Button(-text => '...', -command => sub { $this->canvi(3, 'Output Directory', 'dir') })
	->grid(-column => 2, -row => 2, -sticky => 'nw');

    $panell->Label(-text => 'Marking: ')
	->grid(-column => 0, -row => 3, -sticky => 'ne');
    my $eMark = $panell->Entry(-width => 40, -textvariable => \$this->[4])
	->grid(-column => 1, -row => 3, -sticky => 'new');
    $panell->Button(-text => '...', -command => sub { $this->canvi(4, 'Marking', 'file') })
	->grid(-column => 2, -row => 3, -sticky => 'nw');

    my $filters = [ $Projecte::filterManager->getFilters() ];
    $panell->Label(-text => 'Format: ')
	->grid(-column => 0, -row => 4, -sticky => 'ne');
    my $beFilt = $panell->BrowseEntry(-state => 'readonly', -choices => $filters,
				      -variable => \$this->[5])
	->grid(-column => 1, -row => 4, -sticky => 'new');
    $beFilt->Subwidget('entry')
	->configure(-disabledforeground => 'black');
    
    $panell->Label(-text => 'File Extension: ')
	->grid(-column => 0, -row => 5, -sticky => 'ne');
    my $eExten = $panell->Entry(-width => 40, -textvariable => \$this->[6])
	->grid(-column => 1, -row => 5, -sticky => 'new');
    
    if ($project) {
	my $err = $project->getStatus();
	
	# Clear sub
	my $clearSub = sub { $status->configure(-text => '') };

	# Name
	$this->[1] = $project->getNom();
	if ($err & $Projecte::ERR_NAME) {
	    $eName->configure(-background => 'salmon');
	    $eName->bind('<Enter>', sub { $status->configure(-text => $Projecte::messages{$err & $Projecte::ERR_NAME}) });
	    $eName->bind('<Leave>', $clearSub);
	}

	# Input dir
	$this->[2] = $project->getDirIn();
	if ($err & $Projecte::ERR_INPUT) {
	    $eInDir->configure(-background => 'salmon');
	    $eInDir->bind('<Enter>', sub { $status->configure(-text => $Projecte::messages{$err & $Projecte::ERR_INPUT}) });
	    $eInDir->bind('<Leave>', $clearSub);
	}

	# Output dir
	$this->[3] = $project->getDirOut();
	if ($err & $Projecte::ERR_OUTPUT) {
	    $eOutDir->configure(-background => 'salmon');
	    $eOutDir->bind('<Enter>', sub { $status->configure(-text => $Projecte::messages{$err & $Projecte::ERR_OUTPUT}) });
	    $eOutDir->bind('<Leave>', $clearSub);
	}

	# Marking
	$this->[4] = $project->getMarcFile();
	if ($err & $Projecte::ERR_MARK) {
	    $eMark->configure(-background => 'salmon');
	    $eMark->bind('<Enter>', sub { $status->configure(-text => $Projecte::messages{$err & $Projecte::ERR_MARK}) });
	    $eMark->bind('<Leave>', $clearSub);
	}

	# Filter
	$this->[5] = $project->getFiltName();
	if ($err & $Projecte::ERR_FILTER) {
	    $beFilt->Subwidget('entry')
		->configure(-disabledbackground => 'salmon');
	    $beFilt->bind('<Enter>', sub { $status->configure(-text => $Projecte::messages{$err & $Projecte::ERR_FILTER}) });
	    $beFilt->bind('<Leave>', $clearSub);
	}

	# Exten
	$this->[6] = $project->getExtens();
	if ($err & $Projecte::ERR_EXTEN) {
	    $eExten->configure(-background => 'salmon');
	    $eExten->bind('<Enter>', sub { $status->configure(-text => $Projecte::messages{$err & $Projecte::ERR_EXTEN}) });
	    $eExten->bind('<Leave>', $clearSub);
	}
    }

    return bless($this, $classe);
}


sub getParams {
    my ($this) = @_;

    return @{$this}[1..6];
}


sub canvi {
    my ($this, $pos, $miss, $mode) = @_;

    my $vInicial = $this->[$pos];

    my $result;
    if ($mode eq 'dir') {
	$result = $this->[0]->DirSelect(-title => $miss)->Show($vInicial);

    } elsif ($vInicial =~ /(.+\/)[^\/]*$/) { # Es 'file' relatiu
	$result = $this->[0]->FileSelect(-directory => $1)->Show();

    } else {
	$result = $this->[0]->FileSelect(-directory => '.')->Show();
    }

    if ($result) {
	$this->[$pos] = $result;
    }
}
