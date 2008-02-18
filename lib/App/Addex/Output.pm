#!/usr/bin/perl
use strict;
use warnings;

package App::Addex::Output;
use Carp ();

=head1 NAME

App::Addex::Output - base class for output plugins

=head1 VERSION

version 0.014

=cut

our $VERSION = '0.014';

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
