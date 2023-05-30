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

# Interficie del PTkCha

use strict;

use XML::Parser;

use Tk;
use Tk::BrowseEntry;
use Tk::ROText;

use LlistaChunks;
use Chunk;
use Plugin;
use Filter;

use ConfigFile;
use ProjectManager;
use Projecte;

use InfoProject;
use InfoChunk;
use RelFrame;
use ProjectPopUp;

use OptionsDialog;
use PercentDialog;
use DefaultDialog;
use ProjectManagerDialog;

package Interficie;

# Utilitzarem el patro singleton
our $singleton;

# Versio
our $version = '2.8.2';

# Constructor
sub new {
    my ($classe) = @_;

    # Creem l'Objecte
    my $this = [];

    # Creem la finestra Principal
    my $win = new MainWindow(-title => "PTkChA : Perl/Tk Chunk Annotator -- v$version");

    # Creem els controls, en un principi tots Disableds
    my $infoProject = new InfoProject($this, $win);
    $infoProject->pack(-side => 'top', -fill => 'x');

    my $relFrame = new RelFrame($this, $win);
    $relFrame->pack(-side => 'right', -fill => 'y');

    my $centerFrame = $win->Scrolled('ROText', -scrollbars => 'se',
                                     -state => 'disabled',
                                     -wrap => 'word')
        ->pack(-side => 'top', -fill => 'both', -expand => 1);
    my $centralText = $centerFrame->Subwidget('scrolled');
    $relFrame->setGerma($centralText);

    my $infoChunk = new InfoChunk($win);
    $infoChunk->pack(-side => 'bottom', -fill => 'x');

    # Crem el menu
    my $barra = $win->Menu(-tearoff => 0);

    # Menu Projecte
    my $projMenu = $barra->Menu(-tearoff => 0);
    $projMenu->add('command', -label => 'Manage...',
                   -command => sub { $this->manageProjects() });
    $projMenu->add('separator');
    $projMenu->add('command', -label => 'Options...',
                   -command => sub { $this->opcions() });
    $projMenu->add('separator');
    $projMenu->add('command', -label => 'Quit',
                   -command => sub { $this->sortir() });
    $barra->add('cascade', -label => 'Project', -menu => $projMenu);

    # Menu Fitxer
    my $fileMenu = $barra->Menu(-tearoff => 0);
    $fileMenu->add('command', -label => 'Save',
                   -command => sub { $this->saveCurrent() });
    $fileMenu->add('command', -label => 'Revert',
                   -command => sub { $this->revert() });
    $fileMenu->add('command', -label => 'Initial Version',
                   -command => sub { $this->versioInicial() });
    $fileMenu->add('separator');
    $fileMenu->add('command', -label => 'Default Values...',
                   -command => sub { $this->changeDefaults() },
                   -state => 'disabled');
    $barra->add('cascade', -label => 'File', -menu => $fileMenu);

    # Menu Vista
    # (Inicialment buit)
    my $vistaMenu = $barra->Menu(-tearoff => 0);
    $barra->add('cascade', -label => 'View', -menu => $vistaMenu);

    # Menu Finestres
    my $windowMenu = $barra->Menu(-tearoff => 0);
    $windowMenu->add('command', -label => 'Chart',
                     -command => sub { $this->mostraLlegenda() });
    $barra->add('cascade', -label => 'Windows', -menu => $windowMenu);

    # Menu Plugin
    # (Inicialment buit)
    my $pluginMenu = $barra->Menu(-tearoff => 0);
    $barra->add('cascade', -label => 'Plugins', -menu => $pluginMenu);

    # Menu Ajuda
    my $helpMenu = $barra->Menu(-tearoff => 0);
    $helpMenu->add('command', -label => 'About...',
                   -command => sub { $this->about() });
    $barra->add('cascade', -label => 'Help', -menu => $helpMenu);

    $win->configure(-menu => $barra);

    # Menu Per a Popup
    my $popupMenu = new ProjectPopUp($this, $win);

    # Creem el ProjeKt Manager
    my $configFile     = new ConfigFile();
    my $projeKtManager = $configFile->getProjectManager();
    my $filterManager  = $configFile->getFilterManager();

    # Obtenir el cursor per defecte
    my $defaultCursor = $centralText->cget('-cursor');

    # Atributs
    #########################
    # 0: mode
    # 1: projecte
    # 2: centralText
    # 3: win
    # 4: infoProject
    # 5: relFrame
    # 6: infoChunk
    # 7: popUpMenu
    # 8: projectManager
    # 9: projectManagerDialog
    # 10:(unused)
    # 11:fitxerActual
    # 12:llistaChunks
    # 13:cursorMode
    # 14:cursorDefault
    # 15:parser
    # 16:configFile
    # 17:modificat
    # 18:cursorSobreChunk
    # 19:dialegOpcions
    # 20:menuVista
    # 21:vistaActual
    # 22:paraulesDocument
    # 23:percentDialog
    # 24:plugins
    # 25:pluginMenu
    # 26:defaults
    # 27:fileMenu
    # 28:filterManager
    @{$this} = ( 'inhab', undef, $centralText,
                 $win, $infoProject, $relFrame,
                 $infoChunk, $popupMenu, $projeKtManager,
                 undef, undef, '',
                 new LlistaChunks($centralText), $defaultCursor, $defaultCursor,
                 new XML::Parser(Style => 'Tree'), $configFile, 0,
                 'hand1', new OptionsDialog($win), $vistaMenu,
                 -1, 0, undef,
                 [], $pluginMenu, undef,
                 $fileMenu, $filterManager, undef
               );

    # Binding
    $centralText->bind('<Return>',   sub { $this->nouChunk(); });
    $centralText->bind('<Button-3>', sub { $this->nouChunk(); });
    $centralText->bind('<Shift-Button-1>', sub { $this->nouChunk(); });
    $centralText->bind('<Escape>',   sub { $this->cancel(); });
    $centralText->bind('Tk::ROText', '<Button-3>', '');
    $centralText->bind('Tk::ROText', '<Shift-Button-1>', '');

    # WM
    $win->protocol('WM_DELETE_WINDOW', sub { $this->sortir() });

    # Instanciem el singleton
    $singleton = $this;

    # Bless
    bless($this, $classe);

    # Initialization errors
    $win->idletasks();
    if ($this->[16]->{'_initErrors'}) {
        $this->mostrarError("Initialization Errors:\n" .
                            $this->[16]->{'_initErrors'});
    }

    # Done
    return $this;
}

