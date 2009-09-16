#!/usr/bin/perl -w

BEGIN { $ENV{TESTING} = 1 }

use strict;
use warnings;
use List::Util qw/sum/;
use Test::More;
use Test::NoWarnings;
use GetOpt::Alt::Option;

my @invalid = qw(
	|test
	test=q
);

plan tests => @invalid + 1;

for my $args (@invalid) {
	my $opt;
	eval {
		$opt = GetOpt::Alt::Option->new( opt => $args );
	};

	ok( $@ || !$opt, "'$args' should fail" );
}

