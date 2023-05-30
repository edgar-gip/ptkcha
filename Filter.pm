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

# Basic Filter Support

use strict;

use IO::File;

# Filter interface
# Must be inherited by the Filters

package Filter;

# Constructor
sub new { die "Abstact Operation 'new' Called\n"; }

# Filter a file
sub filter { die "Abstract Operation 'filter' Called\n"; }

# Generic filter, filters line by line
# Pattern pattern
package FilterLineByLine;

our @ISA = qw( Filter );

# Constructor
sub new {
    my ($class) = @_;

    # Space for vars
    # 0: String in construKtion
    return bless([ '' ], $class);
}

# Filter
sub filter {
    my ($this, $file) = @_;

    my $fh = new IO::File("< $file")
        or die "Can't open $file\n";

    # Reset the state
    $this->[0] = '';
    $this->reset();

    # Anem llegint
    my $line;
    while ($line = $fh->getline()) {
        $this->filterLine($line);
    }

    # Return the built string
    $this->finish();
    return $this->[0];
}

# Reset
# By default, nothing more is required
sub reset {}

# Filter a line
sub filterLine { print @_; die "Abstract Operation 'filterLine' Called\n"; }

# Finish
# By default, nothing more is required
sub finish {}

# Return true
1;
