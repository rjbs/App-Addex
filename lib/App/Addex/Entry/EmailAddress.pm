#!/usr/bin/perl
use strict;
use warnings;

package App::Addex::Entry::EmailAddress;

=head1 NAME

App::Addex::Entry::EmailAddress - an address book entry's email address

=head1 VERSION

version 0.015

=cut

our $VERSION = '0.015';

=head1 SYNOPSIS

An App::Addex::Entry::EmailAddress object represents, well, an addess for an
entry.

=head1 METHODS

=head2 new

  my $address = App::Addex::Entry::EmailAddress->new("dude@example.aero");

  my $address = App::Addex::Entry::EmailAddress->new(\%arg);

Valid arguments are:

  address - the contact's email address
  label   - the label for this contact (home, work, etc)
            there is no guarantee that labels are defined or unique

  sends    - if true, this address may send mail; default: true
  receives - if true, this address may receive mail; default: true

=cut

sub new {
  my ($class, $arg) = @_;

  $arg = { address => $arg } if not ref $arg;
  undef $arg->{label} if defined $arg->{label} and not length $arg->{label};

  for (qw(sends receives)) {
    $arg->{$_} = 1 unless exists $arg->{$_};
  }

  bless $arg => $class;
}

=head2 address

This method returns the email address as a string.

=cut

use overload '""' => 'address';

sub address {
  $_[0]->{address}
}

=head2 label

This method returns the address label, if any.

=cut

sub label {
  $_[0]->{label}
}

=head2 sends

=head2 receives

=cut

sub sends    { $_[0]->{sends} }
sub receives { $_[0]->{receives} }

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
