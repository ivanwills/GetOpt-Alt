#!/usr/bin/perl -w

BEGIN { $ENV{TESTING} = 1 }

use strict;
use warnings;
use List::Util qw/sum/;
use Test::More tests => 22 + 1;
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
    $opt->process( @{ $argv->[0] } );
    for my $test ( keys %{ $argv->[1] } ) {
        is $opt->opt->{$test}, $argv->[1]{$test}, $test;
    }
}

sub argv {
    return (
        [ [ qw/--plain    / ] => { plain   => 1    } ],
        [ [ qw/ -p        / ] => { plain   => 1    } ],
        [ [ qw/ -pp       / ] => { plain   => 1    } ],
        [ [ qw/--inc      / ] => { inc     => 1    } ],
        [ [ qw/-i         / ] => { inc     => 1    } ],
        [ [ qw/--inc --inc/ ] => { inc     => 2    } ],
        [ [ qw/-ii        / ] => { inc     => 2    } ],
        [ [ qw/--negate   / ] => { negate  => 1    } ],
        [ [ qw/--no-negate/ ] => { negate  => 0    } ],
        [ [ qw/-n         / ] => { negate  => 1    } ],
        [ [ qw/--string=ab/ ] => { string  => 'ab' } ],
        [ [ qw/--string cd/ ] => { string  => 'cd' } ],
        [ [ qw/ -sef      / ] => { string  => 'ef' } ],
        [ [ qw/ -s gh     / ] => { string  => 'gh' } ],
        [ [ qw/--integer=9/ ] => { integer => 9    } ],
        [ [ qw/--integer 8/ ] => { integer => 8    } ],
        [ [ qw/ -I7       / ] => { integer => 7    } ],
        [ [ qw/ -I 6      / ] => { integer => 6    } ],
        [ [ qw/--float=9.1/ ] => { float   => 9.1  } ],
        [ [ qw/--float 8.2/ ] => { float   => 8.2  } ],
        [ [ qw/ -f7.3     / ] => { float   => 7.3  } ],
        [ [ qw/ -f 6.4    / ] => { float   => 6.4  } ],
    );
}
