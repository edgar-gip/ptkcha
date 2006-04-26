# Dialeg amb els Projectes

use strict;

use Tk;
use Tk::TixGrid;

use Forwarder;

use ProjectDialog;

package ProjectManagerDialog;

our @ISA = qw( Forwarder );

# Constructor
sub new {
    my ($class, $main, $parent) = @_;

    # Window
    my $win = $parent->Toplevel(-title => "Projects");
    
    # Label
    my $etiqueta = $win->Label(-text => '<Available Projects>')
	->pack(-side => 'top', -fill => 'x');

    # Grid
    my $grid = $win->Scrolled('TixGrid', -scrollbars => 'e')
	->pack(-side => 'top', -fill => 'both', -expand => 1)
	->Subwidget('scrolled');

    # Items
    my $stylCap   = $grid->ItemStyle('text',
				     -foreground => 'yellow');
    my $stylTxt   = $grid->ItemStyle('text',
				     -background => 'grey',
				     -foreground => 'black');
    my $stylRed   = $grid->ItemStyle('text',
				     -background => 'grey',
				     -foreground => 'red');
    my $stylGreen = $grid->ItemStyle('text',
				     -background => 'grey',
				     -foreground => 'darkgreen');
    my $stylBlue= $grid->ItemStyle('text',
				     -background => 'grey',
				     -foreground => 'blue');
    
    $grid->set(0, 0, -itemtype => 'text', -text => 'Status', -style => $stylCap);
    $grid->set(1, 0, -itemtype => 'text', -text => 'Name', -style => $stylCap);
    $grid->sizeColumn(1, -size => 200);
    $grid->set(2, 0, -itemtype => 'text', -text => 'Marking', -style => $stylCap);
    $grid->sizeColumn(2, -size => 150);

    # Button panel
    my $panel = $win->Frame()
	->pack(-side => 'bottom', -fill => 'x');
    
    # Group with the parent
    $win->group($parent);

    my $this = [ $win, $main, $grid, $stylTxt,
		 $stylRed, $stylGreen, undef,
		 $parent, $stylBlue, undef ];

    # Populate button panel
    $panel->Button(-text => 'Open',
		   -command => sub { $this->openProject() })
	->grid(-row => 0, -column => 0, -sticky => 'ew');	
    $panel->Button(-text => 'New',
		   -command => sub { $this->newProject() })
	->grid(-row => 0, -column => 1, -sticky => 'ew');
    $panel->Button(-text => 'Modify',
		   -command => sub { $this->modifyProject() })
	->grid(-row => 0, -column => 2, -sticky => 'ew');	
    $panel->Button(-text => 'Delete',
		   -command => sub { $this->deleteProject() })
	->grid(-row => 0, -column => 3, -sticky => 'ew');
    $panel->Button(-text => 'Clone',
		   -command => sub { $this->cloneProject() })
	->grid(-row => 0, -column => 4, -sticky => 'ew');	

    # Add open binding
    $grid->bind('<Double-Button-1>', sub { $this->openProject() });

    return bless($this, $class);
}


# Fill
sub populate {
    my ($this, $projectManager) = @_;

    # For each project in the project manager
    for (my $i = 0; $i < @{$projectManager}; ++$i) {
	$this->populateRow($i, $projectManager->[$i]);
    }

    # Save the project manager
    $this->[6] = $projectManager;
}


# Populate one row
sub populateRow {
    my ($this, $i, $proj) = @_;
	
    # Get the grid and style
    my ($grid, $stylTxt, $stylRed,
	$stylGreen, $stylBlue) = @{$this}[2..5,8];
    
    if ($proj->getStatus()) {
	$grid->set(0, $i + 1,
		   -itemtype => 'text',
		   -text =>  '!',
		   -style => $stylRed);
    } elsif ($proj == $this->[1]->getProjecte()) {
	$grid->set(0, $i + 1,
		   -itemtype => 'text',
		   -text =>  'Active',
		   -style => $stylBlue);
    } else {
	$grid->set(0, $i + 1,
		   -itemtype => 'text',
		   -text =>  'OK',
		   -style => $stylGreen);
    }
    
    $grid->set(1, $i + 1,
	       -itemtype => 'text',
	       -text => $proj->getNom(),
	       -style => $stylTxt);
    
    my $mark = $proj->getMarcatge();
    if ($mark) {
	my $filename = $mark->getFileName();
	$filename =~ /(^|\/)([^\/]+?)(\.xml)?$/;
	$grid->set(2, $i + 1,
		   -itemtype => 'text',
		   -text => $2,
		   -style => $stylTxt);
    } else {
	$grid->set(2, $i + 1,
		   -itemtype => 'text',
		   -text => '-',
		   -style => $stylTxt);
    }
}


