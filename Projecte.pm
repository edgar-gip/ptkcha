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

# Projecte del PTkChA

use strict;

use IO::File;
use XML::Parser;
use Marcatge;

package Projecte;

# Errors
our $ERR_NOERR = 0;

our $ERR_INPUT_NODEF = 1;
our $ERR_INPUT_NOEXS = 2;
our $ERR_INPUT_NODIR = 4;
our $ERR_INPUT_NORD  = 8;
our $ERR_INPUT       =
    $ERR_INPUT_NODEF | $ERR_INPUT_NOEXS |
    $ERR_INPUT_NODIR | $ERR_INPUT_NORD;

our $ERR_OUTPUT_NODEF = 16;
our $ERR_OUTPUT_NOEXS = 32;
our $ERR_OUTPUT_NODIR = 64;
our $ERR_OUTPUT_NOWR  = 128;
our $ERR_OUTPUT       =
    $ERR_OUTPUT_NODEF | $ERR_OUTPUT_NOEXS |
    $ERR_OUTPUT_NODIR | $ERR_OUTPUT_NOWR;

our $ERR_MARK_NODEF = 256;
our $ERR_MARK_NOEXS = 512;
our $ERR_MARK_DIR   = 1024;
our $ERR_MARK_NORD  = 2048;
our $ERR_MARK_XML   = 4096;
our $ERR_MARK       =
    $ERR_MARK_NODEF | $ERR_MARK_NOEXS |
    $ERR_MARK_DIR   | $ERR_MARK_NORD  | $ERR_MARK_XML;

our $ERR_FILTER_NODEF = 8192;
our $ERR_FILTER_NOEXS = 16384;
our $ERR_FILTER_ERROR = 32768;
our $ERR_FILTER       =
    $ERR_FILTER_NODEF | $ERR_FILTER_NOEXS | $ERR_FILTER_ERROR;

our $ERR_EXTEN_NODEF = 65536;
our $ERR_EXTEN       =
    $ERR_EXTEN_NODEF;

our $ERR_NAME_NODEF  = 131072;
our $ERR_NAME        =
    $ERR_NAME_NODEF;

# Messages
our %messages = ( $ERR_NOERR => 'No Error',

		  $ERR_INPUT_NODEF => 'Input is not defined',
		  $ERR_INPUT_NOEXS => 'Input does not exist',
		  $ERR_INPUT_NODIR => 'Input is not a directory',
		  $ERR_INPUT_NORD => 'Input is not readable',

		  $ERR_OUTPUT_NODEF => 'Output is not defined',
		  $ERR_OUTPUT_NOEXS => 'Output does not exist',
		  $ERR_OUTPUT_NODIR => 'Output is not a directory',
		  $ERR_OUTPUT_NOWR => 'Output is not writable',

		  $ERR_MARK_NODEF => 'Marking is not defined',
		  $ERR_MARK_NOEXS => 'Marking does not exist',
		  $ERR_MARK_DIR => 'Marking is a directory',
		  $ERR_MARK_NORD => 'Marking is not readable',
		  $ERR_MARK_XML => 'Marking is not valid XML',
		  
		  $ERR_FILTER_NODEF => 'Filter is not defined',
		  $ERR_FILTER_NOEXS => 'Filter does not exist',
		  $ERR_FILTER_ERROR => 'Filter contains errors',
		  
		  $ERR_EXTEN_NODEF => 'Extension is not defined',
		  
		  $ERR_NAME_NODEF => 'Name is not defined');

# Global filter manager
our $filterManager;

# Constructor
sub new {
    my ($classe, $nom, $dirIn, $dirOut, $marcat, $filtre,
	$extensio) = @_;

    # Creem l'objecte
    my $this = [ $nom, $dirIn, $dirOut, $marcat, undef, $filtre,
		 undef, $extensio ];
    bless($this, $classe);

    # Comprovar
    $this->check();
    return $this;
}


# Copy Constructor
sub clone {
    my ($classe, $projecte) = @_;

    # Creem l'objecte
    my $this = [ @{$projecte} ];
    return bless($this, $classe);
}


# Constructor from an XML tree
sub newFromXML {
    my ($class, $tree) = @_;

    # Get the attributes
    my $name   = $tree->{'name'};
    my $dirIn  = $tree->{'dirIn'};    
    my $dirOut = $tree->{'dirOut'};
    my $mark   = $tree->{'marking'};
    my $filter = $tree->{'filter'};
    my $exten  = $tree->{'extension'};

    return $class->new($name, $dirIn, $dirOut, $mark, $filter,
		       $exten);
}


