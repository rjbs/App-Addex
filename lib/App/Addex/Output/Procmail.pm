#!/usr/bin/perl
use strict;
use warnings;

package App::Addex::Output::Procmail;

use Carp ();
use Sub::Install ();

=head1 NAME

App::Addex - generate mail tool configuration from an address book

=head1 VERSION

version 0.002

  $Id: /my/cs/projects/App-Addex/trunk/lib/App/Addex.pm 31327 2007-04-06T23:00:12.564293Z rjbs  $

=cut

our $VERSION = '0.002';

=head1 SYNOPSIS

This module iterates through all the entries in an address book and produces
configuration files for F<mutt>, F<procmail>, and F<spamassassin> based on that
data.

It is meant to be run with the F<aaabook> command, which is bundled as part of
this software distribution.

=head1 METHODS

B<Achtung!>  The API to this code may very well change.  It is almost certain
to be broken into smaller pieces, to support alternate sources of entries, and
it might just get plugins.

=head2 new

  my $addex = App::Addex->new(\%arg);

This method returns a new Addex.

Valid paramters are:

  classes    - a hashref of plugin/class pairs, described below

  muttrc     - the file name to which to output mutt configuration
  procmailrc - the file name to which to output procmail configuration
  whitelists - the file name to which to output spamassassin whitelists

Valid keys for the F<classes> parameter are:

  addressbook - the App::Addex::AddressBook subclass to use
  output      - an array of output producers

At least one of these three parameters must be given or an exception will be
thrown.

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

=head3 procmail configuration

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
