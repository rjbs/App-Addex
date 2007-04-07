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
}

sub _learn_plugin {
  my ($self, $class, $arg) = @_;

  eval "require $class" or die;
  return $class->new($arg ? $arg : ());
}

=head2 addressbook

  my $abook = $addex->addressbook;

This method returns the App::Addex::AddressBook object.

=cut

sub addressbook { $_[0]->{addressbook} }

=head2 muttrc

=head2 procmailrc

=head2 whitelists

These methods return the names of the files to which configuration will be
written, if any.

=head2 muttrc_line

=head2 procmailrc_line

=head2 whitelists_line

  $abook->muttrc_line($line);

These methods text to the correct configuration file, appending a trailing
newline.

=head2 asciify

  my $ascii_string = $abook->asciify($string);

This method converts a string to seven bit ASCII text, in theory.  In reality
it is terrible and needs to be fixed or eliminated.

=head2 aliasify

  my $alias = $abook->aliasify($string);

Given a string containing a name or nickname, this routine returns a new,
derived string that can be used (in F<mutt>) as a one-word alias for the name.

=cut

BEGIN {
  for my $file (qw(muttrc procmailrc whitelists)) {
    my $fh_method = "_$file\_fh";

    my $fh_sub = sub {
      my ($self) = @_;

      return unless $self->{$file};
      return $self->{$fh_method} if $self->{$fh_method};

      open my $fh, '>', $self->{$file}
        or die "couldn't open $file for writing: $!";

      return $self->{$fh_method} = $fh;
    };

    Sub::Install::install_sub({
      code => $fh_sub,
      as   => $fh_method,
    });

    my $print_sub = sub {
      my ($self, $line) = @_;
      return unless $self->{$file};
      print {$self->$fh_method} "$line\n"
        or die "couldn't write line to $file: $!";
    };

    Sub::Install::install_sub({
      code => $print_sub,
      as   => "$file\_line",
    });
  }

  sub _munger {
    my ($code) = @_;
    sub {
      my (undef, $str) = @_;
      return unless defined $str;
      $str = $code->($str);
      return $str;
    };
  }

  Sub::Install::install_sub({
    code => _munger(sub { $_[0] =~ tr/\216\277/e0/; $_[0] }),
    as   => 'asciify',
  });

  Sub::Install::install_sub({
    code => _munger(sub { $_[0] =~ tr/ .'//d; lc $_[0] }),
    as   => 'aliasify',
  });
}

=head2 run

  App::Addex->new({ ... })->run;

This method performs all the work expected of an Addex: it iterates through the
entries, writing the relevant information to the relevant files.

Generally, this consists of:

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

=head3 procmail configuration

If requested, the F<procmailrc> file will contain a list of simple recipies,
filtering mail from any one of a entry's addresses to his "folder" value (see
above).  People without "folder" settings do not appear in the created
F<procmail> configuration.

=head3 whitelists

If requested, the F<whitelists> file will contain a list of C<whitelist_from>
lines, whitelisting each email address seen in the address book.

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
