#!perl
use strict;
use warnings;

use Test::More tests => 6;

use lib 't/lib';

use_ok('App::Addex::Config');

my $main_config = q{
; This config file test the most common behaviors plus a few quirks.
foo = 1
bar = 2

[App::Addex::Output::Callback]
license = 3E7E004A-0011-11DC-ADB6-B4CE6F25AB15
permit = allow

[App::Addex::Multivalue]
array = 1
array = 2
array=3
array = 4
};

my $have = App::Addex::Config->read_string($main_config);

isa_ok($have, 'ARRAY', 'we got a hashref back from read_string');

my $want = [
  {
    '=name' => '_',
    foo => 1,
    bar => 2,
  },
  {
    '=name'    => 'App::Addex::Output::Callback',
    '=package' => 'App::Addex::Output::Callback',
    license => '3E7E004A-0011-11DC-ADB6-B4CE6F25AB15',
    permit  => 'allow',
  },
  {
    '=name'    => 'App::Addex::Multivalue',
    '=package' => 'App::Addex::Multivalue',
    array => [ qw(1 2 3 4) ],
  },
];

is_deeply($have, $want, "and it's got the values we expect to see");

eval { App::Addex::Config->read_string("[App::Addex::Multivalue]\na=1\na=2"); };

like(
  $@,
  qr/multiple values given/,
  "exception thrown when multiple values for non-multivalue property",
);

eval { App::Addex::Config->read_string("[; warn 'THIS IS REALLY BAD']\n"); };

like(
  $@,
  qr/couldn't understand/,
  "section names must look like class names",
);

eval { App::Addex::Config->read_string("[App::Addex::FailsToLoad]\n"); };

like(
  $@,
  qr/couldn't load plugin/,
  "exception thrown when section header can't be loaded as plugin",
);
