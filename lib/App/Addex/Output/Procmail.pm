#!/usr/bin/perl
use strict;
use warnings;

package App::Addex::Output::Procmail;
use base qw(App::Addex::Output::ToFile);

=head1 NAME

App::Addex::Output::Procmail - generate procmail recipes from an address book

=head1 VERSION

version 0.011

=cut

our $VERSION = '0.011';

=head1 DESCRIPTION

This plugin produces a file that contains a list of procmail recipes.  For
any entry with a "folder" field, recipes are produced to deliver all mail from
its addresses to the given folder.

Forward slashes in the folder name are converted to dots, showing my bias
toward Courier IMAP.

=head1 CONFIGURATION

The valid configuration parameters for this plugin are:

  filename - the filename to which to write the procmail recipes

=head1 METHODS

App::Addex::Output::Procmail is a App::Addex::Output::ToFile subclass, and
inherits its methods.

=head2 process_entry

  $procmail_outputter->process_entry($addex, $entry);

This method does the actual writing of configuration to the file.

=cut

sub process_entry {
  my ($self, $addex, $entry) = @_;

  return unless my $folder = $entry->field('folder');

  $folder =~ tr{/}{.};

  my @emails = $entry->emails;

  for my $email (@emails) {
    $self->output(":0");
    $self->output("* From:.*$email");
    $self->output(".$folder/");
    $self->output(q{});
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