#####################
# Comandes del Menu #
#####################

# Manegar els projectes
sub manageProjects {
    my ($this) = @_;

    if ($this->[9]) {
        $this->[9]->deiconify();
        $this->[9]->raise();
        $this->[9]->focus();
    } else {
        $this->[9] = new ProjectManagerDialog($this, $this->[3]);
        $this->[9]->populate($this->[8]);
        $this->[9]->protocol('WM_DELETE_WINDOW', sub { $this->[9]->destroy(); $this->[9] = undef });
    }
}

# Confirmacio
sub confirmacio {
    my ($this, $missatge) = @_;

    my $retorn = $this->[3]->messageBox(-icon => 'question', -type => 'YesNo',
                                        -message => $missatge,
                                        -title => 'Confirmacio');
    return $retorn eq 'Yes';
}

# Mostrar Error
sub mostrarError {
    my ($this, $missatge) = @_;

    $this->[3]->messageBox(-icon => 'error',
                           -title => 'Error',
                           -message => $missatge,
                           -type => 'Ok');
}

# Actualitzar Interficie
# Posa les dades d'un nou projecte
sub updateInterficie {
    my ($this, $projecte) = @_;

    # Savem el previ
    if ($this->[0] ne 'inhab') {
        # Tenim un text en marxa
        $this->saveCurrent();
        $this->freePlugins();
    }

    # Indiquem que es el projecte Actual
    $this->[1] = $projecte;

    # Si els controls estan deshabilitats, els habilitem
    $this->[2]->configure(-state => 'normal');

    # Mode normal
    $this->changeMode('normal');

    # Actualitzem els controls
    # Info Projecte
    $this->[4]->actualitzar($projecte);

    # Info Chunk
    $this->[6]->populate($projecte);

    # PopupMenu
    $this->[7]->populate($projecte);

    # Actualitzem el comptador
    $this->[23]->mostrarAtribut(-1) if $this->[23];

    # Vista
    $this->carregarVista();

    # Plugins
    $this->reservePlugins();

    # Activem la finestra de defaults
    $this->[26] = new DefaultDialog($this->[3], $projecte->getMarcatge());

    # Configurem el menu
    $this->[27]->entryconfigure(4, -state => ($this->[26] ? 'normal' : 'disabled'));
}

