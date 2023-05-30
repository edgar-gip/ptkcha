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

# Dialeg Per a Resums

use strict;

use IO::File;

use Tk;

use Forwarder;

use Plugins::PluginResum::DialegLlista;

package DialegResum;

our @ISA = qw( Forwarder );

# Atributs
###########
# 0: dialeg
# 1: main
# 2: valor scale %
# 3: valor scale mots
# 4: valor mots seleccionats
# 5: nom fitxer
# 6: etiqueta
# 7: scale mots
# 8: taula
# 9: result
# 10:nombre mots
# 11:refChunks
# 12:refCheckboxes
# 13:textos
# 14:etiqColor
# 15:dialegLlista

# Constructor
sub new {
    my ($classe, $fpare, $main) = @_;

    # Finestra
    my $dialeg = $fpare->Toplevel(-title => 'Summary');

    # Creem l'objecte
    my $this = [ $dialeg, $main, 10, 0, '', '' ];

    $dialeg->withdraw();
    $dialeg->protocol('WM_DELETE_WINDOW', sub { $this->sortir() });

    # Linia superior
    $dialeg->Scale(-from => 0, -to => 100,
                   -tickinterval => 0,
                   -resolution => 1,
                   -command => sub { $this->spin(0) },
                   -variable => \$this->[2],
                   -orient => 'horizontal')
        ->grid(-row => 0, -column => 0, -sticky => 'nw');
    my $etiqueta = $dialeg->Label(-text => '% of xxx words =')
        ->grid(-row => 0, -column => 1, -sticky => 'ns');
    my $scaleMots = $dialeg->Scale(-from => 0, -to => 10000,
                                   -tickinterval => 0,
                                   -resolution => 1,
                                   -command => sub { $this->spin(1) },
                                   -variable => \$this->[3],
                                   -orient => 'horizontal')
        ->grid(-row => 0, -column => 2, -sticky => 'ne');

    # Grid Central
    my $taula = $dialeg->Scrolled('Canvas',
                                  -scrollbars => 'e',
                                  -height => 200)
        ->grid(-row => 1, -column => 0, -columnspan => 3, -sticky => 'nesw')
        ->Subwidget('scrolled');

    # Etiqueta
    $dialeg->Button(-text => 'Auto-Summary',
                    -command => sub { $this->autoResum() })
        ->grid(-row => 2, -column => 0, -sticky => 'new');
    my $etiqColor = $dialeg->Entry(-width => 10, -state => 'disabled',
                                   -textvar => \$this->[4])
        ->grid(-row => 2, -column => 1, -sticky => 'ne', -pady => 5);
    $dialeg->Label(-text => 'words in summary')
        ->grid(-row => 2, -column => 2, -sticky => 'ne', -pady => 5, -padx => 5);

    # Resultat
    my $result = $dialeg->Scrolled('ROText',
                                   -scrollbars => 'e',
                                   -wrap => 'word')
        ->grid(-row => 3, -column => 0, -columnspan => 3, -sticky => 'nesw')
        ->Subwidget('scrolled');

    # Fitxer on grabar
    $dialeg->Entry(-width => 50,
                   -textvariable => \$this->[5])
        ->grid(-row => 4, -column => 0, -columnspan => 2, -sticky => 'nw');
    $dialeg->Button(-text => '...',
                    -command => sub { $this->triarFile() })
        ->grid(-row => 4, -column => 2, -sticky => 'new');

    # Botons
    $dialeg->Button(-text => 'Generate',
                    -command => sub { $this->generar() })
        ->grid(-row => 5, -column => 1, -sticky => 'new');
    $dialeg->Button(-text => 'Close',
                    -command => sub { $this->sortir() })
        ->grid(-row => 5, -column => 2, -sticky => 'new');

    my $dialegLlista = new DialegLlista($dialeg, 'Summary Generation',
                                        30, [ "Yes", "No" ]);

    push(@{$this}, $etiqueta, $scaleMots, $taula,
         $result, 0, undef,
         [], [], $etiqColor,
         $dialegLlista);
    return bless($this, $classe);
}

# Control dels spinboxes
sub spin {
    my ($this, $orig) = @_;

    if ($orig == 0) {
        $this->[3] = int($this->[2] * $this->[10] / 100);
    } else {
        $this->[2] = int($this->[3] * 100 / $this->[10]);
    }

    if ($this->[4] <= $this->[3]) {
        $this->[14]->configure(-foreground => 'black');
    } else {
        $this->[14]->configure(-foreground => 'red');
    }
}

