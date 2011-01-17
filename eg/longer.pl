#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper qw/Dumper/;

use GetOpt::Alt qw/get_options/;
use GetOpt::Alt::Command;

main();

our $VERSION = 1.0;
my %default = (
    inc => 1,
    str => 'string',
);

sub main {

    my $opt = get_options(
        {
            cmds    => [ map { GetOpt::Alt::Command->new( cmd => $_ ) } qw/sub/ ],
            opt     => { %default },
            default => 1,
        },
        [
            'test|t',
            'inc|i+',
            'str|s=s',
            'verbose|v+',
        ],
    );

    if ($opt->opt->{test}) {
        print "In test mode!\n";
        }
        if ($opt->opt->{inc}) {
        print "Inc\n" x $opt->opt->{inc};
    }
    if ($opt->opt->{str}) {
        print "You said: " . $opt->opt->{str} . "\n";
    }
    if ($opt->opt->{verbose}) {
        print Dumper $opt->opt->{verbose} > 1 ? $opt : $opt->opt;
    }
}

__DATA__

=head1 NAME

longer.pl - a longer example file using GetOpt::Alt

=head1 SYNOPSIS

  longer.pl --help
  longer.pl [-t | --test] [--inc num |-inum] [--str str | -s str]

  OPTION:
   -t --test     Test mode
   -i --inc=numb Pass in a number
   -s --str=str  Pass in a string

   -v --verbose  Out put dump of GetOpt::Alt object use twice for more details
      --help     Should display this message and is defined in GetOpt::Alt itself
      --man      Should display the whole POD documentation
      --VERSION  Should show this script's verion number

=head1 REST

=cut
