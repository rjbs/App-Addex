use strict;
use warnings;
package App::Addex::Entry;
# ABSTRACT: an entry in your address book

use Mixin::ExtraFields::Param -fields => {
  driver  => 'HashGuts',
  moniker => 'field',
  id      => undef,
};

use Carp ();

=method new

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
  };

  bless $self => $class;

  $self->field(%{ $arg->{fields} }) if $arg->{fields};

  return $self;
}

=method name

=method nick

These methods return the value of the property they name.

=cut

sub name { $_[0]->{name} }
sub nick { $_[0]->{nick} }

=method emails

This method returns the entry's email addresses.  In scalar context it returns
the number of addresses.

=cut

sub emails { @{ $_[0]->{emails} } }

=method field

  my $value = $entry->field($name);

  $entry->field($name => $value);

This method is generated by L<Mixin::ExtraFields::Param|Mixin::ExtraFields::Param>.

=cut

1;