# Mostrar
sub mostrar {
    my ($this) = @_;

    # Actualitzem els controls
    $this->[10] = $this->[1]->getMotsDocument();
    $this->[6]->configure(-text => "% of $this->[10] words =");
    $this->[7]->configure(-to => $this->[10]);
    $this->[3] = int($this->[2] * $this->[10] / 100);

    # Vells chunks
    my @vellsChunks;
    @vellsChunks = @{$this->[11]} if $this->[11];

    # Obtenim els chunks
    my @chunks = $this->[1]->getChunks();
    $this->[11] = \@chunks;

    # Velles variables
    my @vellesVars;
    @vellesVars = @{$this->[12]} if $this->[12];

    # Construim la taula
    $this->[8]->createText(30, 10, -anchor => 'n', -text => 'Select');
    $this->[8]->createText(80, 10, -anchor => 'n', -text => 'Id');
    $this->[8]->createText(130,10, -anchor => 'n', -text => 'Subst');
    $this->[8]->createText(180,10, -anchor => 'n', -text => 'Weight');
    $this->[8]->createText(230,10, -anchor => 'nw', -text => 'Text');
    $this->[8]->createText(400,10, -anchor => 'n', -text => '#Words');

    my $aprofitat = 0;
    my $possible = 0;
    my $i = 1;
    my $canviSub = sub { $this->canviarResum() };
    foreach my $chunk (@chunks) {
        # Checkbox
        my $checkbutton =
            $this->[8]->Checkbutton(-variable => \$this->[12][$i - 1],
                                    -command => $canviSub);
        $this->[8]->createWindow(30, 5 + 20 * $i, -anchor => 'n',
                                 -window => $checkbutton);

        # Info
        $this->[8]->createText  (80, 10 + 20 * $i, -anchor => 'n',
                                 -text => $chunk->getId(),
                                 -fill => $chunk->getColor());
        $this->[8]->createText  (130, 10 + 20 * $i, -anchor => 'n',
                                 -text => $chunk->getSubst(),
                                 -fill => $chunk->getColor());
        $this->[8]->createText  (180, 10 + 20 * $i, -anchor => 'n',
                                 -text => $chunk->getAtributs()->[0]);

        # Text
        my $texte = $this->[1]->getFragmentText($chunk->getRange());
        $this->[13][$i - 1] = $texte;
        $texte = substr($texte, 0, 20)."..." if length($texte) > 23;
        $this->[8]->createText  (230, 10 + 20 * $i, -anchor => 'nw',
                                 -text => $texte);

        # #Words
        $this->[8]->createText  (400, 10 + 20 * $i, -anchor => 'n',
                                 -text => $chunk->getNWords());

        # Per defecte
        $this->[12][$i - 1] = 0;

        # Podem aprofitar el resultat?
        if ($possible < @vellsChunks) {
            my $j = $possible;
            while ($j < @vellsChunks) {
                if ($vellsChunks[$j] == $chunk) {
                    $this->[12][$i - 1] = $vellesVars[$j];
                    $aprofitat = 1;
                    $possible = $j + 1;
                    last;
                }
                # Next
                ++$j;
            }
        }

        # Next
        ++$i;
    }

    # AutoResum
    if ($aprofitat) {
        $this->canviarResum();
    } else {
        $this->autoResum();
    }

    # Nom de fitxer
    my $nomFitx = $this->[1]->getProjecte()->getDirOut();
    $nomFitx =~ s/([^\/])$/$1\//;
    $nomFitx .= $this->[1]->getFitxerActual().".mod";
    $this->[5] = $nomFitx;

    # Agafem el Grab
    $this->[0]->deiconify();
    $this->[0]->grab();
}

# Triar File
sub triarFile {
    my ($this) = @_;

    my $vInicial = $this->[5];

    my $result;
    if ($vInicial =~ /(.+\/)([^\/]*)$/) { # Es 'file' relatiu
        $result = $this->[0]->getOpenFile(-initialdir => $1)->Show();
    } else {
        $result = $this->[0]->getOpenFile(-initialdir => '.')->Show();
    }

    if (defined($result)) {
        $this->[5] = $result;
    }
}

