# Projecte del PTkChA

use strict;

use IO::File;
use XML::Parser;
use Marcatge;

package Projecte;


# Constructor
sub new {
    my ($classe, $nom, $dirIn, $dirOut, $marcat, $filtre,
	$extensio, $filterManager) = @_;

    # Comprovem els directoris
    die "Input does not exist: $dirIn\n"    if !(-e $dirIn);
    die "Output does not exist: $dirOut\n"  if !(-e $dirOut);
    die "Marking does not exist: $marcat\n" if !(-e $marcat);

    die "Input in not a directory: $dirIn\n"   if !(-d $dirIn);
    die "Output is not a directory: $dirOut\n" if !(-d $dirOut);

    die "Input is not readable: $dirIn\n" if !(-r $dirIn);
    die "Output is not readable/writable: $dirOut\n"
	if !(-r $dirOut && -w $dirOut);

    die "Marking is not readable: $marcat\n" if !(-r $marcat);

    my $filterObj = $filterManager->{$filtre};
    die "Wrong filter: \"$filtre\"\n" if !$filterObj;

    # Creem l'objecte
    my $this = [ $nom, $dirIn, $dirOut, $marcat, undef, $filtre,
		 $filterObj, $extensio ];
    return bless($this, $classe);
}


# Constructor from an XML tree
sub newFromXML {
    my ($class, $tree, $filterManager) = @_;

    # Get the attributes
    my $name   = $tree->{'name'};
    my $dirIn  = $tree->{'dirIn'};    
    my $dirOut = $tree->{'dirOut'};
    my $mark   = $tree->{'marking'};
    my $filter = $tree->{'filter'};
    my $exten  = $tree->{'extension'};

    die "Missing value\n"
	if (!$name || !$dirIn || !$dirOut ||
	    !$mark || !$filter || !$exten);
    return $class->new($name, $dirIn, $dirOut, $mark, $filter,
		       $exten, $filterManager);
}


# Obtenir el Nom
sub getNom    { return $_[0]->[0]; }
sub getDirOut { return $_[0]->[2]; }

# Obtenir el Marcatge
sub getMarcatge {
    my ($this) = @_;

    # Si esta definit, es que ja l'hem carregat abans
    if (!defined($this->[4])) {
	# El carreguem
	$this->[4] = new Marcatge($this->[3]);
    }

    return $_[0]->[4];
}


# Obtenir els Fitxers
sub getFiles {
    my ($this) = @_;

    # Fem un glob
    my $extensio = $this->[7];
    return map {
	$_ =~ /(^|\/)([^\/]*)\.$extensio$/;
	$2;
    } glob("$this->[1]/*.$extensio");
}


# Obtenir un Fitxer
sub loadFile {
    my ($this, $fitxer) = @_;

    # Comprovem que no existeixi ja al directori de sortida
    if (-r "$this->[2]/$fitxer.sum") {
	my $fh = new IO::File("< $this->[2]/$fitxer.sum");
	my $cadena = join('', $fh->getlines());
	$fh->close();
	return $cadena;

    } else {
	# No hi és, hem d'importar i filtrar
	my $extensio = $this->[7];
	return $this->[6]->filter("$this->[1]/$fitxer.$extensio");
    }
}


# Guardar un Fitxer
sub saveFile {
    my ($this, $fitxer, $cadena) = @_;
    
    my $fh = new IO::File("> $this->[2]/$fitxer.sum")
	or die "No Es Pot Obrir Sortida $this->[2]/$fitxer.sum";
    
    $fh->print($cadena);
    $fh->close();
}


# Eliminar un fitxer
sub removeFile {
    my ($this, $fitxer) = @_;

    unlink("$this->[2]/$fitxer.sum")  if -e "$this->[2]/$fitxer.sum";
}


# To XML
sub toXML {
    my ($this) = @_;

    return "  <project name=\"$this->[0]\" dirIn=\"$this->[1]\" dirOut=\"$this->[2]\" marking=\"$this->[3]\" filter=\"$this->[5]\" extension=\"$this->[7]\" />\n";
}


# Retornem Cert
1;
