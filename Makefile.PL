use strict;
use warnings;

use inc::Module::Install;

name          ('App-Addex');
author        ('Ricardo Signes <rjbs@cpan.org>');
license       ('perl');
version_from  ('lib/App/Addex/Apple.pm');

install_script('bin/addex');

requires('Mac::Glue'        => 0.00); # no idea what the minimum version is
requires('Sub::Install'     => 0.91); # for Params::Util use
requires('Getopt::Long::Descriptive' => 0.06); # for %c in format

WriteAll();
