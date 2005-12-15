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

		$this->addFilter($name, $file, $cclass);		
	    }
	}
    }

    # Add the default filters
    $this->addFilter('utf', 'Filters::StandardFilters',
		     'Filters::FilterUtf')   unless $this->{'utf'};
    $this->addFilter('utf_np', 'Filters::StandardFilters',
		     'Filters::FilterUtfNp') unless $this->{'utf_np'};
    $this->addFilter('yam', 'Filters::StandardFilters',
		     'Filters::FilterYam')   unless $this->{'yam'};
    $this->addFilter('txt', 'Filters::StandardFilters',
		     'Filters::FilterTxt')   unless $this->{'txt'};

    # Return the filter manager
    return $this;
}


# Add filter
sub addFilter {
    my ($this, $name, $file, $cclass) = @_;

    die "Ilegal filter name $name\n" if $name =~ /^_/;

    eval "use $file";
    die "Can't load filter file $file: $@" if $@;
    
    eval {
	$this->{$name} = $cclass->new();
	$this->{"_$name"} = [ $name, $file, $cclass ];
    };
    die "Can't create object of filter class $cclass: $@" if $@;
}


# Get the list
sub getFilters {
    my ($this) = @_;

    return sort(grep { !/^_/ } keys(%{$this}));
}


# Au revoir
sub auRevoir {
    my ($this, $handl) = @_;

    $handl->print(" <filters>\n");
    foreach my $filter ($this->getFilters()) {
	my $info = $this->{"_$filter"};
	$handl->print( "  <filter name=\"$info->[0]\" file=\"$info->[1]\" class=\"$info->[2]\" />\n");
    }
    $handl->print(" </filters>\n");
}


# Return true
1;
