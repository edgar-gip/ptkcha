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

# Gestor de Projectes

use strict;

use IO::File;

use Projecte;

package ProjectManager;

# Constructor
# Load from a tree
sub new {
    my ($class, $tree, $filterManager) = @_;

    # Set the filter manager
    $Projecte::filterManager = $filterManager;

    # Som una llista de Projectes
    my $this = [];

    # Skip attributes
    shift(@{$tree});

    # Every child
    while (@{$tree}) {
        my $type    = shift(@{$tree});
        my $content = shift(@{$tree});

        if ($type eq 'project') {
            my $p = newFromXML Projecte($content->[0], $filterManager);
            push(@{$this}, $p);
        }
    }

    # Retornem la llista
    return bless($this, $class);
}


# Au revoir
sub auRevoir {
    my ($this, $handl) = @_;

    $handl->print(" <projects>\n");
    foreach my $p (@{$this}) {
        $handl->print($p->toXML());
    }
    $handl->print(" </projects>\n");
}


# Es un nom valid
sub esNomValid {
    my ($this, $nom) = @_;

    foreach my $p (@{$this}) {
        return 0 if $p->getNom() eq $nom;
    }

    return 1;
}


# Afegir un projecte
sub afegirProjecte {
    push(@{$_[0]}, $_[1]);
}


# Cercar un projecte
sub cercarProjecte {
    my ($this, $nom) = @_;

    map {
        return $_ if $_->getNom() eq $nom;
    } @{$this};

    return undef;
}


# Delete a project
sub deleteProject {
    my ($this, $num) = @_;

    splice(@{$this}, $num, 1);
}

# Retornem Cert
1;
