#!/usr/bin/perl
use strict;
use warnings;

package App::Addex::Output::Mutt;
use base qw(App::Addex::Output::ToFile);

use Unicode::Normalize qw(normalize);
use Unicode::UCD 'charinfo';

=head1 NAME

App::Addex::Output::Mutt - generate mutt configuration from an address book

=head1 VERSION

version 0.015

=cut

our $VERSION = '0.015';

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

=head1 CONFIGURATION

The valid configuration parameters for this plugin are:

  filename - the filename to which to write the Mutt configuration

=head1 METHODS

App::Addex::Output::Mutt is a App::Addex::Output::ToFile subclass, and inherits its methods.

=head2 process_entry

  $mutt_outputter->process_entry($addex, $entry);

This method does the actual writing of configuration to the file.

=cut

# use utf8; print __degrade_to_ascii($_), "\n" for ('Søren', 'Julián', 'Rik');
sub __degrade_to_ascii {
  return $_[0] if $_[0] =~ /^[\x01-\x79]*$/;
  my $decomp = normalize(D => $_[0]);
  use charnames ':full';
  my $recomp =
    join '', map { chr(hex($_->{code})) }
    # map  { warn $_->{name}, "\n"; $_ }
    map  {
      ($_->{name} =~ /^(LATIN \w+ LETTER .) WITH/)
      ? charinfo(charnames::vianame("$1"))
      : $_
    }
    grep { $_->{code} =~ /[^0]/ }
    grep { $_->{block} !~ /combin/i }
    map  { charinfo(ord substr $decomp, $_, 1) }  0 .. length $decomp;
}

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
    $self->output("save-hook ~f$_ =$folder") for grep { $_->sends } @emails;
    $self->output("mailboxes =$folder")
      unless $self->{_saw_folder}{$folder}++;
  }

  if ($sig) {
    $self->output(qq{send-hook ~t$_ set signature="~/.sig/$sig"})
      for grep { $_->receives } @emails;
  }

  my @aliases = 
    map  { __degrade_to_ascii($_) }
    grep { defined $_ } map { $self->_aliasify($_) } $entry->nick, $name;

  my ($rcpt_email) = grep { $_->receives } @emails;
  $self->output("alias $_ $rcpt_email ($name)") for @aliases;

  # It's not that you're expected to -use- these aliases, but they allow
  # mutt's reverse_alias to do its thing.
  if (@emails > 1) {
    my %label_count;

    if (defined(my $label = $rcpt_email->label)) {
      $self->output("alias $_-$label $rcpt_email ($name)") for @aliases;
      $label_count{$label} = 1;
    }

    my @rcpt_emails = grep { $_->receives } @emails;
    for my $i (1 .. $#rcpt_emails) {
      my $label = $rcpt_emails[$i]->label;
      $label = '' unless defined $label;
      $label_count{$label}++;

      for my $id (@aliases) {
        my $alias = length $label ? "$id-$label" : $id;
        $alias .= "-" . ($label_count{$label} - 1) if $label_count{$label} > 1;

        $self->output("alias $alias $rcpt_emails[$i] ($name)");
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
