use strict;
use warnings;
use Module::Build;

use lib 'inc';

use MyBuilder;

my $builder = MyBuilder->new(
  module_name        => 'HTML::jQuery',
  license            => 'perl',
  dist_author        => 'Andy Armstrong <andy@hexten.net>',
  dist_version_from  => 'lib/HTML/jQuery.pm',
  configure_requires => { 'Module::Build' => 0.38 },
  requires           => { 'HTML::DOM' => '0.048' },
  add_to_cleanup     => ['HTML-jQuery-*'],
);

$builder->create_build_script();
