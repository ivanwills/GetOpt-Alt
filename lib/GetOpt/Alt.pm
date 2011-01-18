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
use Pod::Usage;

use overload (
    '@{}'  => \&get_files,
    'bool' => sub { 1 },
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
has default => (
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
    default => 1,
);
has ignore_case => (
    is      => 'rw',
    isa     => 'Bool',
    default => 1,
);
has help => (
    is      => 'rw',
    isa     => 'Str',
);
has cmds => (
    is      => 'rw',
    isa     => 'ArrayRef[GetOpt::Alt::Command]',
    default => sub { [] },
);

around BUILDARGS => sub {
    my ($orig, $class, @params) = @_;
    my %param;

    if (ref $params[0] eq 'HASH' && ref $params[1] eq 'ARRAY') {
        %param  = %{ $params[0] };
        @params = @{ $params[1] };
    }
    $param{options} ||= [];

    if ( !exists $param{helper} || $param{helper} ) {
        push @params, (
            'help',
            'man',
            'VERSION',
        );
        delete $param{helper};
    }

    while ( my $option = shift @params ) {
        push @{ $param{options} }, GetOpt::Alt::Option->new($option);
    }

    return $class->$orig(%param);
};

sub BUILD {
    my ($self) = @_;

}

sub get_options {
    my $caller = caller;

    my $self = __PACKAGE__->new(@_);

    $self->help($caller) if !$self->help || $self->help eq __PACKAGE__;

    $self->process();

    return $self;
}

sub process {
    my ($self, @args) = @_;
    if ( !@args ) {
        @args = @{ $self->argv } ? @{ $self->argv } : @ARGV;
    }
    for my $key ( keys %{ $self->opt } ) {
        delete $self->opt->{$key};
    }
    $self->opt( $self->default ? $self->default : {} );

    ARG:
    while (my $arg = shift @args) {
        my ($long, $short, $data);
        if ($arg =~ /^-- (\w[^=\s]+) (?:= (.*) )?/xms) {
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
        $opt->value( $self->opt->{ $opt->name } );

        my ($value, $used) = $opt->process( $long, $short, $data, \@args );
        $self->opt->{$opt->name} = $value;

        if ( !$used && $short && defined $data && length $data ) {
            unshift @args, '-' . $data;
        }
    }

    if (!@{ $self->argv } && $self->files) {
        @ARGV = @{ $self->files };
    }

    if ( $self->help ) {
         if ( $self->opt->{VERSION} ) {
             my ($name)  = $PROGRAM_NAME =~ m{^.*/(.*?)$}mxs;
             my $version = eval '$' . $self->help . '::VERSION';  ## no critic
             $version ||= 'undef';
             print "$name Version = $version\n";
             exit 1;
         }
         elsif ( $self->opt->{man} ) {
             pod2usage( -verbose => 2 );
         }
         elsif ( $self->opt->{help} ) {
             pod2usage( -verbose => 1 );
         }
    }

    return $self;
}

sub best_option {
    my ($self, $long, $short, $no) = @_;

    if ($no) {
        $long =~ s/^no-//xms;
    }

    for my $opt (@{ $self->options }) {
        return $opt if $long && $opt->name eq $long;

        for my $name (@{ $opt->names }) {
            return $opt if $long && $name eq $long;
            return $opt if $short && $name eq $short;
        }
    }

    return $self->best_option($long, $short, 1) if !$no;

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

=head2 C<new ( \%config, \@optspec )>

=head3 config

=over 4

=item C<default> - HashRef

Sets the default values for all the options. The values in opt will be reset
with the values in here each time process is called

=item C<files> - 

=item C<argv> - 

=item C<bundle> - 

=item C<ignore_case> - 

=item C<help> - 

=item C<cmds> - 

=back

Return: GetOpt::Alt -

Description:

=head3 C<get_options (@options | $setup, $options)>

This is the equivalent of calling new(...)->process

=head3 C<BUILD ()>

internal method

=head3 C<process ()>

=head3 C<best_option ()>

=head3 C<get_files ()>


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
