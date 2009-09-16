#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 1 + 1;
use Test::NoWarnings;

BEGIN {
	use_ok( 'module' );
}

diag( "Testing module $module::VERSION, Perl $], $^X" );