# Canviar el text
sub select {
    my ($this, $fitxer, $no_save) = @_;

    # Guardem l'actual
    $this->saveCurrent() unless $no_save;

    # Mode normal
    $this->changeMode('normal');

    # Esborrem el contingut del text central
    $this->[2]->delete("1.0", 'end');

    # Sel·leccionem el que toca
    if (($this->[11] = $fitxer)) {
        eval {
            $this->establirText($this->[1]->loadFile($fitxer));
        };
        # Hi ha hagut algun error
        $this->mostrarError($@) if $@;
    }

    # Actualitzem el comptador
    $this->[23]->updateAtribut() if $this->[23] && !$no_save;

    # Actualitzem la vista
    $this->canviarVista($this->[21]) unless $this->[21] == -1;
}

# Establir el text
sub establirText {
    my ($this, $cadena) = @_;

    # Cadena
    # print $cadena;

    # Obtenim el marcatge
    my $marcatge = $this->[1]->getMarcatge();
    my $etiqueta = $marcatge->getEtiqueta();

    # Netejem els chunks
    $this->[12]->clean();
    $this->[12]->setClustered($marcatge->isClustered());

    # Nombre de paraules
    $this->[22] = 0;

    # Substos
    my @substos  = ();

    # Relacions Pendents
    my %pendents = ();

    # Ids
    my %hashIds  = ();

    # Obtenim l'Arbre de Parsing
    my $arbre;
    eval {
        $arbre = $this->[15]->parse("<resum>$cadena</resum>");
    };

    if ($@) {
        # Indiquem l'error
        $this->[4]->setNombreMots('There are no');
        return;
    }

    # Anem recorrent el contingut
    my $contingut = $arbre->[1];
    shift(@{$contingut});

    # Recorrem l'Arbre Gran
    while (@{$contingut}) {
        my ($tag, $info) = (shift(@{$contingut}), shift(@{$contingut}));

        if ($tag eq '0') {
            # Text, l'afegim normalment
            $this->[2]->insert('end', $info);

            # Sumem nombre de paraules
            foreach my $mot (split(/ /, $info)) {
                ++$this->[22] if $mot;
            }

        } elsif ($tag eq $etiqueta) {
            # Un Chunk!!!

            # N'extraiem la informacio
            my $atributs = shift(@{$info});
            my ($relacions, $text);

            # Recorrem l'Arbre Menor
            while (@{$info}) {
                my ($tagC, $infoC) = (shift(@{$info}), shift(@{$info}));
                if ($tagC eq 'rels') {
                    $relacions = $infoC;

                } elsif ($tagC eq '0') {
                    $text .= $infoC;
                }
            }

            # Text buit
            next if !$text;

            # Creem el nou chunk
            my $chunk   = $this->[12]->newChunkSeq();
            my $freePos = $chunk->getPos();

            # Aqui comença el tag
            $this->[2]->insert('end', $text, "chunk$freePos");

            # Marquem els bindings del tag
            $this->[2]->tagBind("chunk$freePos", '<Button-3>',
                                [ sub { $this->botoDret($chunk, @_) },
                                Tk::Ev('X'), Tk::Ev('Y') ] );
            $this->[2]->tagBind("chunk$freePos", '<Shift-Button-1>',
                                [ sub { $this->botoDret($chunk, @_) },
                                Tk::Ev('X'), Tk::Ev('Y') ] );
            $this->[2]->tagBind("chunk$freePos", '<Button-1>',
                                sub { $this->clickar($chunk) });
            $this->[2]->tagBind("chunk$freePos", '<Enter>',
                                sub {
                                    $this->[6]->actualitzar($chunk);
                                    $this->[2]->configure(-cursor => $this->[18]);
                                });
            $this->[2]->tagBind("chunk$freePos", '<Leave>',
                                sub {
                                    $this->[6]->clean();
                                    $this->[2]->configure(-cursor => $this->[13]);
                                });
            my $p = $freePos;

            # Assignem la informació del Chunk
            my @rang = $this->[2]->tagRanges("chunk$freePos");
            $chunk->assignarRang($text, @rang);
            $chunk->assignarAtributs($atributs, $marcatge, \@substos, \%hashIds);
            $chunk->construirPendents($relacions, $marcatge, \%pendents);

            # Indiquem el color
            $this->[2]->tagConfigure("chunk$freePos",
                                     -foreground => 'white',
                                     -background => $chunk->getColor());

            # Sumem nombre de paraules
            $this->[22] += $chunk->getNWords();
        }
    }

    # Corregim els IDs
    my ($key, $valor);
    while (($key, $valor) = each(%pendents)) {
        foreach my $llista (@{$valor}) {
            next unless $llista;

            for (my $i = 1; $i < @{$llista}; $i += 2) {
                next if ref($llista->[$i]);

                if (defined($hashIds{$llista->[$i]})) {
                    # Tenim el Chunk destí
                    $llista->[$i] = $hashIds{$llista->[$i]};

                } else {
                    # Es un Chunk que hem esborrat
                    splice(@{$llista}, $i, 2);

                    # Tornem a fer el mateix
                    $i -= 2;
                }
            }
        }
    }

    # Assignem les relacions
    while (($key, $valor) = each(%pendents)) {
        $hashIds{$key}->assignarRelacions($valor) if $hashIds{$key};
    }

    # Renumerem
    $this->[12]->renumerarChunks();

    # Indiquem que no ha estat modificat
    $this->[17] = 0;

    # Mode de visio: subst
    # $this->[21] = -1;

    # Nombre de mots
    $this->[4]->setNombreMots($this->[22]);
}

