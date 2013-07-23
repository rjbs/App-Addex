use strict;
use warnings;

package App::Addex::Output::SpamAssassin;
use parent qw(App::Addex::Output::ToFile);
# ABSTRACT: generate SpamAssassin whitelists from an address book

=head1 DESCRIPTION

This plugin produces a file that contains a list of SpamAssassin whitelist
declarations.

=head1 CONFIGURATION

The valid configuration parameters for this plugin are:

  filename - the filename to which to write the whitelists

=method process_entry

  $sa_outputter->process_entry($addex, $entry);

This method does the actual writing of configuration to the file.

=cut

sub process_entry {
  my ($self, $addex, $entry) = @_;

  $self->output("whitelist_from $_") for grep { $_->sends } $entry->emails;
}

1;
