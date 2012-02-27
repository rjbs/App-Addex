use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
  NAME  => 'App::Addex',
  VERSION_FROM  => 'lib/App/Addex.pm',
  (eval { ExtUtils::MakeMaker->VERSION(6.21) } ? (LICENSE => 'perl') : ()),
  PREREQ_PM => {
    'Config::MVP::Reader::INI'  => 2.000,
    'File::HomeDir'             => 0.000,
    'File::Spec'                => 0.000,
    'Getopt::Long::Descriptive' => 0.060,
    'Mixin::ExtraFields'        => 0.005,
    'Mixin::ExtraFields::Param' => 0.000,
    'Text::Unidecode'           => 0.000, # should replace this!
  },
  EXE_FILES => [ 'bin/addex' ],
  (eval { ExtUtils::MakeMaker->VERSION(6.46) }
    ? (META_MERGE => {
        resources => {
          repository => 'http://github.com/rjbs/app-addex'
        }
      })
    : ()
  ),
);
