use strict;

use Tk;
use Tk::DialogBox;
use Tk::Pane;

use Forwarder;

# Classe DefaultDialog
package DefaultDialog;
our @ISA = qw( Forwarder );

# Constructor
sub new {
    my ($classe, $pare, $marcatge) = @_;

    my $atribs = $marcatge->getAtributs();
    return undef unless @{$atribs};
    
    my $dialog =
	$pare->DialogBox(-title => 'Default Values',
			 -buttons => [ 'Ok' ]);

    my $panell =
	$dialog->add('Scrolled', 'Frame',
		     -scrollbars => 'e')
	->pack(-fill => 'both', -expand => 1)
	->Subwidget('scrolled');

    my @llista;
    my $i = 0;
    foreach my $atr (@{$atribs}) {
	my $etiqueta = $panell->Label(-text => $atr->[0])
	    ->grid(-column => 0, -row => $i, -sticky => 'ne');
	my @valors = @{$atr}[1..$#{$atr}];
	my $combo = $panell->BrowseEntry(-state => 'readonly',
					 -choices => \@valors,
					 -variable => \$llista[$i])
	    ->grid(-column => 1, -row => $i, -sticky => 'nw');
	$llista[$i] = $valors[0];
	++$i;
    }
    
    my $this = [ $dialog, \@llista ];
    return bless($this, $classe);
}


# Obtenir valor
sub getValor { return $_[0]->[1][$_[1]]; }

# Obtenir
sub getAllValors { return @{$_[0]->[1]}; }

# Retornem Cert
1;
