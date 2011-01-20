#!/usr/bin/perl -w

BEGIN { $ENV{TESTING} = 1 }

use strict;
use warnings;
use List::Util qw/sum/;
use Test::More;
use Test::NoWarnings;
use Getopt::Alt::Option;

my @invalid = qw(
    |test
    test=q
    test=q?
    test=i?
    a||b
);

plan tests => @invalid + 1;

for my $args (@invalid) {
    my $opt;
    eval {
        $opt = Getopt::Alt::Option->new( $args );
    };

    ok( $@ || !$opt, "'$args' should fail" );
    diag Dumper $opt if $opt;
}

