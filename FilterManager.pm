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

# Filter manager

use strict;

use Filter;


package FilterManager;


# Constructor
sub new {
    my ($class, $tree, $config) = @_;

    # This
    my $this = bless({}, $class);

    if ($tree) {
	# Change the include path locally
	local @INC = @INC;
	push(@INC, split(':', $config->{'IncDir'}));
	
	# Skip attributes
	shift(@{$tree});
	while (@{$tree}) {
	    my $type    = shift(@{$tree});
	    my $content = shift(@{$tree});
	    if ($type eq 'filter') {
		my $name   = $content->[0]{'name'};
		my $file   = $content->[0]{'file'};
		my $cclass = $content->[0]{'class'};

		die "Missing parameters for filter\n"
		    if (!$name || !$file || !$cclass);

		$this->addFilter($name, $file, $cclass, $config);
	    }
	}
    }

    # Add the default filters
    $this->addFilter('bio', 'Filters::StandardFilters',
		     'Filters::FilterBIO',   $config) unless $this->{'bio'};
    $this->addFilter('txt', 'Filters::StandardFilters',
		     'Filters::FilterTxt',   $config) unless $this->{'txt'};
    $this->addFilter('xml', 'Filters::StandardFilters',
		     'Filters::FilterXML',   $config) unless $this->{'xml'};

    # Return the filter manager
    return $this;
}


# Add filter
sub addFilter {
    my ($this, $name, $file, $cclass, $config) = @_;

    eval "use $file";
    if ($@) {
	$config->{'_initErrors'} .=
	    "* Can't load file $file\nfor filter $name.\n";
	return;
    }

    if (!UNIVERSAL::can($cclass, 'new')) {
	$config->{'_initErrors'} .=
	    "* Can't call 'new' on class $cclass\nfor filter $name.\n";
	return
    }

    $this->{$name} = [ $name, $file, $cclass ];
}


# Create a filter
sub newFilter {
    my ($this, $name, $marking) = @_;
    
    my $cclass = $this->{$name}[2];

    my $filter;
    eval { $filter = $cclass->new($marking); };
    die "Can't create filter $name of class $cclass: $@" if $@;

    return $filter;
}


# Get the list
sub getFilters {
    my ($this) = @_;

    return sort(keys(%{$this}));
}


# Au revoir
sub auRevoir {
    my ($this, $handl) = @_;

    $handl->print(" <filters>\n");
    foreach my $filter ($this->getFilters()) {
	my $info = $this->{$filter};
	$handl->print( "  <filter name=\"$info->[0]\" file=\"$info->[1]\" class=\"$info->[2]\" />\n");
    }
    $handl->print(" </filters>\n");
}


# Return true
1;
