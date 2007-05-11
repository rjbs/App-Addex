#!/usr/bin/perl
use strict;
use warnings;

package App::Addex::Output::Mutt;

use Carp ();

=head1 NAME

App::Addex::Output::Mutt - generate mutt configuration from an address book

=head1 VERSION

version 0.007

  $Id$

=cut

our $VERSION = '0.007';

=head1 DESCRIPTION

This plugin produces a file that contains a list of alias lines.  The first
email address for each entry will be aliased to the entry's aliasified nickname
and name.  Every other address will be aliased to one of those with an
appended, incrementing counter.  The entry's name is added as the alias's "real
name."

If the entry has a "folder" value (given as a line in the card's "notes" that
looks like "folder: value") a save-hook is created to save mail from the entry
to that folder and a mailboxes line is created for the folder.  If the entry
has a "sig" value, a send-hook is created to use that signature when composing
a message to the entry.

=head1 METHODS

=head2 new

  my $addex = App::Addex::Output::Mutt->new(\%arg);

This method returns a new Addex mutt outputter.

Valid arguments are:

  filename - the file to which to write mutt configuration

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

sub _output {
  my ($self, $line) = @_;

  print { $self->{fh} } "$line\n"
    or Carp::croak "couldn't write to output file: $!";
}

=head2 process_entry

  $mutt_outputter->process_entry($addex, $entry);

This method does the actual writing of configuration to the file.

=cut

sub _aliasify {
  my (undef, $text) = @_;

  return unless defined $text;
  $text =~ tr/ .'//d;
  return lc $text;
}

sub process_entry {
  my ($self, $addex, $entry) = @_;

  my $name   = $entry->name;
  my @emails = $entry->emails;

  my $folder = $entry->field('folder');
  my $sig    = $entry->field('sig');

  if ($folder) {
    $folder =~ tr{/}{.};
    $self->_output("save-hook ~f$_ =$folder") for @emails;
    $self->_output("mailboxes =$folder")
      unless $self->{_saw_folder}{$folder}++;
  }

  if ($sig) {
    $self->_output(qq{send-hook ~t$_ set signature="~/.sig/$sig"})
      for @emails;
  }

  my @aliases
    = grep { defined $_ } map { $self->_aliasify($_) } $entry->nick, $name;

  $self->_output("alias $_ $emails[0] ($name)") for @aliases;

  # It's not that you're expected to -use- these aliases, but they allow
  # mutt's reverse_alias to do its thing.
  if (@emails > 1) {
    my %label_count;

    if (defined(my $label = $emails[0]->label)) {
      $self->_output("alias $_-$label $emails[0] ($name)") for @aliases;
      $label_count{$label} = 1;
    }

    for my $i (1 .. $#emails) {
      my $label = $emails[$i]->label;
      $label_count{$label}++;
      my $alias = defined $label ? "$aliases[0]-$label" : $aliases[0];
      $alias .= "-" . $label_count{$label} - 1 if $label_count{$label} > 1;

      $self->_output("alias $alias $emails[$i] ($name)");
    }
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
