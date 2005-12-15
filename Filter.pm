# Basic Filter Support

use strict;

use IO::File;


# Filter interface
# Must be inherited by the Filters

package Filter;

# Constructor
sub new { die "Abstact Operation\n"; }

# Filter a file
sub filter { die "Abstract Operation\n"; }


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
	chomp($line);
	$this->filterLine($line);
    }
    
    # Return the built string
    return $this->[0];
}


# Reset
# By default, nothing more is required
sub reset {}


# Filter a line
sub filterLine { die "Abstract Operation\n"; }

 
# Common functionalities

# Prepare to import as XML
sub prepararImpXML {
    my ($this, $cadena) = @_;
    
    $cadena =~ s/&/"\&#x26;"/ge;
    $cadena =~ s/</"\&#x3c;"/ge;
    
    return $cadena;
}
  

# Return true
1;
