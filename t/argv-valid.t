#!/usr/bin/perl -w

BEGIN { $ENV{TESTING} = 1 }

use strict;
use warnings;
use List::Util qw/sum/;
use Test::More tests => 8;
use Test::NoWarnings;
use GetOpt::Alt;
use Data::Dumper qw/Dumper/;

my $opt = GetOpt::Alt->new(
    {
        bundle => 1,
    },
    [
        'inc|i+',
        'negate|n!',
    ],
);

for my $argv ( argv() ) {
    $opt->process( @{ $argv->[0] } );
    for my $test ( keys %{ $argv->[1] } ) {
        is $opt->opt->{$test}, $argv->[1]{$test}, $test;
    }
}

sub argv {
    return (
        [ [ qw/--inc      / ] => { inc    => 1 } ],
        [ [ qw/-i         / ] => { inc    => 1 } ],
        [ [ qw/--inc --inc/ ] => { inc    => 2 } ],
        [ [ qw/-ii        / ] => { inc    => 2 } ],
        [ [ qw/--negate   / ] => { negate => 1 } ],
        [ [ qw/--no-negate/ ] => { negate => 0 } ],
        [ [ qw/-n         / ] => { negate => 1 } ],
    );
}
