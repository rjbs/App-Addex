#!perl
use strict;
use warnings;

use lib 't/lib';

use Test::More tests => 3;

my $class = 'App::Addex::Output::ToFile';
use_ok($class);

eval { $class->new; };
like($@, qr/no filename/, 'filename is a required arg');

# Is this test portable? -- rjbs, 2007-05-11
eval { $class->new({ filename => '/' }); };
like($@, qr/couldn't open/, 'filename is a required arg');

