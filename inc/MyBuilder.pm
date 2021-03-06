package MyBuilder;

use base qw( Module::Build );

sub create_build_script {
  my ( $self, @args ) = @_;
  $self->_auto_mm;
  return $self->SUPER::create_build_script( @args );
}

sub _auto_mm {
  my $self = shift;
  my $mm   = $self->meta_merge;
  my @meta = qw( homepage bugtracker MailingList repository );
  for my $meta ( @meta ) {
    next if exists $mm->{resources}{$meta};
    my $auto = "_auto_$meta";
    next unless $self->can( $auto );
    my $av = $self->$auto();
    $mm->{resources}{$meta} = $av if defined $av;
  }
  $self->meta_merge( $mm );
}

sub _auto_repository {
  my $self = shift;
  if ( -d '.svn' ) {
    my $info = `svn info .`;
    return $1 if $info =~ /^URL:\s+(.+)$/m;
  }
  return;
}

sub _auto_bugtracker {
  'http://rt.cpan.org/NoAuth/Bugs.html?Dist=' . shift->dist_name;
}

sub ACTION_testauthor {
  my $self = shift;
  $self->test_files( 'xt/author' );
  $self->ACTION_test;
}

sub ACTION_critic {
  exec qw( perlcritic -1 -q -profile perlcriticrc lib/ ), glob 't/*.t';
}

sub ACTION_tags {
  exec(
    qw(
     ctags -f tags --recurse --totals
     --exclude=blib
     --exclude=.svn
     --exclude='*~'
     --languages=Perl
     t/ lib/
     )
  );
}

sub ACTION_tidy {
  my $self = shift;

  my @extra = qw( Build.PL );

  my %found_files = map { %$_ } $self->find_pm_files,
   $self->_find_file_by_type( 'pm', 't' ),
   $self->_find_file_by_type( 'pm', 'inc' ),
   $self->_find_file_by_type( 't',  't' );

  my @files = ( keys %found_files,
    map { $self->localize_file_path( $_ ) } @extra );

  for my $file ( @files ) {
    system 'perltidy', '-b', $file;
    unlink "$file.bak" if $? == 0;
  }
}

1;
