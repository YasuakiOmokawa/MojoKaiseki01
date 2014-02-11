package Kaiseki::Web::Controller::Root;

use Mojo::Base 'Mojolicious::Controller';
use Kaiseki::Model::Kaiseki;
use Kaiseki::Model::KaisekiForScrape;
use Storable;
use Storable qw(nstore);
use Carp 'croak';
use Mojo::IOLoop;

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
  $self->stash->{error} = '';
  $self->stash->{src} = '';

  # アナリティクスデータログの格納ファイルパス
  my $homedir = $self->app->home;
  my $filedir = $homedir . "/public/datas";
  my $file = $filedir . "/" . "all_metrics.txt";

  # dataファイル生成
  # my @gadata = $kaiseki->getGadata($client_id, $client_secret, $refresh_token, $view_id, $metrics . "<=0", $start_date, $end_date, $homedir);
  # my $file = $filedir . "/" . "${view_id}.tsv";
  # $kaiseki->savetoTsv( $file, @gadata);

  # Web解析データの取得
  my $kaiseki = Kaiseki::Model::Kaiseki->new;
  my $kaiseki_scrape = Kaiseki::Model::KaisekiForScrape->new;
  eval{
        my @rows = $kaiseki->getCustomerinfo(1);
        Mojo::IOLoop->timer(2 => sub { 
            $kaiseki_scrape->scrapeGadata($rows[0], $rows[1], $file);
          }
        );
  };

  $self->stash->{error} = $@ if $@;
  $self->render('example/detail');
  # Mojo::IOLoop->start;
};


1;