#!/usr/bin/perl
use strict;
use warnings;

package App::Addex::Output::SpamAssassin;
use base qw(App::Addex::Output::ToFile);

=head1 NAME

App::Addex::Output::SpamAssassin - generate SpamAssassin whitelists from an address book

=head1 VERSION

version 0.017

=cut

our $VERSION = '0.017';

=head1 DESCRIPTION

This plugin produces a file that contains a list of SpamAssassin whitelist
declarations.

=head1 CONFIGURATION

The valid configuration parameters for this plugin are:

  filename - the filename to which to write the whitelists

=head1 METHODS

App::Addex::Output::SpamAssassin is a App::Addex::Output::ToFile subclass, and
inherits its methods.

=cut

=head2 process_entry

  $sa_outputter->process_entry($addex, $entry);

This method does the actual writing of configuration to the file.

=cut

sub process_entry {
  my ($self, $addex, $entry) = @_;

  $self->output("whitelist_from $_") for grep { $_->sends } $entry->emails;
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
