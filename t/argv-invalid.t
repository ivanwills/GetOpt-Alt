#!/usr/bin/perl -w

BEGIN { $ENV{TESTING} = 1 }

use strict;
use warnings;
use List::Util qw/sum/;
use Test::More tests => 6 + 1;
use Test::NoWarnings;
use GetOpt::Alt;
use Data::Dumper qw/Dumper/;

my $opt = GetOpt::Alt->new(
    {
        bundle => 1,
    },
    [
        'plain|p',
        'inc|i+',
        'negate|n!',
        'string|s=s',
        'integer|I=i',
        'float|f=f',
    ],
);

for my $argv ( argv() ) {
    eval { $opt->process( @{ $argv } ) };
    ok( $@, join ' ', @{ $argv }, 'fails') or diag Dumper $opt->opt;
}

sub argv {
    return (
        [ qw/--incclude / ],
        [ qw/-r         / ],
        [ qw/--string   / ],
        [ qw/-I   negate/ ],
        [ qw/-I 12negate/ ],
        [ qw/-f 2.3a    / ],
    );
}

