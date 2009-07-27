#!/usr/bin/perl
use strict;
use warnings;

package App::Addex::Config;
use base qw(Config::INI::MVP::Reader);

=head1 NAME

App::Addex::Config - read the addex config file

=head1 VERSION

version 0.021

=cut

our $VERSION = '0.021';

=head1 DESCRIPTION

=cut

sub starting_section_name { 'classes' }
sub starting_section_multivalue_args  { [ qw(output plugin) ] }

=head1 AUTHOR

Ricardo SIGNES, C<< <rjbs@cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll automatically be
notified of progress on your bug as I make changes.

=head1 COPYRIGHT

Copyright 2007 Ricardo Signes, all rights reserved.

This program is free software; you may redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
