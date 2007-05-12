#!perl
use strict;
use warnings;

use lib 't/lib';

use Test::More tests => 3;

use_ok('App::Addex');

my @calls;

my $callback = sub {
  my ($self, $addex, $entry) = @_;
  push @calls, ($entry->emails)[0]->address;
};

my $addex = App::Addex->new({
  classes => {
    addressbook => 'App::Addex::AddressBook::Test',
    output      => [ 'App::Addex::Output::Callback' ],
  },
  'App::Addex::Output::Callback' => {
    callback => $callback,
  },
});

isa_ok($addex, 'App::Addex');

$addex->run;

is(@calls, 6, "callback called twice");