# Sortir del programa
sub sortir {
    my ($this) = @_;

    # Grabem el que tinguem
    $this->saveCurrent();
    $this->freePlugins();

    # Guardem el Config file
    eval {
        $this->[16]->auRevoir();
    };

    # Error?
    if ($@) {
        my $error = $@; chomp($error);
        $this->mostrarError("$error: Settings not saved.\n");
    }

    # Mostrem missatge tranquilitzador
    # print "If it crashes here, nothing happens\n";

    exit(0);
}

# Guardar el fitxer actual
sub saveCurrent {
    my ($this) = @_;

    # Tornem si no hi ha res a fer
    return if $this->[0] eq 'inhab' || !$this->[11];

    # Tornem si no estem obligats a guardar i no cal
    return if !$this->[17] && !$this->[16]->{'ForWri'};

    # Obtenim la informacio
    my $cadena = '';
    $this->getTextActual(\$cadena);

    # Li diem al projecte que ho guardi
    $this->[1]->saveFile($this->[11], $cadena);

    # No ha estat modificat
    $this->[17] = 0;
}

# Obtenir el text actual
sub getTextActual {
    my ($this, $refCadena) = @_;

    $this->[2]->dump('-text', '-tag',
                     -command => sub { $this->buildCadena($refCadena, @_); },
                     '1.0', 'end');
}

