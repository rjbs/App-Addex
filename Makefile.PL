use strict;
use warnings;

use inc::Module::Install;

name          ('App-Addex');
author        ('Ricardo Signes <rjbs@cpan.org>');
license       ('perl');
version_from  ('lib/App/Addex/Apple.pm');

install_script('bin/addex');

requires('Test::More'       => 0.00);
requires('Scalar::Util'     => 0.00);

WriteAll();
