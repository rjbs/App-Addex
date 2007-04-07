#!/usr/bin/perl
use strict;
use warnings;

package App::Addex::Output::Procmail;

use Carp ();

=head1 NAME

App::Addex::Output::Procmail - generate procmail recipes from an address book

=head1 VERSION

version 0.002

  $Id: /my/cs/projects/App-Addex/trunk/lib/App/Addex.pm 31327 2007-04-06T23:00:12.564293Z rjbs  $

=cut

our $VERSION = '0.002';

=head1 DESCRIPTION

This plugin produces a file that contains a list of procmail recipes.  For
any entry with a "folder" field, recipes are produced to deliver all mail from
its addresses to the given folder.

=head1 METHODS

=head2 new

  my $addex = App::Addex::Output::Procmail->new(\%arg);

This method returns a new Addex procmail outputter.

Valid arguments are:

  filename - the file to which to write procmail recipes

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

  $mutt_outputter->process_entry($addex, $entry);

This method does the actual writing of configuration to the file.

=cut

sub process_entry {
  my ($self, $addex, $entry) = @_;

  return unless my $folder = $entry->field('folder');

  my @emails = $entry->emails;

  for my $email (@emails) {
    $self->_output(":0");
    $self->_output("* From:.*$email");
    $self->_output(".$folder/");
    $self->_output(q{});
  }

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
