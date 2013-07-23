use strict;
use warnings;

package App::Addex::Output::ToFile;
use parent 'App::Addex::Output';
# ABSTRACT: base class for output plugins that write to files

use Carp ();

=head1 DESCRIPTION

This is a base class for output plugins that will write to files.  The
"filename" configuration parameter must be given, and must be the name of a
file to which the user can write.

=method new

  my $addex = App::Addex::Output::Subclass->new(\%arg);

This method returns a new outputter.  It should be subclassed to provide a
C<process_entry> method.

Valid arguments are:

  filename - the file to which to write configuration (required)

=cut

sub new {
  my ($class, $arg) = @_;

  Carp::croak "no filename argument given for $class" unless $arg->{filename};

  my $self = $class->SUPER::new;

  open my $fh, '>', $arg->{filename}
    or Carp::croak "couldn't open output file $arg->{filename}: $!";

  binmode($fh, ':encoding(utf8)');

  $self->{fh} = $fh;

  return $self;
}

=method output

  $outputter->output($string);

This method appends the given string to the output file, adding a newline.

=cut

sub output {
  my ($self, $line) = @_;

  print { $self->{fh} } "$line\n"
    or Carp::croak "couldn't write to output file: $!";
}

sub finalize {
  # We'll just delete this ref and let garbage collection cause closing if
  # needed. -- rjbs, 2007-11-05
  delete $_[0]->{fh};
}

1;
