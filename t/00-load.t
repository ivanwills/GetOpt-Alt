#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 2 + 1;
use Test::NoWarnings;

BEGIN {
    use_ok( 'GetOpt::Alt' );
    use_ok( 'GetOpt::Alt::Option' );
}

diag( "Testing module $GetOpt::Alt::VERSION, Perl $], $^X" );
