#!perl
# vim:ts=2:sw=2:et:ft=perl

use strict;
use warnings;

use HTML::DOM;
use HTML::jQuery;

use lib qw( t/lib );

use Data::Dumper;
use TestTools;
use Test::More tests => 1;

my %html = mydata;

my $dom = HTML::DOM->new;
$dom->write( $html{test1} );

my $jq = jq( $dom, 'a' );
#diag Dumper( $jq );

is scalar( @$jq ), 2, 'got two matches';

__DATA__

=name test1
<html>
  <head>
    <title>Test 1</title>
  </head>
  <body>
    <h1>Test 1</h1>
    <a href="http://hexten.net/">Hexten</a>
    <p>This is some <a href="http://example.com/">example</a> text.
  </body>
</html>
