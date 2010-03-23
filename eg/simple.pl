#!/usr/bin/perl

use strict;
use warnings;

use GetOpt::Alt;

main();

sub main {

	my $opt = GetOpt::Alt->new(
		'test|t',
		'inc|i+',
		'str|s=s',
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
}
