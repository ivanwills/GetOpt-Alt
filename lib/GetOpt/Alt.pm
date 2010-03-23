package GetOpt::Alt;

# Created on: 2009-07-17 07:40:56
# Create by:  Ivan Wills
# $Id$
# $Revision$, $HeadURL$, $Date$
# $Revision$, $Source$, $Date$

use Moose;
use warnings;
use version;
use Carp;
use Scalar::Util;
use List::Util;
#use List::MoreUtils;
use Data::Dumper qw/Dumper/;
use English qw/ -no_match_vars /;
use base qw/Exporter/;
use GetOpt::Alt::Option;

use overload (
	'@{}' => \&get_files,
);

our $VERSION     = version->new('0.0.1');
our @EXPORT_OK   = qw/get_options/;
our %EXPORT_TAGS = ();
#our @EXPORT      = qw//;

has options => (
	is    => 'rw',
	isa   => 'ArrayRef[GetOpt::Alt::Option]',
);
has opt => (
	is      => 'rw',
	isa     => 'HashRef',
	default => sub { {} },
);
has files => (
	is      => 'rw',
	isa     => 'ArrayRef[Str]',
	default => sub {[]},
);
has argv => (
	is      => 'rw',
	isa     => 'ArrayRef[Str]',
	default => sub {[]},
);
has bundle => (
	is      => 'rw',
	isa     => 'Bool',
	default => 0,
);
has ignore_case => (
	is      => 'rw',
	isa     => 'Bool',
	default => 1,
);

around BUILDARGS => sub {
	my ($orig, $class, @params) = @_;
	my %param;

	if (ref $params[0] eq 'HASH' && ref $params[1] eq 'ARRAY') {
		%param = shift @params;
		@params = @{ $params[1] };
	}
	$param{options} ||= [];

	while (@params) {
		my $option = shift @params;
		push @{ $param{options} }, GetOpt::Alt::Option->new($option);
	}

	return $class->$orig(%param);
};

sub get_options {
	return __PACKAGE__->new(@_)->process;
}

sub process {
	my ($self, @args) = @_;
	@args = @{ $self->argv } ? @{ $self->argv } : @ARGV;

	ARG:
	while (my $arg = shift @args) {
		my ($long, $short, $data);
		if ($arg =~ /^-- (\w+) (?:= (.*) )?/xms) {
			$long = $1;
			$data = $2;
		}
		elsif ($arg =~ /^- (\w) (.*)/xms) {
			$short = $1;
			$data  = $2;
		}
		else {
			push @{ $self->files }, $arg;
			next ARG;
		}

		my $opt = $self->best_option( $long, $short );

		my $value = $opt->process( $long, $short, $data, \@args );
		$self->opt->{$opt->name} = $value;
	}

	if (!@{ $self->argv } && $self->files) {
		@ARGV = @{ $self->files };
	}

	return $self;
}

sub best_option {
	my ($self, $long, $short) = @_;

	for my $opt (@{ $self->options }) {
		return $opt if $long && $opt->name eq $long;

		for my $name (@{ $opt->names }) {
			return $opt if $long && $name eq $long;
			return $opt if $short && $name eq $short;
		}
	}

	die "Unknown option '" . ($long ? "--$long" : "-$short") . "'\n";
}

sub get_files {
	my ($self) = @_;

	return $self->files;
}

1;

__END__

=head1 NAME

GetOpt::Alt - Alternate method of processing command line arguments

=head1 VERSION

This documentation refers to GetOpt::Alt version 0.1.

=head1 SYNOPSIS

   use GetOpt::Alt;

   # Brief but working code example(s) here showing the most common usage(s)
   # This section will be as far as many users bother reading, so make it as
   # educational and exemplary as possible.

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head3 C<new ( $search, )>

Param: C<$search> - type (detail) - description

Return: GetOpt::Alt -

Description:

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.

Please report problems to Ivan Wills (ivan.wills@gmail.com).

Patches are welcome.

=head1 AUTHOR

Ivan Wills - (ivan.wills@gmail.com)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2009 Ivan Wills (14 Mullion Close, Hornsby Heights, NSW Australia 2077).
All rights reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. See L<perlartistic>.  This program is
distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.

=cut
