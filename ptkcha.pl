#!/usr/local/perl-5.8.0/bin/perl
# PTkCha

use strict;

# Load from the execution dir, if possible
BEGIN {
    $0 =~ /(^|.*\/)([^\/]+)$/;
    unshift(@INC, $1 ? $1 : '.');
}

use Tk;

use Interficie;

new Interficie();
MainLoop();
