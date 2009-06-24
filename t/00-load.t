#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'GetOpt::Alt' );
}

diag( "Testing GetOpt::Alt $GetOpt::Alt::VERSION, Perl $], $^X" );