# Construir la cadena
sub buildCadena {
    my ($this, $refCadena, $key, $value, $idx) = @_;

    if ($key eq 'text') {
        $$refCadena .= $value;

    } elsif ($key eq 'tagon') {
        if ($value =~ /^chunk(\d+)$/) {
            my $chunk = $this->[12]->getChunk($1);
            if ($chunk) {
                $$refCadena .= $this->[1]->getMarcatge()->buildCadena($chunk);
            }
        }

    } elsif ($key eq 'tagoff') {
        $$refCadena .= '</'.$this->[1]->getMarcatge()->getEtiqueta().'>' if $value =~ /^chunk\d+$/;
    }
}

# Premut enter
sub nouChunk {
    my ($this) = @_;

    # Si estem deshabilitats, res
    return if $this->[0] eq 'inhab';

    # Si no era normal, ara si -> cancel·lem
    # Nomes si estavem circulant, seguim
    if ($this->[0] eq 'circular') {
        $this->changeMode('normal');
    } elsif ($this->[0] ne 'normal') {
        $this->changeMode('normal');
        return;
    }

    # Marquem amb el tag Chungo
    # Trobem el que esta marcat
    my @rang = $this->[2]->tagRanges('sel');
    return unless @rang;

    # Ens expandim?
    @rang = $this->expandirSeleccio(@rang)
        if $this->[16]->{'SelExp'};

    return if $this->[2]->compare($rang[0], '>=', $rang[1]);

    # Comprovem el solapament amb altres chunks
    my @idx1 = split(/\./, $rang[0]);
    my @idx2 = split(/\./, $rang[1]);

    my ($solapament, $quin, $iniNou, $fiNou) =
        $this->[12]->trobarSolapament(\@idx1, \@idx2);

    if (!$solapament) {
        # Afegim un chunk!

        # Creem el nou chunk
        my $chunk   = $this->[12]->newChunkSeq();
        my $freePos = $chunk->getPos();

        $this->[2]->tagAdd("chunk$freePos", $rang[0], $rang[1]);
        $this->[2]->tagBind("chunk$freePos", '<Button-3>',
                            [ sub { $this->botoDret($chunk, @_) },
                              Tk::Ev('X'), Tk::Ev('Y') ] );
        $this->[2]->tagBind("chunk$freePos", '<Shift-Button-1>',
                            [ sub { $this->botoDret($chunk, @_) },
                              Tk::Ev('X'), Tk::Ev('Y') ] );
        $this->[2]->tagBind("chunk$freePos", '<Button-1>',
                            sub { $this->clickar($chunk) });
        $this->[2]->tagBind("chunk$freePos", '<Enter>',
                            sub {
                                $this->[6]->actualitzar($chunk);
                                $this->[2]->configure(-cursor => $this->[18]);
                            });
        $this->[2]->tagBind("chunk$freePos", '<Leave>',
                            sub {
                                $this->[6]->clean();
                                $this->[2]->configure(-cursor => $this->[13]);
                            });
        my $p = $freePos;

        # Assignem el rang
        $chunk->assignarRang($this->[2]->get($rang[0], $rang[1]), @rang);
        $chunk->atributsPerDefecte($this->[26]);

        # El meu color
        my $color;
        if ($this->[21] == -1) {
            $color = $chunk->getColor();
        } else {
            $color = $this->[1]->getMarcatge()
                ->colorAtribut($this->[21],
                               $chunk->getAtributs()->[$this->[21]]);
        }
        $this->[2]->tagConfigure("chunk$freePos",
                                 -foreground => 'white',
                                 -background => $color);

        # Renumerem
        $this->[12]->renumerarChunks();

        # Actualitzem el comptador
        $this->[23]->updateAtribut() if $this->[23];

        # Indiquem que ha estat modificat
        $this->[17] = 1;

    } elsif ($solapament eq 'inclusio' ||
             $solapament eq 'extensio') {

        # Traiem el tag antic
        $this->[2]->tagRemove("chunk$quin->[0]", $quin->[3], $quin->[4]);

        # Actualitzem la Info
        my ($iniX, $fiX) = ("$iniNou->[0].$iniNou->[1]",
                          "$fiNou->[0].$fiNou->[1]");
        $quin->assignarRang($this->[2]->get($iniX, $fiX), $iniX, $fiX);

        # Fem més petit o més gran
        $this->[2]->tagAdd("chunk$quin->[0]", $iniX, $fiX);

        # Actualitzem el comptador
        $this->[23]->updateAtribut() if $this->[23];

        # Indiquem que ha estat modificat
        $this->[17] = 1;
    }
    # Si es multiple, no fem res
}

