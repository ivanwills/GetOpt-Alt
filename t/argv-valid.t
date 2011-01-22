#!/usr/bin/perl -w

BEGIN { $ENV{TESTING} = 1 }

use strict;
use warnings;
use List::Util qw/sum/;
use Test::More tests => 32 + 1;
use Test::NoWarnings;
use Getopt::Alt;
use Data::Dumper qw/Dumper/;

my $opt = Getopt::Alt->new(
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
        'array|a=i@',
        'hash|h=s%',
    ],
);

for my $argv ( argv() ) {
    $opt->process( @{ $argv->[0] } );
    for my $test ( keys %{ $argv->[1] } ) {
        if ( ref $argv->[1]{$test} ) {
            is_deeply $opt->opt->{$test}, $argv->[1]{$test}, $test;
        }
        else {
            is $opt->opt->{$test}, $argv->[1]{$test}, $test;
        }
    }
}

sub argv {
    return (
        [ [ qw/--plain      / ] => { plain   => 1    } ],
        [ [ qw/ -p          / ] => { plain   => 1    } ],
        [ [ qw/ -pp         / ] => { plain   => 1    } ],
        [ [ qw/--inc        / ] => { inc     => 1    } ],
        [ [ qw/-i           / ] => { inc     => 1    } ],
        [ [ qw/--inc --inc  / ] => { inc     => 2    } ],
        [ [ qw/-ii          / ] => { inc     => 2    } ],
        [ [ qw/--negate     / ] => { negate  => 1    } ],
        [ [ qw/--no-negate  / ] => { negate  => 0    } ],
        [ [ qw/-n           / ] => { negate  => 1    } ],
        [ [ qw/--string=ab  / ] => { string  => 'ab' } ],
        [ [ qw/--string cd  / ] => { string  => 'cd' } ],
        [ [ qw/ -sef        / ] => { string  => 'ef' } ],
        [ [ qw/ -s gh       / ] => { string  => 'gh' } ],
        [ [ qw/ -s=ij       / ] => { string  => 'ij' } ],
        [ [ qw/ -s =k       / ] => { string  => '=k' } ],
        [ [ qw/--integer=9  / ] => { integer => 9    } ],
        [ [ qw/--integer 8  / ] => { integer => 8    } ],
        [ [ qw/ -I7         / ] => { integer => 7    } ],
        [ [ qw/ -I 6        / ] => { integer => 6    } ],
        [ [ qw/ -I=5        / ] => { integer => 5    } ],
        [ [ qw/--float=9.1  / ] => { float   => 9.1  } ],
        [ [ qw/--float 8.2  / ] => { float   => 8.2  } ],
        [ [ qw/ -f7.3       / ] => { float   => 7.3  } ],
        [ [ qw/ -f 6.4      / ] => { float   => 6.4  } ],
        [ [ qw/ -f=5.5      / ] => { float   => 5.5  } ],
        [ [ qw/-a 1         / ] => { array   => [1]              } ],
        [ [ qw/-a 1 -a 2    / ] => { array   => [1,2]            } ],
        [ [ qw/-a=3         / ] => { array   => [3]              } ],
        [ [ qw/-h h=a       / ] => { hash    => {h=>'a'        } } ],
        [ [ qw/-h h=b -h i=c/ ] => { hash    => {h=>'b', i=>'c'} } ],
        [ [ qw/-h=a=b       / ] => { hash    => { a => 'b'     } } ],
    );
}
