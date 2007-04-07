#!/usr/bin/perl
use strict;
use warnings;

package App::Addex;

use Carp ();
use Sub::Install ();

=head1 NAME

App::Addex - generate mail tool configuration from an address book

=head1 VERSION

version 0.002

  $Id$

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

  # XXX: keep track of seen/unseen classes; carp if some go unused?
  # -- rjbs, 2007-04-06

  for my $core (qw(addressbook)) {
    my $class = $arg->{classes}{$core}
      or Carp::confess "no $core class provided";

    $self->{$core} = $self->_learn_plugin($class, $arg->{$class});
  }

  my @output_classes = @{ $arg->{classes}{output} || [] };
  # XXX: move the above "plugins" into here, including the confess
  my @output_plugins;
  for my $class (@output_classes) {
    push @output_plugins, $self->_learn_plugin($class, $arg->{$class});
  }
  $self->{output} = \@output_plugins;

  return bless $self => $class;
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

=head2 output_plugins

This method returns all the output plugin objects.

=cut

sub output_plugins {
  my ($self) = @_;
  return @{ $self->{output} };
}

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

=cut

sub run {
  my ($self) = @_;

  for my $entry ($self->addressbook->entries) {
    for my $plugin ($self->output_plugins) {
      $plugin->process_entry($self, $entry);
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