# AutoResum
sub autoResum {
    my ($this) = @_;

    my $totalMots = 0;

    # Netegem el text
    $this->[9]->delete('1.0', 'end');

    # Netegem els seleccionats
    foreach (@{$this->[12]}) {
        $_ = 0;
    }

    # Grups ja sel·leccionats
    my %grups;

    for (my $pes = 1; $pes < 4; ++$pes) {
        my $i = 0;
        foreach my $chunk (@{$this->[11]}) {
            if ($chunk->getAtributs()->[0] == $pes
                && !defined($grups{$chunk->getSubst()})) {
                $totalMots += $chunk->getNWords();
                $this->[12][$i] = 1;
                $grups{$chunk->getSubst()} = 1;
            }
            ++$i;
        }
        last if $totalMots >= $this->[3];
    }

    $this->canviarResum();
}

# Sortir
sub sortir {
    my ($this) = @_;

    $this->grabRelease();
    $this->withdraw();

    # Netegem l'objecte
    @{$this->[13]} = ();
    $this->[8]->delete('all');
    $this->[8]->yviewMoveto(0.0);

    # No netegem els chunks
    # $this->[11] = undef;
    # @{$this->[12]} = ();
}

# Canviar Resum
sub canviarResum {
    my ($this) = @_;

    my $totalMots = 0;

    # Netegem el text
    $this->[9]->delete('1.0', 'end');
    my $i = 0;
    foreach my $chunk (@{$this->[11]}) {
        if ($this->[12][$i]) {
            $totalMots += $chunk->getNWords();
            $this->[9]->insert('end', "$this->[13][$i]", "tag$i");
            $this->[9]->tagConfigure("tag$i", -foreground => 'white',
                                     -background => $chunk->getColor());
            $this->[9]->insert('end', " ");
        }
        ++$i;
    }

    $this->[4] = $totalMots;
    if ($totalMots <= $this->[3]) {
        $this->[14]->configure(-foreground => 'black');
    } else {
        $this->[14]->configure(-foreground => 'red');
    }
}

# Generem un resum
sub generar {
    my ($this) = @_;

    # DialegLlista
    my $d = $this->[15];
    $d->netejarLlista();

    # Error?
    my $error = 0;

    # Fem verificacions
    # Verifiquem llargada
    if ($this->[4] > $this->[3]) {
        $d->afegirElement("Summary longer");
        $d->afegirElement(" than expected");
        $error = 1;
    }

    # Verifiquem que el fitxer no existeixi ja
    if (-e $this->[5]) {
        $d->afegirElement("Output file");
        $d->afegirElement(" exists");
        $error = 1;
    }

    my $i = 0;
    my %grups = ();
    foreach my $chunk (@{$this->[11]}) {
        if ($this->[12][$i]) {
            # Repeticio de substs?
            my $subst = $chunk->getSubst();
            if (++$grups{$subst} == 2) {
                $d->afegirElement("Subst $subst");
                $d->afegirElement(" appears more than once");
                $error = 1;
            }

            # Dependencies
            my $dep = $chunk->getSortints();
            for (my $j = 0; $j < @{$dep}; $j += 2) {
                # Comprovem que hi sigui
                if (!$this->[12][$dep->[$j + 1]->getId() - 1]) {
                    $d->afegirElement("Chunk ".$chunk->getId());
                    $d->afegirElement(" depends on chunk ".$dep->[$j + 1]->getId());
                    $error = 1;
                }
            }
        }
        ++$i;
    }

    if ($error) {
        $d->afegirElement("Generate Summary with Errors?");
        return if $d->Show() eq 'No';
    }

    # Generem el resum cap al fitxer
    my $fh = new IO::File("> $this->[5]");
    if (!$fh) {
        $this->[0]->messageBox(-icon => 'error',
                               -title => 'Error',
                               -message => "Can't open file",
                               -type => 'Ok');
        return;
    }

    $i = 0;
    foreach my $chunk (@{$this->[11]}) {
        $fh->print("$this->[13][$i] ") if $this->[12][$i];
        ++$i;
    }
    $fh->close();

    $this->missatge("Summary succesfully generated")
}

# Missatge
sub missatge {
    my ($this, $cadena) = @_;

    $this->[0]->messageBox(-icon => 'info', -type => 'Ok',
                           -message => $cadena,
                           -title => 'Summary Process');
}

# Retornem Cert
1;
