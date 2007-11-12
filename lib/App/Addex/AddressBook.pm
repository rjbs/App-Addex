#!/usr/bin/perl
use strict;
use warnings;

package App::Addex::AddressBook;

use App::Addex::Entry;

use Carp ();

=head1 NAME

App::Addex::AddressBook - the address book that addex will consult

=head1 VERSION

version 0.012

=cut

our $VERSION = '0.012';

=head1 METHODS

=head2 new

  my $addex = App::Addex::AddressBook->new(\%arg);

This method returns a new AddressBook.  Its implementation details are left up
to the subclasses, but it must accept a hashref as its first argument.

=cut

sub new {
  bless {} => $_[0];
}

=head2 entries

  my @entries = $addex->entries;

This method returns the entries in the address book as L<App::Addex::Entry>
objects.  Its behavior in scalar context is not yet defined.

This method should be implemented by a address-book-implementation-specific
subclass.

=cut

sub entries {
  Carp::confess "no behavior defined for virtual method entries";
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
