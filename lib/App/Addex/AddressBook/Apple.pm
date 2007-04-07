#!/usr/bin/perl
use strict;
use warnings;

package App::Addex::AddressBook::Apple;
use base qw(App::Addex::AddressBook);

use Mac::Glue qw(:glue);

=head1 NAME

App::Addex::Apple - create mail helper files from Apple Address Book

=head1 VERSION

version 0.002

  $Id$

=cut

our $VERSION = '0.002';

=head1 SYNOPSIS

This module iterates through all the entries in an Apple Address Book and
produces configuration files for F<mutt>, F<procmail>, and F<spamassassin>
based on that data.

It is meant to be run with the F<aaabook> command, which is bundled as part of
this software distribution.

=head1 METHODS

B<Achtung!>  The API to this code may very well change.  It is almost certain
to be broken into smaller pieces, to support alternate sources of people, and
it might just get plugins.

=cut

=head2 _glue

  my $glue = $abook->_glue;

This method returns the Mac::Glue "glue" for the Apple Address book.

=cut

sub _glue {
  return $_[0]->{_abook_glue} ||= Mac::Glue->new("Address_Book");
}

sub _demsng {
  return if ! $_[1] or $_[1] eq 'msng';
  return $_[1];
}

sub _entrify {
  my ($self, $person) = @_;

  return unless my @emails = map { $self->_demsng($_->prop('value')->get) }
                             $person->prop("email")->get;

  my %fields;
  if (my $note = scalar $self->_demsng($person->prop('note')->get)) {
    ($fields{folder}) = $note =~ /^folder:\s*(\S+)$/sm;
    ($fields{sig})    = $note =~ /^sig:\s*(\S+)$/sm;
  }

  return App::Addex::Entry->new({
    name   => scalar $self->_demsng($person->prop('name')->get),
    nick   => scalar $self->_demsng($person->prop('nickname')->get),
    emails => \@emails,
    fields => \%fields,
  });
}

=head2 entries

  my @entries = $addex->entires;

This method returns the entries in the Address Book as Addex Entry objects.

=cut

sub entries {
  my ($self) = @_;

  my @entries = map { $self->_entrify($_) } $self->_glue->prop("people")->get;
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
