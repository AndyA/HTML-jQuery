package TestTools;

use strict;
use warnings;

use base qw( Exporter );

our @EXPORT = qw( mydata );

=head1 NAME

TestTools - Test support

=head2 C<< mydata >>

Read data (after __DATA__) in the test and return a list of name =>
value pairs corresponding to sections found in the data. Sections start
with '=name <name>'.

=cut

sub mydata {
  my $fh = \*main::DATA;
  my @d  = ();
  while ( <$fh> ) {
    if ( /^=name\s+(\S+)\s*$/ ) {
      push @d, ( $1, '' );
      next;
    }
    $d[-1] .= $_ if @d;
  }
  return @d;
}

1;

# vim:ts=2:sw=2:sts=2:et:ft=perl
