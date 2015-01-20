#!/usr/bin/perl

use strict;
use warnings;
use List::Util qw/sum/;
use Test::More;
use Test::Warnings;
use Getopt::Alt;

build();
get_opt();
done_testing();

sub build {
    my $opt = eval { Getopt::Alt->new({ helper => 0 }, []) };
    ok $opt;

    $opt = eval {
        Getopt::Alt->new(
            {
                helper      => 0,
                conf_prefix => 't/.',
            },
            ['foo|f']
        )
    };
    my $error = $@;
    SKIP: {
        if ( $error !~ /YAML/ ) {
            skip "Don't have the correct modules installed", 6;
        }

        ok !$error, "No error found"
            or diag "Error : $error";
        ok $opt, "Conf read with out error";
        ok $opt->default->{foo}, "--foo read";
        is $opt->aliases->{bar}[0], 'baz', "bar is baz";

        $opt = eval {
            Getopt::Alt->new(
                {
                    helper      => 0,
                    conf_prefix => 't/.',
                    name        => 'other',
                },
                ['foo|f']
            )
        };
        ok $opt, "Conf read with out error";
        ok !$opt->default->{foo}, "--foo not read";
    }
}

sub get_opt {
    my $opt = eval { get_options('test|t', 'foo|f', 'bar|b') };
    my $error = $@;
    SKIP: {
        if ( $error !~ /YAML/ ) {
            skip "Don't have the correct modules installed", 6;
        }
        ok !$error, 'no error' or diag $error;
    }
}

