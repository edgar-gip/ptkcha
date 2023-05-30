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

# PTkCha

use strict;

use FindBin qw( $RealBin );
use lib "$RealBin";

# Load from the execution dir, if possible
BEGIN {
    $0 =~ /(^|.*\/)([^\/]+)$/;
    unshift(@INC, $1 ? $1 : '.');
}

use Tk;

use Interficie;

new Interficie();
MainLoop();
