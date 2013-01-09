package Getopt::Alt;

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
use Getopt::Alt::Option;
use Getopt::Alt::Exception;
use Pod::Usage;
use TryCatch;

use overload (
    '@{}'  => \&get_files,
    'bool' => sub { 1 },
);

our $VERSION     = version->new('0.0.1');
our @EXPORT_OK   = qw/get_options/;
our %EXPORT_TAGS = ();
our $EXIT        = 1;
#our @EXPORT      = qw//;

has options => (
    is    => 'rw',
    isa   => 'ArrayRef[Getopt::Alt::Option]',
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
    isa     => 'ArrayRef[Getopt::Alt::Command]',
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
        push @{ $param{options} }, Getopt::Alt::Option->new($option);
    }

    return $class->$orig(%param);
};

sub BUILD {
    my ($self) = @_;

}

sub get_options {
    my $caller = caller;

    if ( @_ > 2 && ref $_[0] eq 'HASH' && ref $_[1] ne 'ARRAY' ) {
        my $options = shift @_;
        @_ = ( { default => $options}, [ @_ ] );
    }

    try {
        my $self = __PACKAGE__->new(@_);

        $self->help($caller) if !$self->help || $self->help eq __PACKAGE__;

        $self->process();

        return $self;
    }
    catch ($e) {
        if ( ref $e && ref $e eq 'Getopt::Alt::Exception' && $e->help ) {
            die $e;
        }

        warn $e;
        my $self = __PACKAGE__->new();

        $self->help($caller) if !$self->help || $self->help eq __PACKAGE__;

        $self->_show_help(1);
    }
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
        if ( $arg =~ /^-- (\w[^=\s]+) (?:= (.*) )?/xms ) {
            $long = $1;
            $data = $2;
        }
        elsif ( $arg =~ /^- (\w) =? (.*)/xms ) {
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
             my $version = defined $main::VERSION ? $main::VERSION : 'undef';
             die Getopt::Alt::Exception->new( message => "$name Version = $version\n", help => 1);
        }
        elsif ( $self->opt->{man} ) {
            $self->_show_help(2);
        }
        elsif ( $self->opt->{help} ) {
            $self->_show_help(1);
        }
    }

    return $self;
}

sub best_option {
    my ($self, $long, $short, $no) = @_;

    if ($no && $long) {
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

    if ( $self->help ) {
        $self->_show_help(1, "Unknown option '" . ($long ? "--$long" : "-$short") . "'")
    }
    else {
        confess "Unknown option '" . ($long ? "--$long" : "-$short") . "'\n";
    }
}

sub get_files {
    my ($self) = @_;

    return $self->files;
}

sub _show_help {
    my ($self, $verbosity, $msg) = @_;

    tie *OUT, 'ScalarHandle';
    pod2usage(
        $msg ? ( -msg => $msg ) : (),
        -verbose => $verbosity,
        -exitval => 'NOEXIT',
        -output  => \*OUT,
    );
    my $message = $ScalarHandle::out;
    close OUT;
    die Getopt::Alt::Exception->new( message => $message, help => 1 );
}

1;

package ScalarHandle;
use strict;
use warnings;
use parent qw/Tie::Handle/;

our $out = '';

sub TIEHANDLE {
    my ($class) = @_;
    $out = '';
    return bless {}, $class;
}
sub PRINT {
    my ($self, @lines) = @_;
    $out .= join '', @lines;
}
sub CLOSE { $out = '' }

1;

__END__

=head1 NAME

Getopt::Alt - Alternate method of processing command line arguments

=head1 VERSION

This documentation refers to Getopt::Alt version 0.1.

=head1 SYNOPSIS

   use Getopt::Alt;

   # Create a new options object
   my $opt = Getopt::Alt->new(
       {
           default => { string => 'default' },
       },
       [
           'string|s=s',
           ...
       ],
   );
   print "String = " . $opt->opt->{string} . "\n";

=head1 DESCRIPTION

The aim of C<Getopt::Alt> is to provide an alternative to L<Getopt::Long> that
allows your simple script to easily grow to a more complex script or to a
package with multiple commands. The simple usage is quite similar to
L<Getopt::Long>:

In C<Getopt::Long> you might get your options like:

 use Getopt::Long;
 my %options = ( string => 'default' );
 GetOptions(
     \%options,
     'string|s=s',
     ...
 );

The found options are now stored in the C<%options> hash.

In C<Getopt::Alt> you might do the following:

 use Getopt::Alt qw/get_options/;
 my %default = ( string => 'default' );
 my $opt = get_options(
     \%default,
     'string|s=s',
     ...
 );
 my %options = %{ $opt->opt };

This will also result in the options stored in the C<%options> hash.

Some other differences between Getopt::Alt and Getopt::Long include:

=over 4

=item *

Bundling - is on by default

=item *

Case sensitivity is on by default

=item *

Throws error rather than returning errors.

=back

=head1 SUBROUTINES/METHODS

=head2 C<new ( \%config, \@optspec )>

=head3 config

=over 4

=item C<default> - HashRef

Sets the default values for all the options. The values in opt will be reset
with the values in here each time process is called

=item C<files> - ArrayRef[Str]

Any arguments that not consumed as part of options (usually files), if C<argv>
was not specified then this value would be put back into C<@ARGV>.

=item C<argv> - ArrayRef[Str]

The arguments that you wish to process, this defaults to C<@ARGV>.

=item C<bundle> - bool

Turns on bundling of arguments eg C<-rv> is equivalent to C<-r -v>. This is
on by default.

=item C<ignore_case> - bool

Turns ignoring of the case of arguments, off by default.

=item C<helper> - bool

If set to a true value this will cause the help, man, and VERSION options to
be added the end of your

=item C<help> -

???

=item C<cmds> - ArrayRef[Getopt::Alt::Command]

If the Getopt::Alt is being used as part of a package where individual
commands have their own modules this parameter stores an instance of each
commands. (Not yet fully implemented.

=item C<options> - ArrayRef[Getopt::Alt::Option]

The individual command option specifications processed.

=item C<opt> - HashRef

The values processed from the argv.

=item C<default> - HashRef

The default values for each option. The default value is not modified by
processing, so if set the same default will be used from call to call.

=back

Return: Getopt::Alt -

Description:

=head3 C<get_options (@options | $setup, $options)>

=head3 C<get_options ($default, 'opt1', 'opt2' ... )>

This is the equivalent of calling new(...)->process but it does some extra
argument processing.

B<Note>: The second form is the same basically the same as Getopt::Long's
getOptions called with a hash ref as the first parameter.

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
