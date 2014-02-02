package Kaiseki::Web::Controller::Root;

use Mojo::Base 'Mojolicious::Controller';
use Kaiseki::Model::Kaiseki;
use Storable;
use Storable qw(nstore);
use Carp 'croak';

# Liteの、get '/' => sub {　部分
sub index {
  my $self = shift;
  my $start_date = $self->req->param('start_date');
  my $end_date = $self->req->param('end_date');
  $self->stash->{start_date} = $start_date;
  $self->stash->{end_date} = $end_date;
  $self->stash->{error} = '';
  $self->stash->{src} = '';

  # アナリティクスビューIDの取得
  my $kaiseki = Kaiseki::Model::Kaiseki->new;

  if ($start_date) {

    my $src;
    eval{
          my $kaiseki = Kaiseki::Model::Kaiseki->new;
          my @rows = $kaiseki->getCustomerinfo(1);
          # `/myapp/mvc/kaiseki/kaiseki_web/t/opePhantomJS.sh start`;
          $src = $kaiseki->scrapeGadata($rows[0], $rows[1]);
          # `/myapp/mvc/kaiseki/kaiseki_web/t/opePhantomJS.sh stop`;
    };
    # $self->app->log->debug("src is $src");

    $self->stash->{error} = $@ if $@;
    $self->stash->{src} = $src;
    $self->render('example/index');
  }
  # elsif ($metrics) {
  #   $self->stash->{error} = '比較基準を正しく入力してください';
  #   $self->render('example/index');
  # }
  else {
    $self->render('example/index');
  }
};

sub selectdetail {
  my $self = shift;
  my $metrics = $self->req->param('metrics');
  my $start_date = $self->req->param('start_date');
  my $end_date = $self->req->param('end_date');
  my $caption = $self->req->param('caption');

  $self->stash->{start_date} = $start_date;
  $self->stash->{end_date} = $end_date;
  $self->stash->{metrics} = $metrics;
  $self->stash->{caption} = $caption;
  $self->render('example/selectdetail');
};

sub detail {
  my $self = shift;
  # my $uranaikekka = $self->req->param('uranaikekka');
  # $self->stash->{addkekka} = $uranaikekka;
  $self->render('example/detail');
};


1;