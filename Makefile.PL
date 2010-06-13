use inc::Module::Install;

all_from      ('lib/App/Addex.pm');

install_script('bin/addex');

requires('Config::MVP::Reader::INI'  => 2.000); # current series
requires('File::HomeDir'             => 0.000); # minimum unknown
requires('File::Spec'                => 0.000); # minimum unknown
requires('Getopt::Long::Descriptive' => 0.060); # for %c in format
requires('Mixin::ExtraFields'        => 0.005); # can get id from refaddr
requires('Mixin::ExtraFields::Param' => 0.000); # minimum unknown
requires('Text::Unidecode'           => 0.000); # minimum unknown

repository('http://github.com/rjbs/app-addex');

auto_manifest;

WriteAll();
