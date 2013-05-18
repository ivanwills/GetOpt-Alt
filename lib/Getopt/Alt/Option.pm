package Getopt::Alt::Option;

# Created on: 2009-07-17 14:52:26
# Create by:  Ivan Wills
# $Id$
# $Revision$, $HeadURL$, $Date$
# $Revision$, $Source$, $Date$

use strict;
use warnings;
use version;
use Moose::Role;
use Carp;
use Scalar::Util;
use List::Util;
use Data::Dumper qw/Dumper/;
use English qw/ -no_match_vars /;

Moose::Exporter->setup_import_methods(
    as_is     => [qw/build_option/],
    #with_meta => ['operation'],
);


our $VERSION = version->new('0.0.3');

Moose::Util::meta_attribute_alias('Getopt::Alt::Option');

has opt => (
    is       => 'ro',
    required => 1,
);
has name => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);
has names => (
    is       => 'rw',
    isa      => 'ArrayRef[Str]',
    required => 1,
);
has increment => (
    is  => 'rw',
    isa => 'Bool',
);
has negatable => (
    is  => 'rw',
    isa => 'Bool',
);
has nullable => (
    is  => 'rw',
    isa => 'Bool',
);
has config => (
    is  => 'ro',
    isa => 'Bool',
);
has project => (
    is  => 'ro',
    isa => 'Bool',
);
has ref => (
    is  => 'ro',
    isa => 'Str',
);
has type => (
    is  => 'ro',
    isa => 'Str',
);
has value => (
    is        => 'rw',
    isa       => 'Any',
    predicate => 'has_value',
);

my $r_name     = qr/ [^|\s=+!-][^|\s=+!?]* /xms;
my $r_alt_name = qr/ $r_name | \\d /xms;
my $r_names    = qr/ $r_name (?: [|] $r_alt_name)* /xms;
my $r_type     = qr/ [nifsd] /xms;
my $r_ref      = qr/ [%@] /xms;
my $r_type_ref = qr/ = $r_type $r_ref? /xms;
my $r_inc      = qr/ [+] /xms;
my $r_neg      = qr/ [!] /xms;
my $r_null     = qr/ [?] /xms;
my $r_spec     = qr/^ ( $r_names ) ( $r_inc | $r_neg | $r_type_ref )? ( $r_null )? $/xms;

# calling new => ->new( 'test|t' )
#                ->new( name => 'text', names => [qw/test tes te t/], ... )
#                ->new({ name => 'text', names => [qw/test tes te t/], ... )
sub build_option {
    my ($class, @params) = @_;

    if (@params == 1 && ref $params[0]) {
        @params =
              ref $params[0] eq 'ARRAY' ? @{ $params[0] }
            : ref $params[0] eq 'HASH'  ? %{ $params[0] }
            :                             confess "Can't supply a " . (ref $params[0]) . " ref to new!";
    }
    if (@params == 1 && !ref $params[0]) {
        my $spec = pop @params;
        push @params, (opt => $spec);

        confess "$spec doesn't match the specification definition! (qr/$r_spec/)" if $spec !~ /$r_spec/;

        my ($names, $options, $null) = $spec =~ /$r_spec/;
        my @names = split /\|/, $names;
        if ( !@names || grep {!defined $_ || length $_ == 0 || !/$r_name/} @names ) {
            confess "Invalid option spec '$spec'\n" . Dumper \@names;
        }
        push @params, 'names', \@names;
        push @params, 'name', $names[0];

        if ( $null && $null eq '?' ) {
            push @params, 'nullable' => 1;
        }

        if ($options) {
            my ($type, $extra);
            if ( my ($option) = $options =~ /^ ( [=+!] ) /xms) {
                if ($option eq '=') {
                    ($type, $extra) = split /;/, $options;
                }
                else {
                    ($extra) = $options =~ /^;(.*)/xms;
                    if ($option eq '+') {
                        push @params, 'increment' => 1;
                    }
                    elsif ($option eq '!') {
                        push @params, 'negatable' => 1;
                    }
                }
            }

            if ($type) {
                my ($text, $ref);
                $type =~ s/^=//;
                die "Unknown type in option spec '$spec' ($type)\n" if $type !~ /^ $r_type $r_ref? $/xms;
                if ( length $type == 1 ) {
                    ($text) = $type =~ /^ ([nifsd]) $/xms;
                    croak "Bad spec $spec, Unknown type $type" if !$text;
                }
                elsif ( length $type == 2 ) {
                    ($text, $ref) = $type =~ /^ ($r_type) ($r_ref) $/xms;
                    push @params,
                         ref =>
                               $ref eq '%' ? 'HashRef'
                             : $ref eq '@' ? 'ArrayRef'
                             :               confess "Unknown reference type '$ref' in '$spec'";
                }
                push @params,
                    type =>
                          $text eq 's' ? 'Str'
                        : $text eq 'd' ? 'Int'
                        : $text eq 'i' ? 'Int'
                        : $text eq 'f' ? 'Num'
                        : $text eq 'n' ? 'Num'
                        :                confess "Unknown type spec '$type' in '$spec'";
            }
        }
    }
    my %params = @params;
    $params{traits} = ['Getopt::Alt::Option'];

    my $type
        = $params{type} && $params{ref} ? "$params{ref}\[$params{type}\]"
        : $params{type}                 ? $params{type}
        : $params{ref}                  ? $params{ref}
        :                                 'Str';

    if ( $params{nullable} ) {
        $type = "Maybe[$type]";
    }

    $class->add_attribute(
        $params{name},
        is   => 'rw',
        isa  => $type,
        %params,
    );

    return $class->get_attribute( $params{name} );
}

