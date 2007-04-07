use strict;
use warnings;

use inc::Module::Install;

name          ('App-Addex');
author        ('Ricardo Signes <rjbs@cpan.org>');
license       ('perl');
version_from  ('lib/App/Addex.pm');

install_script('bin/addex');

requires('Config::Tiny'              => 0.00); # minimum unknown
requires('File::HomeDir'             => 0.00); # minimum unknown
requires('File::Spec'                => 0.00); # minimum unknown
requires('Getopt::Long::Descriptive' => 0.06); # for %c in format
requires('Mac::Glue'                 => 0.00); # minimum unknown
requires('Sub::Install'              => 0.91); # for Params::Util use

WriteAll();
