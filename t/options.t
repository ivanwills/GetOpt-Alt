#!/usr/bin/perl -w

BEGIN { $ENV{TESTING} = 1 }

use strict;
use warnings;
use List::Util qw/sum/;
use Test::More;
use Test::NoWarnings;
use GetOpt::Alt::Option;

my %valid = (
	'test' => {
		names => [qw/test tes te t/],
	},
	'test|other' => {
		names => [qw/test other tes othe te oth t ot o/],
	},
	'test|other|o' => {
		names => [qw/test other o tes othe te oth t ot/],
	},
	'inc+' => {
		increment => 1,
	}
);
my @invalid = qw(
	|test
);
my %matching = (
	test => [
		[qw/--test/],
		[qw/-t/],
	],
);

plan tests =>
	  (sum map { scalar keys %{ $valid{$_} } } keys %valid)
	+ @invalid
	+ (sum map { scalar @{ $matching{$_} } } keys %matching)
	+ 1;


