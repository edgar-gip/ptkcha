# Forwarder
# Edgar Gonzalez i Pellicer

package Forwarder;

# Forward (sempre fa Forward al primer)
sub AUTOLOAD {
    my ($this, @resta) = @_;
    
    $AUTOLOAD =~ /\:\:(.+)$/;
    return $this->[0]->$1(@resta);
}


# Retornem Cert
1;