# New project
sub newProject {
    my ($this) = @_;

    my $dialog = new ProjectDialog($this->[0]);
    my $res = $dialog->Show();
    if ($res eq 'OK') {
	# Get project manager
	my $pm = $this->[6];

	# Add project
	my $p = new Projecte($dialog->getParams());
	$pm->afegirProjecte($p);
	$this->populateRow($#{$pm}, $p);
    }
}


# Modify project
sub modifyProject {
    my ($this) = @_;

    # Project manager & grid
    my ($grid, $pm) = @{$this}[2,6];    

    # Get the selected item
    for (my $i = 0; $i < @{$pm}; ++$i) {
	if ($grid->selectionIncludes(1, $i + 1)) {
	    # Check it is not the current one
	    if ($pm->[$i] == $this->[1]->getProjecte()) {
		$this->mostrarError('Can\'t modify active project');
		last;
	    }

	    my $dialog = new ProjectDialog($this->[0], $pm->[$i]);
	    my $res = $dialog->Show();
	    if ($res eq 'OK') {
		my $p = new Projecte($dialog->getParams());
		$pm->[$i] = $p;
		$this->populateRow($i, $p);
	    }
	    last;
	}
    }
}


# Open project
sub openProject {
    my ($this) = @_;
    
    # Project manager & grid
    my ($grid, $pm) = @{$this}[2,6];    
    
    # Get the selected item
    for (my $i = 0; $i < @{$pm}; ++$i) {
	if ($grid->selectionIncludes(1, $i + 1)) {
	    # Check it is not the current one
	    if ($pm->[$i] == $this->[1]->getProjecte()) {
		last;
	    }
	    
	    # Check status is OK
	    if ($pm->[$i]->getStatus()) {
		$this->mostrarError('Can\'t open a project with errors');
		last;
	    }

	    # Open
	    $this->[1]->updateInterficie($pm->[$i]);

	    # Show the window
	    $this->[7]->deiconify();
	    $this->[7]->raise();
	    $this->[7]->focus();

	    # Deactivate
	    $this->populateRow($this->[9], $pm->[$this->[9]])
		if defined($this->[9]);

	    # Populate row
	    $this->populateRow($i, $pm->[$i]);
	    $this->[9] = $i;
	    last;
	}
    }
}


# Delete project
sub deleteProject {
    my ($this) = @_;
    
    # Project manager & grid
    my ($grid, $pm) = @{$this}[2,6];    

    # Return if empty
    return unless @{$pm};

    # Get the selected item
    my $i = 0;
    while ($i < @{$pm}) {
	if ($grid->selectionIncludes(1, $i + 1)) {
	    # Check it is not the current one
	    if ($pm->[$i] == $this->[1]->getProjecte()) {
		$this->mostrarError('Can\'t delete active project');
		return;
	    }

	    # Confirm
	    return unless $this->confirmacio('Delete project?');

	    # Delete
	    $pm->deleteProject($i);
	    last;
	}
	++$i;
    }

    # Move next
    while ($i < @{$pm}) {
	$this->populateRow($i, $pm->[$i]);
	++$i;
    }

    # Remove last
    $grid->deleteRow($i + 1);
}


# Clone project
sub cloneProject {
    my ($this) = @_;
    
    # Project manager & grid
    my ($grid, $pm) = @{$this}[2,6];    

    # Return if empty
    return unless @{$pm};

    # Get the selected item
    for (my $i = 0; $i < @{$pm}; ++$i) {
	if ($grid->selectionIncludes(1, $i + 1)) {
	    # Add project
	    my $p = clone Projecte($pm->[$i]);
	    $pm->afegirProjecte($p);
	    $this->populateRow($#{$pm}, $p);
	    last;
	}
    }
}


# Confirmacio
sub confirmacio {
    my ($this, $missatge) = @_;

    my $retorn = $this->[0]->messageBox(-icon => 'question',
					-type => 'YesNo',
					-message => $missatge,
					-title => 'Confirmation');
    return $retorn eq 'Yes';
}


# Mostrar Error
sub mostrarError {
    my ($this, $missatge) = @_;

    $this->[0]->messageBox(-icon => 'error',
			   -title => 'Error',
			   -message => $missatge,
			   -type => 'Ok');
}


# Retornem cert
1;
    
