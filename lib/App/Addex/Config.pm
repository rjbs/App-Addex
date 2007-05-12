#!/usr/bin/perl
use strict;
use warnings;

package App::Addex::Config;
use base qw(Config::INI::Reader);

=head1 NAME

App::Addex::Config - read the addex config file

=head1 VERSION

version 0.006

  $Id$

=cut

our $VERSION = '0.006';

=head1 DESCRIPTION

The F<addex> config file is an INI file in which some properties may be given
multiple times to produce multiple values.  These properties will be given
in the documentation for the relevant plugins.  If multiple values are found
for an existing property which I<cannot> be given multiple times, an exception
will be raised.

Each section is assumed to be a plugin which must be loaded and queried for its
multiple-value properties.

=cut

sub new {
  my ($class) = @_;

  my $self = $class->SUPER::new;

  $self->{__PACKAGE__}{classes}{multivalue_args} = [ qw(output) ];

  bless $self => $class;
}

sub starting_section { 'classes' }

sub change_section {
  my ($self, $section) = @_;

  $self->{section} = $section;
  $self->{data}{ $self->{section} } ||= {};
  return if $self->{__PACKAGE__}{$section};

  # Consider using Params::Util to validate class name.  -- rjbs, 2007-05-11
  Carp::croak "invalid section name '$section' in configuration"
    unless $section =~ /\A[A-Z0-9]+(?:::[A-Z0-9]+)*\z/i;
  
  eval "require $section"
    or Carp::croak "couldn't load plugin $section named on config: $@";

  my $conf = $self->{__PACKAGE__}{$section} = {};

  if ($section->can('multivalue_args')) {
    $conf->{multivalue_args} = [ $section->multivalue_args ];
  } else {
    $conf->{multivalue_args} = [ ];
  }
}

sub set_value {
  my ($self, $name, $value) = @_;

  my $section = $self->{data}{ $self->{section} } ||= {};

  my $mva = $self->{__PACKAGE__}->{ $self->{section} }->{multivalue_args};

  if (grep { $_ eq $name } @$mva) {
    $section->{$name} ||= [];
    push @{ $section->{$name} }, $value;
    return;
  }

  if (exists $section->{$name}) {
    Carp::croak
      "multiple values given for property $name in section $self->{section}";
  }

  $section->{$name} = $value;
}

=head1 AUTHOR

Ricardo SIGNES, C<< <rjbs@cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll automatically be
notified of progress on your bug as I make changes.

=head1 COPYRIGHT

Copyright 2007 Ricardo Signes, all rights reserved.

This program is free software; you may redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