# Expandir la seleccio
sub expandirSeleccio {
    my ($this, @rang) = @_;

    while ($this->[2]->compare($rang[0], '<', 'end') &&
           $this->[2]->get($rang[0]) =~ /\s/) {
        $rang[0] = $this->[2]->index("$rang[0] + 1 c");
    }
    $rang[0] = $this->[2]->index("$rang[0] wordstart");

    if ($this->[2]->get("$rang[1] - 1 c") =~ /\s/) {
        while ($this->[2]->compare($rang[1], '>', $rang[0]) &&
               $this->[2]->get("$rang[1] - 1 c") =~ /\s/) {
            $rang[1] = $this->[2]->index("$rang[1] - 1 c");
        }
    } elsif ($this->[2]->get("$rang[1]") !~ /\s/) {
        $rang[1] = $this->[2]->index("$rang[1] wordend");
    }

    return @rang;
}

# Boto Dret sobre un chunk
sub botoDret {
    my ($this, $chunk, $rot, $x, $y) = @_;

    # Si no era normal, ara si -> cancel·lem
    # Nomes si estavem circulant, seguim
    if ($this->[0] eq 'circular') {
        $this->changeMode('normal');
    } elsif ($this->[0] ne 'normal') {
        $this->changeMode('normal');
        return;
    }

    # Postegem el Menu
    $this->[7]->Post($chunk, $x, $y);
}

# Esborrar el chunk sel·leccionat
sub esborrarChunk {
    my ($this, $escollit) = @_;

    # Num
    my $num = $escollit->getPos();

    # Netejem el tag
    $this->[2]->tagDelete("chunk$num");

    # Esborrem la informació del chunk
    $this->[12]->esborrarChunk($num);

    # Netegem la info per si un cas
    $this->[6]->clean();

    # Renumerem
    $this->[12]->renumerarChunks();

    # Indiquem que ha estat modificat
    $this->[17] = 1;

    # Actualitzem el comptador
    $this->[23]->updateAtribut() if $this->[23];
}

# Clickar
sub clickar {
    my ($this, $chunk2) = @_;

    if ($this->[0] eq 'triarSubst') {
        # Comprovem que no siguin el mateix, ja
        my $chunk1 = $this->[7]->getActiveChunk();
        my ($g1, $g2) = map { $_->getInternalSubst() } ($chunk1, $chunk2);

        if ($g1 != $g2) {
            # Nou color, nou grup
            $this->[12]->annexionar($g1, $g2, $chunk2->getColor(),
                                    $this->[2]);

            # Renumerem els Chunks
            $this->[12]->renumerarChunks();

            # Indiquem que ha estat modificat
            $this->[17] = 1;
        }

        # Indiquem que no busquem companyia
        $this->changeMode('normal');

    } elsif ($this->[0] eq 'triarRel') {
        # Obtenim el nom de la relacio
        my ($nom, $ste) = $this->[7]->getActiveRel();
        my $chunk1 = $this->[7]->getActiveChunk();

        if ($chunk1 != $chunk2) {
            # Afegim la relacio
            $chunk1->addRel($nom, $ste, $chunk2);

            # Indiquem que ha estat modificat
            $this->[17] = 1;
        }

        # Passem a mode circular
        $this->[5]->actualitzar($chunk2);
        $this->changeMode('circular');

    } elsif ($this->[0] eq 'normal') {
        # Ens hem de posar en mode circular
        $this->[5]->actualitzar($chunk2);
        $this->changeMode('circular');

    } elsif ($this->[0] eq 'circular') {
        # Canviem de target
        $this->[5]->clean();
        $this->[5]->actualitzar($chunk2);

    } elsif ($this->[0] ne 'inhab') {
        # Tornem al mode normal
        $this->changeMode('normal');
    }
}

