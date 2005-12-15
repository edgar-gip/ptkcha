# Dialeg Dependencies

use Tk;
use Tk::DialogBox;

use Forwarder;


package DialegLlista;

our @ISA = qw( Forwarder );

# constructor
sub new {
    my ($classe, $finestraPare, $titol, $ample, $botons) = @_;
    $ample  ||= 30;
    $botons ||= [ "Ok" ];

    my $dialog =
	$finestraPare->DialogBox(-title => $titol,
				 -buttons => $botons );
    my $llista = $dialog->add('Scrolled', 'Listbox',
			      -scrollbars => 'e',
			      -selectmode => 'single',
			      -width => $ample)
	->pack(-fill => 'both', -expand => 1)
	->Subwidget('scrolled');
    
    my $this = [ $dialog, $llista ];
    return bless($this, $classe);
}


# Netejar la llista
sub netejarLlista {
    my ($this) = @_;

    $this->[1]->delete(0, 'end');
}


# Afegir element
sub afegirElement {
    my ($this, $cadena) = @_;

    $this->[1]->insert('end', $cadena);
}


# Retornem Cert
1;
