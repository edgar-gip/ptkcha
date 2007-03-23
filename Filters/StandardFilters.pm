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

# Built-in filters
# Basic Ones

use strict;

use Filter;

#######
# BIO #
#######

package Filters::FilterBIO;

our @ISA = qw( FilterLineByLine );


# Constructor
sub new {
    my ($class, $marking) = @_;

    my $this = FilterLineByLine::new($class);
    push(@{$this}, 0,
	 $marking->getEtiqueta(),
	 map { $_->[0] } @{$marking->getAtributs()});
    return $this;
}


# Reset
sub reset {
    my ($this) = @_;
    
    # State variable
    $this->[1] = 0;
}


# Filter BIO
sub filterLine {
    my ($this, $linia) = @_;

    # Label and attributes
    my ($label, @attrs) = @{$this}[2..$#{$this}];

    # Blank Line
    chomp($linia);
    if (!$linia) {
	if ($this->[1]) {
	    # Close previous
	    $this->[0] .= "</$label>";
	    $this->[1] = 0;
	}
	$this->[0] .= "\n";
	return;
    }

    # Altrament
    my @parts = split(' ', $linia);
    my @bio   = split('-', $parts[-1]);
    if ($bio[0] eq 'B') {
	# New NE
	if ($this->[1]) {
	    # Close previous
	    $this->[0] .= "</$label>";
	}

	# Start ours
	$this->[0] .= " <$label";
	for (my $i = 1; $i < @bio; ++$i) {
	    last if $i > @attrs;
	    $this->[0] .= sprintf(" %s=\"%s\"",
				  $attrs[$i-1], $bio[$i]);
	}
	$this->[0] .= ">$parts[0]";
	$this->[1] = 1;

    } elsif ($bio[0] eq 'I') {
	if (!$this->[1]) {
	    # Open a dummy one -> BIO Error!
	    $this->[0] .= " <$label";
	    for (my $i = 1; $i < @bio; ++$i) {
		last if $i > @attrs;
		$this->[0] .= sprintf(" %s=\"%s\"",
				      $attrs[$i-1], $bio[$i]);
	    }
	    $this->[0] .= ">$parts[0]";
	    $this->[1] = 1;
	} else {
	    $this->[0] .= " $parts[0]";
	}
	
    } else {
	# Close previous
	if ($this->[1]) {
	    $this->[0] .= "</$label>";
	    $this->[1] = 0;
	}
	
	$this->[0] .= " $parts[0]";
    }
}


# Finish
sub finish {
    my ($this) = @_;

    # Finish if open
    if ($this->[1]) {
	$this->[0] .= "</$this->[2]>\n";
    }
}


#######
# Txt #
#######

package Filters::FilterTxt;

our @ISA = qw( FilterLineByLine );


# Filtrar Text
sub filterLine {
    my ($this, $cadena) = @_;

    # Just append, escaping things that would
    # mess the XML up
    $cadena =~ s/&/"&x26;"/ge;
    $cadena =~ s/</"&x3c;"/ge;
    $this->[0] .= $cadena;
}


#######
# XML #
#######

package Filters::FilterXML;

our @ISA = qw( FilterLineByLine );


# Filtrar Text
sub filterLine {
    my ($this, $cadena) = @_;

    # Just append -> We assume it is XML
    $this->[0] .= $cadena;
}


# Return true
1;
