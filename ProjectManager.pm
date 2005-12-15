# Gestor de Projectes

use strict;

use IO::File;

package ProjectManager;

# Constructor
# Load from a tree
sub new {
    my ($class, $tree, $filterManager) = @_;

    # Som una llista de Projectes
    my $this = [];

    # Skip attributes
    shift(@{$tree});

    # Every child
    while (@{$tree}) {
	my $type    = shift(@{$tree});
	my $content = shift(@{$tree});
	
	if ($type eq 'project') {
	    eval {
		my $p = newFromXML Projecte($content->[0], $filterManager);
		push(@{$this}, $p);
	    };
	    
	    # Informem si hi ha hagut errors
	    print "Error Opening Project: $@" if $@;
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
