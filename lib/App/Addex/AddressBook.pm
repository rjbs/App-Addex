use strict;
use warnings;
package App::Addex::AddressBook;
# ABSTRACT: the address book that addex will consult

use App::Addex::Entry;

use Carp ();

=method new

  my $addr_book = App::Addex::AddressBook->new(\%arg);

This method returns a new AddressBook.  Its implementation details are left up
to the subclasses, but it must accept a hashref as its first argument.

Valid arguments are:

  addex - required; the App::Addex object using this address book

=cut

sub new {
  my ($class, $arg) = @_;
  Carp::croak "no addex argument provided" unless $arg->{addex};
  bless { addex => $arg->{addex} } => $class;
}

=method addex

  my $addex = $addr_book->addex;

This returns the App::Addex object with which the address book is associated.

=cut

sub addex { $_[0]->{addex} }

=method entries

  my @entries = $addex->entries;

This method returns the entries in the address book as L<App::Addex::Entry>
objects.  Its behavior in scalar context is not yet defined.

This method should be implemented by a address-book-implementation-specific
subclass.

=cut

sub entries {
  Carp::confess "no behavior defined for virtual method entries";
}

1;
