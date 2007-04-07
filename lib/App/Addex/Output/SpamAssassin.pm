#!/usr/bin/perl
use strict;
use warnings;

package App::Addex::Output::SpamAssassin;

use Carp ();

=head1 NAME

App::Addex::Output::SpamAssassin - generate SpamAssassin whitelists from an address book

=head1 VERSION

version 0.002

  $Id$

=cut

our $VERSION = '0.002';

=head1 DESCRIPTION

This plugin produces a file that contains a list of SpamAssassin whitelist
declarations.

=head1 METHODS

=head2 new

  my $addex = App::Addex::Output::SpamAssassin->new(\%arg);

This method returns a new Addex SpamAssassin outputter.

Valid arguments are:

  filename - the file to which to write spamassassin configuration

=cut

sub new {
  my ($class, $arg) = @_;

  my $self = bless {} => $class;

  open my $fh, '>', $arg->{filename}
    or Carp::croak "couldn't open output file $arg->{filename}: $!";

  $self->{fh} = $fh;

  return $self;
}

sub _output {
  my ($self, $line) = @_;
  print { $self->{fh} } "$line\n"
    or Carp::croak "couldn't write to output file: $!";
}

=head2 process_entry

This method does the actual writing of configuration to the file.

=cut

sub process_entry {
  my ($self, $addex, $entry) = @_;

  $self->_output("whitelist_from $_") for $entry->emails;
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
