use strict;
use warnings;

package App::Addex::Output;
# ABSTRACT: base class for output plugins

use Carp ();

=head1 DESCRIPTION

This is a base class for output plugins.

=head1 METHODS

=head2 new

  my $output_plugin = App::Addex::Output->new(\%arg);

This method returns a new outputter.

=cut

sub new {
  my ($class) = @_;

  return bless {} => $class;
}

=head2 process_entry

  $output_plugin->process_entry($entry);

This method is called once for each entry to be processed.  It must be
overridden in output plugin classes, or the base implementation will throw an
exception when called.

=cut

sub process_entry { Carp::confess "process_entry method not implemented" }

=head2 finalize

  $output_plugin->finalize;

This method is called after all entries have been processed.

=cut

sub finalize { }

1;
