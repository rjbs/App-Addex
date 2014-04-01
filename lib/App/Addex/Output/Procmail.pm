use strict;
use warnings;

package App::Addex::Output::Procmail;
# ABSTRACT: generate procmail recipes from an address book

use parent qw(App::Addex::Output::ToFile);

=head1 DESCRIPTION

This plugin produces a file that contains a list of procmail recipes.  For
any entry with a "folder" field, recipes are produced to deliver all mail from
its addresses to the given folder.

Forward slashes in the folder name are converted to dots, showing my bias
toward Courier IMAP.

=head1 CONFIGURATION

The valid configuration parameters for this plugin are:

  filename - the filename to which to write the procmail recipes

=method process_entry

  $procmail_outputter->process_entry($addex, $entry);

This method does the actual writing of configuration to the file.

=cut

sub process_entry {
  my ($self, $addex, $entry) = @_;

  return unless my $folder = $entry->field('folder');

  $folder =~ tr{/}{.};

  my @emails = $entry->emails;

  for my $email (@emails) {
    next unless $email->sends;
    $self->output(":0");
    $self->output("* From:.*$email");
    $self->output(".$folder/");
    $self->output(q{});
  }

}

1;
