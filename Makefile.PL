use strict;
use warnings;

use inc::Module::Install;

name          ('App-Addex');
author        ('Ricardo Signes <rjbs@cpan.org>');
license       ('perl');
version_from  ('lib/App/Addex.pm');

install_script('bin/addex');

requires('Config::INI::Reader'       => 0.003); # the first released version
requires('File::HomeDir'             => 0.000); # minimum unknown
requires('File::Spec'                => 0.000); # minimum unknown
requires('Getopt::Long::Descriptive' => 0.060); # for %c in format
requires('Mac::Glue'                 => 0.000); # minimum unknown

WriteAll();
