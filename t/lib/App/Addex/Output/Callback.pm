#!perl
use strict;
use warnings;

package App::Addex::Output::Callback;

sub new {
  my ($self, $arg) = @_;

  bless $arg->{callback} => $self;
}

sub process_entry { $_[0]->(@_); } 

1;
