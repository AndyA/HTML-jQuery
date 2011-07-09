package HTML::jQuery::Result;

use strict;
use warnings;

=head1 NAME

HTML::jQuery::Result - Node wrapper

=cut

sub new {
  my ( $cl, $nd ) = @_;
  return bless { node => $nd }, $cl;
}

1;

# vim:ts=2:sw=2:sts=2:et:ft=perl
