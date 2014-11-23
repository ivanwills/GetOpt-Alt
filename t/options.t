#!/usr/bin/perl

use strict;
use warnings;
use List::Util qw/sum/;
use Test::More;
use Test::Warnings;
use Getopt::Alt::Option;

option_type();
done_testing();

sub option_type {
    my $class_name = 'Getopt::Alt::Dynamic::Test';
    my $object = Moose::Meta::Class->create(
        $class_name,
        superclasses => [ 'Getopt::Alt::Dynamic' ],
    );

    my $opt = build_option($object, ['one|o']);
    ok $opt, "Create opt from array";

    $opt = build_option($object, 'two|t');
    ok $opt, "Create opt from string";

    $opt = build_option($object, {
        name  => 'three',
        names => [qw/ three T /],
        opt   => 'three|T',
    });
    ok $opt, "Create opt from hash";

    $opt = build_option(
        $object,
        name  => 'three',
        names => [qw/ three T /],
        opt   => 'three|T',
    );
    ok $opt, "Create opt from hash";

    $opt = build_option($object, 'four|f=d');
    ok $opt, "Create opt for a digit";

    eval { build_option($object, sub {'four'}) };
    ok $@, "Bad reference";

    eval { build_option($object, 'five|f@') };
    ok $@, "Bad reference";

    # bad spec
    eval { build_option($object, '|') };
    ok $@, "Bad spec";

    # bad spec
    eval { build_option($object, 'a||q') };
    ok $@, "Bad spec";
}
