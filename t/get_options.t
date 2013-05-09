#!/usr/bin/perl -w

BEGIN { $ENV{TESTING} = 1 }

use strict;
use warnings;
use List::Util qw/sum/;
use Test::More;
use Getopt::Alt qw/get_options/;
use Data::Dumper qw/Dumper/;

my @data = data();

for my $data (@data) {
    for my $test ( @{ $data->{tests} } ) {
        local @ARGV = @{ $test->{argv} };
        my $files = eval { get_options( @{ $data->{args} } ) };
        if ( $test->{success} ) {
            ok !$@, "'$test->{name}': No errors" or note $@;
            is_deeply [ @{ $files || [] } ], $test->{results}, "'$test->{name}': Files returned correctly" or note Dumper $files;
        }
        else {
            ok !$files && $@, "'$test->{name}': fails" or note Dumper { args => $data->{args}, ARGV => $test->{argv}, };
            note $@;
        }
    }
}

done_testing;

sub data {
    return (
        {
            args => [
                'test|t!',
            ],
            tests => [
                {
                    name    => 'Empty',
                    success => 1,
                    argv    => [],
                    results => [],
                },
                {
                    name    => 'with test',
                    success => 1,
                    argv    => [qw/-t -t/],
                    results => [],
                },
                {
                    name    => 'with file',
                    success => 1,
                    argv    => [qw/file/],
                    results => [qw/file/],
                },
                {
                    name    => 'with test and file',
                    success => 1,
                    argv    => [qw/-t file/],
                    results => [qw/file/],
                },
                {
                    name    => 'unknown option',
                    success => 0,
                    argv    => [qw/--unknown/],
                },
            ]
        },
        {
            args => [
                { data => [] },
                'test|t',
                'data|d=s@',
            ],
            tests => [
                {
                    name    => 'Name',
                    success => 1,
                    argv    => [],
                    results => [],
                },
                {
                    name    => 'with data',
                    success => 1,
                    argv    => [qw/-d data1 -d data2/],
                    results => [],
                },
                {
                    name    => 'Name',
                    success => 0,
                    argv    => [qw/-a/],
                },
            ]
        },
        {
            args => [
                {}, ['test|t', 'man', 'help', 'VERSION']
            ],
            tests => [
                {
                    name    => '--help (will die)',
                    success => 0,
                    argv    => [qw/--help/],
                },
                {
                    name    => '--man (will die)',
                    success => 0,
                    argv    => [qw/--man/],
                },
                {
                    name    => '--VERSION (will die)',
                    success => 0,
                    argv    => [qw/--VERSION/],
                },
                {
                    name    => 'no -h',
                    success => 0,
                    argv    => [qw/-h/],
                },
            ]
        },
    );
}

=head1 NAME

get_options.t - tests for get_options

=head1 SYNOPSIS

 get_options ...

=cut

