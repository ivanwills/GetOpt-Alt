#!/usr/bin/perl -w

BEGIN { $ENV{TESTING} = 1 }

use strict;
use warnings;
use List::Util qw/sum/;
use Test::More;
use Test::NoWarnings;
use GetOpt::Alt::Option;

my %miss_matching => {
	test => [
		[qw/--test/],
		[qw/-t/],
	],
};

plan test => sum map {} %miss_matching + 1;



