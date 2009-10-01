#!/usr/bin/perl -w

BEGIN { $ENV{TESTING} = 1 }

use strict;
use warnings;
use List::Util qw/sum/;
use Test::More;
use Test::NoWarnings;
use GetOpt::Alt::Option;

my %miss_matching = {
	test => [
		[qw/--test/],
		[qw/-t/],
	],
};

plan tests => sum map { scalar @{ $miss_matching{$_} } } keys %miss_matching + 1;



