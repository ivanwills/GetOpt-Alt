#!/usr/bin/perl -w

BEGIN { $ENV{TESTING} = 1 }

use strict;
use warnings;
use List::Util qw/sum/;
use Test::More;
#use Test::NoWarnings;
use GetOpt::Alt::Option;
use Data::Dumper qw/Dumper/;

my @valid = (
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
my %valid = @valid;

my $tests = ( sum map {scalar keys %{$valid{$_}} } keys %valid );
plan tests => $tests + 1;

for ( my $i = 0; $i < @valid; $i += 2 ) {
	diag my $args  = $valid[$i];
	my $tests = $valid[$i+1];
	my $opt   = GetOpt::Alt::Option->new( $args );

	for my $key ( keys %{ $tests } ) {
		is_deeply( $opt->$key(), $tests->{$key}, "$args -> $tests->{$key}" );
		diag "here";
	}
}