# Canvi de Mode
sub changeMode {
    my ($this, $mode) = @_;

    if ($mode ne $this->[0]) {
        # Desfem el mode anterior
        if ($this->[0] eq 'circular') {
            $this->[5]->clean();
        }

        # Fem tota la feina de canvi de mode
        if ($mode eq 'normal') {
            $this->[18] = 'hand1';
            $this->[13] = $this->[14];

        } elsif ($mode eq 'triarSubst') {
            $this->[18] = 'plus';
            $this->[13] = 'pirate';

        } elsif ($mode eq 'triarRel') {
            $this->[18] = 'sizing';
            $this->[13] = 'X_cursor';

        } elsif ($mode eq 'circular') {
            $this->[18] = 'exchange';
            $this->[13] = 'exchange';
        }

        # Configurem
        $this->[2]->configure(-cursor => $this->[13]);

        # Canviem
        $this->[0] = $mode;
    }
}

# Cancelar
sub cancel {
    my ($this) = @_;

    $this->changeMode('normal') unless $this->[0] eq 'inhab';
}

# Opcions
sub opcions {
    my ($this) = @_;

    $this->[19]->actualitzar($this->[16]);
    if ($this->[19]->Show() eq "OK") {
        $this->[19]->getResults($this->[16]);
    }
}

# Revertir
sub revert {
    my ($this, $force) = @_;

    # Si no ha estat modificat o no està segur, retornar
    return unless $force || $this->[17];
    return unless $force || $this->confirmacio("Lose the changes done?");

    # Mode normal
    $this->changeMode('normal');

    # Esborrem el contingut del text central
    $this->[2]->delete("1.0", 'end');

    # Sel·leccionem el que toca
    eval {
        $this->establirText($this->[1]->loadFile($this->[11]));
    };
    # Hi ha hagut algun error
    $this->mostrarError($@) if $@;
}

# Versio Inicial
sub versioInicial {
    my ($this, $force) = @_;

    # Si no s'està segur, retornar
    return unless $this->[11] && $this->confirmacio("Lose ALL changes done?");

    # Mode normal
    $this->changeMode('normal');

    # Esborrem el contingut del text central
    $this->[2]->delete("1.0", 'end');

    # Sel·leccionem el que toca
    eval {
        $this->[1]->removeFile($this->[11]);
        $this->establirText($this->[1]->loadFile($this->[11]));
    };
    # Hi ha hagut algun error
    $this->mostrarError($@) if $@;
}

# Canviar valors per defecte
sub changeDefaults {
    my ($this) = @_;

    $this->[26]->Show() if $this->[26];
}

# Carregar menu vista
sub carregarVista {
    my ($this) = @_;

    # Netegem el menu vista
    $this->[20]->delete(0, 'end');

    # Obtenir el marcatge
    my $marcatge = $this->[1]->getMarcatge();

    # Es clustered?
    if ($marcatge->isClustered()) {
        $this->[20]->add('radiobutton', -label => 'subst',
                         -value => -1, -variable => \$this->[21],
                         -command => sub { $this->canviarVista() });
    } else {
        $this->[20]->add('radiobutton', -label => 'id',
                         -value => -1, -variable => \$this->[21],
                         -command => sub { $this->canviarVista() });
    }

    $this->[20]->add('separator');

    # Per a cada atribut
    my $atributs = $marcatge->getAtributs();
    my $i = 0;
    foreach my $atr (@{$atributs}) {
        $this->[20]->add('radiobutton', -label => $atr->[0],
                         -value => $i++, -variable => \$this->[21],
                         -command => sub { $this->canviarVista() });
    }

    # Vista per defecte
    $this->[21] = -1;
}

