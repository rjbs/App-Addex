#!/usr/bin/perl
use strict;
use warnings;

package App::Addex::Output::Mutt;

use Carp ();

=head1 NAME

App::Addex::Output::Mutt - generate mutt configuration from an address book

=head1 VERSION

version 0.002

  $Id: /my/cs/projects/App-Addex/trunk/lib/App/Addex.pm 31327 2007-04-06T23:00:12.564293Z rjbs  $

=cut

our $VERSION = '0.002';

=head1 METHODS

B<Achtung!>  The API to this code may very well change.  It is almost certain
to be broken into smaller pieces, to support alternate sources of entries, and
it might just get plugins.

=head2 new

  my $addex = App::Addex::Output::Mutt->new(\%arg);

This method returns a new Addex mutt outputter.

=cut

sub new {
  my ($class, $arg) = @_;

  my $self = bless {} => $class;
}

=head3 mutt configuration

If requested, the F<muttrc> file will contain a list of alias lines.  The first
email address for each entry will be aliased to the entry's aliasified
nickname and name.  Every other address will be aliased to one of those with an
appended, incrementing counter.  The entry's name is added as the alias's
"real name."

If the entry has a "folder" value (given as a line in the card's "notes" that
looks like "folder: value") a save-hook is created to save mail from the entry
to that folder and a mailboxes line is created for the folder.  If the entry
has a "sig" value, a send-hook is created to use that signature when composing
a message to the entry.

=cut

sub run {
  my ($self) = @_;

  for my $entry ($self->addressbook->entries) {
    my $name   = $self->asciify($entry->name);
    my @emails = $entry->emails;

    my $folder = $entry->field('folder');
    my $sig    = $entry->field('sig');

    if ($self->_whitelists_fh) {
      $self->whitelists_line("whitelist_from $_") for @emails;
    }

    if ($folder) {
      $folder =~ tr{/}{.};
      $self->muttrc_line("save-hook ~f$_ =$folder") for @emails;
      $self->muttrc_line("mailboxes =$folder")
        unless $self->{_saw_folder}{$folder}++;

      if ($self->_procmailrc_fh) {
        for my $email (@emails) {
          $self->procmailrc_line(":0");
          $self->procmailrc_line("* From:.*$email");
          $self->procmailrc_line(".$folder/");
          $self->procmailrc_line(q{});
        }
      }
    }

    if ($sig) {
      $self->muttrc_line(qq{send-hook ~t$_ set signature="~/.sig/$sig"})
        for @emails;
    }

    my @aliases
      = grep { defined $_ } map { $self->aliasify($_) } $entry->nick, $name;

    $self->muttrc_line("alias $_ $emails[0] ($name)") for @aliases;

    # It's not that you're expected to -use- these aliases, but they allow
    # mutt's reverse_alias to do its thing.
    if (@emails > 1) {
      for my $i (1 .. $#emails) {
        $self->muttrc_line("alias $aliases[0]-$i $emails[$i] ($name)");
      }
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
