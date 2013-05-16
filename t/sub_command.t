#!/usr/bin/perl -w

BEGIN { $ENV{TESTING} = 1 }

use strict;
use warnings;
use List::Util qw/sum/;
use Test::More;
use Getopt::Alt qw/get_options/;
use Data::Dumper qw/Dumper/;

sub_simple();
sub_hash();
sub_code();
done_testing();

sub sub_simple {
    @ARGV = qw/ -o thing cmd --not-processed/;
    my $opt = eval {
        get_options(
            {
                sub_command => 1,
            },
            [
                'out|o=s',
            ]
        )
    };
    ok $opt, 'Get options'
        or diag $@;
    is $opt->options->out, 'thing', 'first inputs processed correctly';
    is $ARGV[0], '--not-processed', 'Param not processed';
    #diag Dumper $opt;
}
sub sub_hash {
}
sub sub_code {
}
