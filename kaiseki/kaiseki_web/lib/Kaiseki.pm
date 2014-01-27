package Kaiseki;

use strict;
use warnings;
use File::Spec;
use Carp qw/croak/;

our $VERSION = '0.10'; # Delta

sub config {
    my $filename = Kaiseki->config_file();
    my $config = do $filename;
    croak ("Cannnot load configuration file: $filename") if $@;
    return $config;
}

sub config_file {
    my $filename = $ENV{Kaiseki_CONFIG};
    if( !$filename ) {
        my $mode = $ENV{PLACK_ENV} || 'development';
        $filename = File::Spec->catfile( Kaiseki->base_dir(), 'config', $mode . '.pl' );
    }
    $filename = readlink $filename || $filename;
    croak("Cannot find configuration file: $filename") unless -f $filename;
    return $filename;
}

sub base_dir {
    my $path = ref $_[0] || $_[0];
    $path =~ s!::!/!g;
    if ( my $libpath = $INC{"$path.pm"} ) {
        $libpath =~ s!(?:blib/)?lib/+$path\.pm$!!;
        return File::Spec->rel2abs( $libpath || './' );
    }
    return File::Spec->rel2abs( './' );
}

1;