# Canviar vista
sub canviarVista {
    my ($this) = @_;

    my $nAtribut = $this->[21];
    if ($nAtribut == -1) {
        # Recorrem els chunks i els reassignem el seu color
        foreach my $ch ($this->[12]->getChunks()) {
            $this->[2]->tagConfigure("chunk".$ch->getPos(),
                                     -background => $ch->getColor());
        }

    } else {
        my $marcatge = $this->[1]->getMarcatge();

        # Recorrem els chunks i els reassignem el color de l'atribut
        foreach my $ch ($this->[12]->getChunks()) {
            my $color = $marcatge->
                colorAtribut($nAtribut, $ch->getAtributs()->[$nAtribut]);
            $this->[2]->tagConfigure("chunk".$ch->getPos(),
                                     -background => $color);
        }
    }

    $this->[23]->mostrarAtribut($nAtribut) if $this->[23];
}

sub notificarCanviAtribut {
    my ($this, $num, $ch) = @_;

    return unless $this->[21] == $num;

    my $color = $this->[1]->getMarcatge()
        ->colorAtribut($num, $ch->getAtributs()->[$num]);
    $this->[2]->tagConfigure("chunk".$ch->getPos(),
                             -background => $color);

    # Actualitzem el comptador
    $this->[23]->updateAtribut() if $this->[23];
}

# Mostrar la llegenda
sub mostraLlegenda {
    my ($this) = @_;

    if ($this->[23]) {
        $this->[23]->deiconify();
        $this->[23]->raise();
        $this->[23]->focus();
    } else {
        $this->[23] = new PercentDialog($this, $this->[3]);
        $this->[23]->mostrarAtribut($this->[21]) unless $this->[0] eq 'inhab';
        $this->[23]->protocol('WM_DELETE_WINDOW', sub { $this->[23]->destroy(); $this->[23] = undef });
    }
}

# Reservar els plugins
sub reservePlugins {
    my ($this) = @_;

    # Agafem la llista de plugins
    my $plugins = $this->[1]->getMarcatge()->getPlugins();

    for (my $i = 0; $i < @{$plugins}; $i += 3) {
        eval {
            local @INC = @INC;
            push(@INC, split(':', $this->[16]->{'IncDir'}));

            eval "use $plugins->[$i+2]";
            die if $@;

            my $p = ($plugins->[$i+1])->new($this);
            my $menu = $p->makeMenu($this->[25]);

            push(@{$this->[24]}, $p);
            $this->[25]->add('cascade', -label => $plugins->[$i],
                             -menu => $menu);
        };
        print $@ if $@;
    }
}

# Alliverar els plugins
sub freePlugins {
    my ($this) = @_;

    foreach my $plugin (@{$this->[24]}) {
        $plugin->free();
    }

    # Buidem la llista
    @{$this->[24]} = ();

    # Buidem el plugin menu
    $this->[25]->delete(0, 'end');
}

# Consultores
sub getChunks         { return $_[0]->[12]->getChunks(); }
sub getProjecte       { return $_[0]->[1]; }
sub getMotsDocument   { return $_[0]->[22]; }
sub getFragmentText   { return $_[0]->[2]->get($_[1], $_[2]); }
sub getFitxerActual   { return $_[0]->[11]; }
sub setModificat      { $_[0]->[17] = 1; }
sub getProjectManager { return $_[0]->[8]; }

# About
sub about {
    my ($this) = @_;

    $this->[3]->
        messageBox(-icon => 'info', -type => 'Ok',
                   -message => ("PTkChA v$version\n" .
                                "by Edgar Gonzalez i Pellicer\n" .
                                "TALP Research Center\nBarcelona, 2004-2011\n" .
                                "egonzalez\@lsi.upc.edu"),
                   -title => 'About...');
}

# Retornem Cert
1;