# Check
sub check {
    my ($this) = @_;

    # Get attributes
    my ($name, $dirIn, $dirOut, $marcat, $filtre, $exten) =
	@{$this}[0,1,2,3,5,7];

    # At the beginning
    my $status = $ERR_NOERR;

    # Name
    if (!$name) {
	$status |= $ERR_NAME_NODEF;
    }

    # Input dir
    if (!$dirIn) {
	$status |= $ERR_INPUT_NODEF;
    } elsif (!-e $dirIn) {
	$status |= $ERR_INPUT_NOEXS;
    } elsif (!-d $dirIn) {
	$status |= $ERR_INPUT_NODIR;
    } elsif (!-r $dirIn) {
	$status |= $ERR_INPUT_NORD;
    }

    # Output dir
    if (!$dirOut) {
	$status |= $ERR_OUTPUT_NODEF;
    } elsif (!-e $dirOut) {
	$status |= $ERR_OUTPUT_NOEXS;
    } elsif (!-d $dirOut) {
	$status |= $ERR_OUTPUT_NODIR;
    } elsif ((!-w $dirOut) || (!-r $dirOut)) {
	$status |= $ERR_OUTPUT_NOWR;
    }

    # Marking
    $this->[4] = undef;
    if (!$marcat) {
	$status |= $ERR_MARK_NODEF;
    } elsif (!-e $marcat) {
	$status |= $ERR_MARK_NOEXS;
    } elsif (-d $marcat) {
	$status |= $ERR_MARK_DIR;
    } elsif (!-r $marcat) {
	$status |= $ERR_MARK_NORD;
    } else {
	eval {
	    $this->[4] = new Marcatge($this->[3]);
	};
	$status |= $ERR_MARK_XML if $@;
    }

    # Filter
    $this->[6] = undef;
    if (!$filtre) {
	$status |= $ERR_FILTER_NODEF;
    } else {
	eval {
	    $this->[6] = $filterManager->newFilter($filtre, $this->[4]);
	    $status |= $ERR_FILTER_NOEXS unless $this->[6];
	};
	$status |= $ERR_FILTER_ERROR if $@;
    }

    # Extension
    if (!$exten) {
	$status |= $ERR_EXTEN_NODEF;
    }

    # Set the status
    $this->[8] = $status;
}


# Consultores
sub getNom      { return $_[0]->[0]; }
sub getDirIn    { return $_[0]->[1]; }
sub getDirOut   { return $_[0]->[2]; }
sub getMarcFile { return $_[0]->[3]; }
sub getMarcatge { return $_[0]->[4]; }
sub getFiltName { return $_[0]->[5]; }
sub getExtens   { return $_[0]->[7]; }
sub getStatus   { return $_[0]->[8]; }


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
	return $this->fixXMLIn($cadena);

    } else {
	# No hi és, hem d'importar i filtrar
	my $extensio = $this->[7];
	my $string   = $this->[6]->filter("$this->[1]/$fitxer.$extensio");
	return $this->fixXMLIn($string);
    }
}


# Guardar un Fitxer
sub saveFile {
    my ($this, $fitxer, $cadena) = @_;
    
    my $fh = new IO::File("> $this->[2]/$fitxer.sum")
	or die "No Es Pot Obrir Sortida $this->[2]/$fitxer.sum";
    
    $fh->print($this->fixXMLOut($cadena));
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


# Fix a string for XML in the input
sub fixXMLIn {
    my ($this, $string) = @_;

    # Label
    my $label = $this->[4]->getEtiqueta();

    # For each line
    my @lines = split("\n", $string);
    my $out;
    foreach my $line (@lines) {
	while ($line =~ /^(.*?)<([^<]+?)>(.*)$/) {
	    my $prefix  = $1;
	    my $content = $2;
	    $line = $3;

	    $prefix =~ s/</"&#x3c;"/ge;
	    $out   .= $prefix;

	    if ($content =~ /^\s*\/\s*$label\s*$/ ||
		$content =~ /^\s*$label(\s+\w+=\"[^\"]*\")*\s*$/) {
		# Add it as is
		$out .= "<$content>";
	    } else {
		# Add it escaped
		$out .= "&#x3c;$content>";
	    }
	}

	# Add the last
	$line =~ s/</"&#x3c;"/ge;
	$out  .= "$line\n";
    }

    # Return
    return $out;
}


# Fix a string for XML in the output
sub fixXMLOut {
    my ($this, $string) = @_;

    # Change ampersands
    $string =~ s/&/"&#x26;"/ge;
    
    # Non-changeable labels
    my %good =
	map { $_ => 1 } ($this->[4]->getEtiqueta(),
			 @{$this->[4]->getExtras()});

    # For each line
    my @lines = split("\n", $string);
    my $out;
    foreach my $line (@lines) {
	while ($line =~ /^(.*?)<([^<]+?)>(.*)$/) {
	    my $prefix  = $1;
	    my $content = $2;
	    $line = $3;

	    $prefix =~ s/</"&#x3c;"/ge;
	    $out   .= $prefix;

	    if (($content =~ /^\s*\/\s*(\w+)\s*$/ && $good{$1}) ||
		($content =~ /^\s*(\w+)(\s+\w+=\"[^\"]*\")*\s*$/ && $good{$1})) {
		# Add it as is
		$out .= "<$content>";
	    } else {
		# Add it escaped
		$out .= "&#x3c;$content>";
	    }
	}
	
	# Last
	$line =~ s/</"&#x3c;"/ge;
	$out .= "$line\n";
    }

    # Return
    return $out;
}


# Retornem Cert
1;
