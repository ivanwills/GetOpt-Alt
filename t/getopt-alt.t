#!/usr/bin/perl

use strict;
use warnings;
use List::Util qw/sum/;
use Test::More;
use Test::Warnings;
use Getopt::Alt;

build();
done_testing();

sub build {
    my $opt = eval { Getopt::Alt->new({ helper => 0 }, []) };
    ok $opt;
}

