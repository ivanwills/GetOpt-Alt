#!/usr/bin/perl -w

BEGIN { $ENV{TESTING} = 1 }

use strict;
use warnings;
use List::Util qw/sum/;
use Test::More;
use Getopt::Alt qw/get_options/;
use Data::Dumper qw/Dumper/;

sub_simple();
sub_array();
sub_array_complex();
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
    is $opt->out, 'thing', 'first inputs processed correctly';
    is $ARGV[0], '--not-processed', 'Param not processed';
    #diag Dumper $opt;
}

sub sub_array {
    @ARGV = qw/ -o thing cmd --processed/;
    my $opt = eval {
        Getopt::Alt->new(
            {
                sub_command => {
                    cmd => [
                        'processed|p',
                    ],
                },
            },
            [
                'out|o=s',
            ]
        )->process
    };

    ok $opt, 'Get options'
        or diag $@;
    is $opt->cmd, 'cmd', 'The command cmd is found correctly';
    ok $opt->opt->can('processed'), 'Processed sub parameter is present';
}

sub sub_array_complex {
    my $opt = eval {
        Getopt::Alt->new(
            {
                sub_command => {
                    cmd => [
                        {
                            default => {
                                out       => 'local default',
                                processed => 'false',
                            },
                        },
                        [ 'processed|p=s', ],
                    ],
                },
                default => {
                    other => 'global default',
                },
            },
            [
                'out|o=s',
                'other|t=s',
            ]
        )
    };
    eval { $opt->process(qw/ -o thing cmd --processed yes/) };

    ok $opt, 'Get options'
        or diag $@;
    is $opt->cmd, 'cmd', 'The sub command cmd is found correctly';
    ok $opt->opt->can('processed'), 'Processed sub parameter is present';
    is $opt->opt->processed, 'yes', 'The processed sub command parameter is what we expect';

    # Check default parameters
    $opt->process(qw/cmd/);

    ok $opt, 'Get options'
        or diag $@;
    is $opt->opt->processed, 'false', 'The processed sub command parameter is the default value';
    is $opt->opt->out, 'local default', 'The out parameter is the sub command default value';
    is $opt->opt->other, 'global default', 'The other parameter is the default value';
}

sub sub_code {
}

