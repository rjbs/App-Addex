#!/usr/bin/perl
use strict;
use warnings;

package App::Addex::Output::ToFile;
use Carp ();

=head1 NAME

App::Addex::Output::ToFile - base class for output plugins that write to files

=head1 VERSION

version 0.009

=cut

our $VERSION = '0.009';

=head1 DESCRIPTION

This is a base class for output plugins that will write to files.  The
"filename" configuration parameter must be given, and must be the name of a
file to which the user can write.

=head1 METHODS

=head2 new

  my $addex = App::Addex::Output::Subclass->new(\%arg);

This method returns a new outputter.  It should be subclassed to provide a
C<process_entry> method.

Valid arguments are:

  filename - the file to which to write configuration (required)

=cut

sub new {
  my ($class, $arg) = @_;

  Carp::croak "no filename argument given for $class" unless $arg->{filename};

  my $self = bless {} => $class;

  open my $fh, '>', $arg->{filename}
    or Carp::croak "couldn't open output file $arg->{filename}: $!";

  $self->{fh} = $fh;

  return $self;
}

=head2 output

  $outputter->output($string);

This method appends the given string to the output file, adding a newline.

=cut

sub output {
  my ($self, $line) = @_;

  print { $self->{fh} } "$line\n"
    or Carp::croak "couldn't write to output file: $!";
}

=head1 AUTHOR

Ricardo SIGNES, C<< <rjbs@cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll automatically be
notified of progress on your bug as I make changes.

=head1 COPYRIGHT

Copyright 2006-2007 Ricardo Signes, all rights reserved.

This program is free software; you may redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
