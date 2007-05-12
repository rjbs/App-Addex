#!perl
use strict;
use warnings;

package App::Addex::Multivalue;

sub new {
  my ($self, $arg) = @_;

  bless $arg => $self;
}

sub multivalue_args { qw(array list) }

1;