sub process {
    my ($self, $long, $short, $data, $args) = @_;

    my $name = $long ? "--$long" : "-$short";
    my $value;
    my $used = 0;
    if ($self->type) {
        $used = 1;
        if ( !defined $data || length $data == 0 ) {
            confess "No " . $self->type . " passed for $name\n"
                if ( ! defined $args->[0]  && !$self->nullable ) || (
                    $args->[0] && $args->[0] =~ /^-/ && !( $self->type eq 'Int' || $self->type eq 'Num' )
                );

            $data = shift @$args;
        }
        elsif ( $self->ref || grep { $self->type eq $_ } qw/Int Num Str/ ) {
            if ( $data && !$self->nullable ) {
                $data =~ s/^=//xms;
            }
        }

        my $key;
        if ($self->ref && $self->ref eq 'HashRef') {
            ($key, $data) = split /=/, $data, 2;
        }

        $value =
              $self->nullable      && ( !defined $data || $data eq '' )                 ? undef
            : $self->type eq 'Int' && $data =~ /^ -? \d+$/xms                           ? $data
            : $self->type eq 'Num' && $data =~ /^ -? (?: \d* (?: [.]\d+ )? | \d+ )$/xms ? $data
            : $self->type eq 'Str' && length $data > 0                                  ? $data
            :                                                                             confess "The value '$data' is not of type '".$self->type."'\n";

        if ($self->ref) {
            my $old;
            if ($self->ref eq 'ArrayRef') {
                $old = $self->value || [];
                push @$old, $value;
            }
            elsif ($self->ref eq 'HashRef') {
                $old = $self->value || {};
                $old->{$key} = $value;
            }
            else {
                confess "Unknown reference type '" . $self->ref . "' (from " . $self->opt . ")\n";
            }
            $value = $old;
        }
    }
    elsif ($self->increment) {
        $value = ($self->value || 0) + 1;
    }
    elsif ($self->negatable) {
        $value = $long && $long =~ /^no-/ ? 0 : 1;
    }
    else {
        $value = 1;
    }

    $self->value($value);

    return ( $self->value, $used );
}

1;

__END__

=head1 NAME

Getopt::Alt::Option - Sets up a particular command line option

=head1 VERSION

This documentation refers to Getopt::Alt::Option version 0.0.3.


=head1 SYNOPSIS

   use Getopt::Alt::Option;

   # Brief but working code example(s) here showing the most common usage(s)
   # This section will be as far as many users bother reading, so make it as
   # educational and exemplary as possible.


=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 C<build_option ( $class, @params )>

This is a helper function to create an C<Getopt::Alt::Option> attribute on the
supplied C<$class> object.

=head2 C<process ($long, $short, $data, $args)>

Processes the option against the supplied $data or $args->[0] if no $data is set

=head1 DIAGNOSTICS

A list of every error and warning message that the module can generate (even
the ones that will "never happen"), with a full explanation of each problem,
one or more likely causes, and any suggested remedies.

=head1 CONFIGURATION AND ENVIRONMENT

A full explanation of any configuration system(s) used by the module, including
the names and locations of any configuration files, and the meaning of any
environment variables or properties that can be set. These descriptions must
also include details of any configuration language used.

=head1 DEPENDENCIES

A list of all of the other modules that this module relies upon, including any
restrictions on versions, and an indication of whether these required modules
are part of the standard Perl distribution, part of the module's distribution,
or must be installed separately.

=head1 INCOMPATIBILITIES

A list of any modules that this module cannot be used in conjunction with.
This may be due to name conflicts in the interface, or competition for system
or program resources, or due to internal limitations of Perl (for example, many
modules that use source code filters are mutually incompatible).

=head1 BUGS AND LIMITATIONS

A list of known problems with the module, together with some indication of
whether they are likely to be fixed in an upcoming release.

Also, a list of restrictions on the features the module does provide: data types
that cannot be handled, performance issues and the circumstances in which they
may arise, practical limitations on the size of data sets, special cases that
are not (yet) handled, etc.

The initial template usually just has:

There are no known bugs in this module.

Please report problems to Ivan Wills (ivan.wills@gmail.com).

Patches are welcome.

=head1 AUTHOR

Ivan Wills - (ivan.wills@gmail.com)
<Author name(s)>  (<contact address>)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2009 Ivan Wills (14 Mullion Close, Hornsby Heights, NSW Australia 2077).
All rights reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. See L<perlartistic>.  This program is
distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.

=cut
