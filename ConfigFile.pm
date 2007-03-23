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

# Configuration file

use strict;

use XML::Parser;

use FilterManager;
use ProjectManager;


package ConfigFile;

# Constructor
sub new {
    my ($class, $file) = @_;
    
    # Default value for file
    $file ||= "$ENV{HOME}/.ptkcha.xml";

    # Object
    my $this = {};
    
    eval {
	my $parser = new XML::Parser(Style => 'Tree');

	my $tree;
	eval {
	    $tree = $parser->parsefile($file);
	};
	die "$file is not a valid XML file: $@" if $@;
	
	# Check root
	die "$file does not contain an XML <config>\n"
	    if $tree->[0] ne 'config';
	die "$file is not XML <config> version 1.1.xml\n"
	    if shift(@{$tree->[1]})->{'version'} ne '1.1.xml';
	
	# Branch of the Project Manager
	my $pmTree;
	my $fmTree;

	while (@{$tree->[1]}) {
	    my $type    = shift(@{$tree->[1]});
	    my $content = shift(@{$tree->[1]});

	    if ($type eq 'option') {
		$this->{$content->[0]{'name'}} = $content->[0]{'value'};
		
	    } elsif ($type eq 'filters') {
		$fmTree = $content;
		
	    } elsif ($type eq 'projects') {
		$pmTree = $content;
	    }
	}

	# Init errors
	$this->{'_initErrors'} = '';

	# Then, check for the filter manager
	$this->{'_filterManager'} = new FilterManager($fmTree, $this);
	    
	# Parse the project manager
	$this->{'_projectManager'} =
	    new ProjectManager($pmTree, $this->{'_filterManager'});

	# Init errors?
	if ($this->{'_initErrors'}) {
	    print "Initialization Errors:\n" . $this->{'_initErrors'};
	}
    };
    
    if ($@) {
	# Couldn't parse the configuration file
	
	# Default options
	$this->{'SelExp'} = 1;  # Selection Expansion
	$this->{'ForWri'} = 0;  # Forced Writing
	$this->{'IncDir'} = ''; # Extra @INC Dirs

	# Init errors
	$this->{'_initErrors'} = '';

	# Empty filter manager
	$this->{'_filterManager'} = new FilterManager(undef, $this);

	# Empty project manager
	$this->{'_projectManager'} = new ProjectManager([],
							$this->{'_filterManager'});
    }

    return bless($this, $class);
}


# Get the project manager
sub getProjectManager {
    my ($this) = @_;

    return $this->{'_projectManager'};
}


# Get the filter manager
sub getFilterManager {
    my ($this) = @_;

    return $this->{'_filterManager'};
}


# Good bye
sub auRevoir {
    my ($this, $file) = @_;

    # Default value for file
    $file ||= "$ENV{HOME}/.ptkcha.xml";

    my $fout = new IO::File("> $file")
	or die "Can't open output configuration file $file\n";

    $fout->print("<config version=\"1.1.xml\">\n");
    while (my ($opt, $val) = each(%{$this})) {
	if ($opt !~ /_/) {
	    $fout->print(" <option name=\"$opt\" value=\"$val\" />\n");
	}
    }

    # Special
    $this->{'_filterManager'}->auRevoir($fout);
    $this->{'_projectManager'}->auRevoir($fout);

    $fout->print("</config>\n");
}


# Return true
1;

    
