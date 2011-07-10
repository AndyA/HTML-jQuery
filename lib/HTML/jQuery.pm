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
   unless blessed $self && $self->isa( __PACKAGE__ );
  my $match = sub {
    my $nd = shift;
    return ( $nd ) if $nd->tagName eq 'A';
    return;
  };

  return $self->_wrap(
    $self->_visitor_recursive( $self->{node}->firstChild, $match ) );
}

my $NAME = qr{[-\w]*};

sub css_attr {
  my $attr = shift;
  return sub { exists $_[0]->{attr}{$attr} }
   if $attr !~ m{=};
  if ( $attr =~ m{^($NAME)="(.*?)"$} ) {
    my ( $k, $v ) = ( $1, $2 );
    return sub { exists $_[0]{attr}{$k} && $_[0]{attr}{$k} eq $v };
  }
  if ( $attr =~ m{^($NAME)~="(.*?)"$} ) {
    my ( $k, $v ) = ( $1, $2 );
    return sub {
      return 0 unless defined $_[0]{attr}{$k};
      return 1 if grep { $_ eq $v } split /\s+/, $_[0]{attr}{$k};
      return 0;
    };
  }
  die "Don't understand $attr";
}

sub css_term {
  my $t = shift;

  return sub { 1 }
   if $t eq '*';
  return sub { $_[0]->{tag} eq $t }
   if $t =~ /^[-\w]+$/;

  $t =~ s/^($NAME)#($NAME)$/${1}[id="${2}"]/g;
  $t =~ s/^($NAME)\.($NAME)$/${1}[class~="${2}"]/g;

  die "Unsupported syntax: $t" unless $t =~ m{^($NAME)\[(.+?)\]$};
  my ( $tag, $attr ) = ( $1, $2 );
  my $test = css_attr( $attr );
  return $test unless length $tag;
  return sub { $_[0]->{tag} eq $tag && $test->( $_[0] ) };
}

sub css_test {
  my $t  = shift;
  my $tt = css_term( $t );
  return sub {
    return 0 unless @_;
    return $tt->( $_[0] );
  };
}

sub css_selector {
  my @p = split /\s+/, join ' ', @_;
  return sub { 0 }
   unless @p;

  my $t = css_test( shift @p );
  while ( @p ) {
    my $lt = $t;
    if ( $p[0] eq '>' ) {
      shift @p;
      my $nt = css_test( shift @p );
      $t = sub {
        my ( $nd, @tail ) = @_;
        return $nt->( $nd ) && $lt->( @tail );
      };
    }
    else {
      my $nt = css_test( shift @p );
      $t = sub {
        my ( $nd, @tail ) = @_;
        return 0 unless $nt->( $nd );
        while ( @tail ) {
          return 1 if $lt->( @tail );
          shift @tail;
        }
        return 0;
      };
    }
  }
  return sub { $t->( reverse @_ ) ? 1 : 0 };
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
