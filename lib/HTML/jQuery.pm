package HTML::jQuery;

use strict;
use warnings;

use base qw( Exporter );

our @EXPORT = qw( jq );

use Carp;
use Data::Dumper;
use HTML::DOM::Node qw( :all );
use HTML::DOM;
use HTML::jQuery::Result;
use Scalar::Util qw( blessed );

=head1 NAME

HTML::jQuery - jQuery-like CSS selector based access to an HTML DOM

=head1 VERSION

This document describes HTML::jQuery version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

  use HTML::jQuery;
  
=head1 DESCRIPTION

=head1 INTERFACE 

=head2 C<< new >>

=cut

sub new {
  my ( $cl, $nd ) = @_;
  return bless { node => $nd }, $cl;
}

=head2 C<< jq >>

Performa a jQuery style query on a dom node.

=cut

sub _visitor_recursive {
  my ( $self, $nd, $match ) = @_;

  return unless $nd->nodeType == ELEMENT_NODE;

  my @got = $match->( $nd );

  my $chd = $nd->firstChild;
  while ( $chd ) {
    push @got, $self->_visitor_recursive( $chd, $match );
    $chd = $chd->nextSibling;
  }

  return @got;
}

sub _wrap {
  my ( $self, @nodes ) = @_;
  return [ map { HTML::jQuery::Result->new( $_ ) } @nodes ];
}

sub jq {
  my ( $self, $sel ) = @_;
  $self = HTML::jQuery->new( $self )
   unless blessed $self && $self->isa( 'HTML::jQuery' );
  my $match = sub {
    my $nd = shift;
    return ( $nd ) if $nd->tagName eq 'A';
    return;
  };

  return $self->_wrap(
    $self->_visitor_recursive( $self->{node}->firstChild, $match ) );
}

1;
__END__

=head1 DEPENDENCIES

None.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-html-jquery@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

=head1 AUTHOR

Andy Armstrong  C<< <andy@hexten.net> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2009, Andy Armstrong C<< <andy@hexten.net> >>.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.
