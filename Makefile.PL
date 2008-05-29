use inc::Module::Install;

all_from      ('lib/App/Addex.pm');

install_script('bin/addex');

requires('Config::INI::Reader'       => 0.005); # lazy-loaded starting sec'n
requires('Config::INI::MVP::Reader'  => 0.016); # first released version
requires('File::HomeDir'             => 0.000); # minimum unknown
requires('File::Spec'                => 0.000); # minimum unknown
requires('Getopt::Long::Descriptive' => 0.060); # for %c in format
requires('Mixin::ExtraFields'        => 0.005); # can get id from refaddr
requires('Mixin::ExtraFields::Param' => 0.000); # minimum unknown
requires('Text::Unidecode'           => 0.000); # minimum unknown

extra_tests;

WriteAll();
