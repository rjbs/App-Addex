#!/usr/bin/perl
use strict;
use warnings;

package App::Addex::Entry;

use Carp ();

=head1 NAME

App::Addex::Entry - an entry in your address book

=head1 VERSION

version 0.009

=cut

our $VERSION = '0.009';

=head1 METHODS

B<Achtung!>  The API to this code may very well change.

=head2 new

  my $entry = App::Addex::Entry->new(\%arg);

This method returns an Addex Entry object.

Valid parameters (sure to change) are:

  name   - a full name (required)
  nick   - a nickname (optional)
  emails - an arrayref of email addresses (required)

=cut

sub new {
  my ($class, $arg) = @_;

  # XXX: do some validation -- rjbs, 2007-04-06
  my $self = {
    name   => $arg->{name},
    nick   => $arg->{nick},
    emails => $arg->{emails},

    fields => $arg->{fields}, # eliminate,
  };

  bless $self => $class;
}

=head2 name

=head2 nick

These methods return the value of the property they name.

=cut

sub name { $_[0]->{name} }
sub nick { $_[0]->{nick} }

=head2 emails

This method returns the entry's email addresses.  In scalar context it returns
the number of addresses.

=cut

sub emails { @{ $_[0]->{emails} } }

=head2 field

B<Achtung!> Possibly not long for this world.

  my $value = $entry->field($name);

This method returns the value, if any, for the named field.

=cut

sub field {
  my ($self, $field) = @_;

  return unless exists $self->{fields}{$field};
  return $self->{fields}{$field};
}

=head1 AUTHOR

Ricardo SIGNES, C<< <rjbs@cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll automatically be
notified of progress on your bug as I make changes.

=head1 COPYRIGHT

Copyright 2006-2007 Ricardo Signes, all rights reserved.

This program is free software; you may redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
