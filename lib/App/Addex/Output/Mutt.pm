use strict;
use warnings;

package App::Addex::Output::Mutt;
use base qw(App::Addex::Output::ToFile);

use Text::Unidecode ();

=head1 NAME

App::Addex::Output::Mutt - generate mutt configuration from an address book

=head1 VERSION

version 0.023

=cut

our $VERSION = '0.023';

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

  filename  - the filename to which to write the Mutt configuration

  unidecode - if set (to 1) this will transliterate all aliases to ascii before
              adding them to the file

=head1 METHODS

App::Addex::Output::Mutt is a App::Addex::Output::ToFile subclass, and inherits its methods.

=cut

sub new {
  my ($class, $arg) = @_;
  $arg ||= {};

  my $self = $class->SUPER::new($arg);

  $self->{unidecode} = $arg->{unidecode};

  return $self;
}

=head2 process_entry

  $mutt_outputter->process_entry($addex, $entry);

This method does the actual writing of configuration to the file.

=cut

sub _aliasify {
  my ($self, $text) = @_;

  return unless defined $text;
  $text =~ tr/ .'//d;
  Text::Unidecode::unidecode($text) if $self->{unidecode};
  return lc $text;
}

sub _ig {
  return($_[0] =~ /;$/ and $_[0] =~ /:/);
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
    map { $self->_aliasify($_) } grep { defined } $entry->nick, $name;

  my @name_strs = (qq{ ($name)}, q{});

  my ($rcpt_email) = grep { $_->receives } @emails;
  $self->output("alias $_ $rcpt_email$name_strs[_ig($rcpt_email)]")
    for @aliases;

  # It's not that you're expected to -use- these aliases, but they allow
  # mutt's reverse_alias to do its thing.
  if (@emails > 1) {
    my %label_count;

    if (defined(my $label = $rcpt_email->label)) {
      $self->output("alias $_-$label $rcpt_email$name_strs[_ig($rcpt_email)]")
        for @aliases;

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

        $self->output("alias $alias $rcpt_emails[$i]$name_strs[_ig($rcpt_emails[$i])]");
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
