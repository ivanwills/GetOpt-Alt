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
    eval { Getopt::Alt->new() };
    like $@, qr/Incorrect arguments to Getopt::Alt->new!/, "Bad arguments";
    eval { Getopt::Alt->new({ helper => 0 }) };
    like $@, qr/Incorrect arguments to Getopt::Alt->new!/, "Bad arguments";

    eval { Getopt::Alt->new({ helper => 0 }, []) };
    like $@, qr/No options supplied!/, "Error with out any options supplied";
}

