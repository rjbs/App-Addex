use strict;
use warnings;
package App::Addex::Entry::EmailAddress;
# ABSTRACT: an address book entry's email address

=head1 SYNOPSIS

An App::Addex::Entry::EmailAddress object represents, well, an addess for an
entry.

=method new

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

=method address

This method returns the email address as a string.

=cut

use overload '""' => 'address';

sub address {
  $_[0]->{address}
}

=method label

This method returns the address label, if any.

=cut

sub label {
  $_[0]->{label}
}

=method sends

=method receives

=cut

sub sends    { $_[0]->{sends} }
sub receives { $_[0]->{receives} }

1;
