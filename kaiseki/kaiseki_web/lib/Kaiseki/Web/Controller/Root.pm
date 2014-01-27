package Kaiseki::Web::Controller::Root;

use Mojo::Base 'Mojolicious::Controller';
use Kaiseki::Model::Kaiseki;
use Storable;
use Storable qw(nstore);
use Carp 'croak';

# Liteの、get '/' => sub {　部分
sub index {
  my $self = shift;
  my $metrics = $self->req->param('metrics');
  my $start_date = $self->req->param('start_date');
  my $end_date = $self->req->param('end_date');
  $self->stash->{start_date} = $start_date;
  $self->stash->{end_date} = $end_date;
  $self->stash->{error} = '';
  $self->stash->{caption} = '';
  $self->stash->{gagood} = '';
  $self->stash->{gabad} = '';
  $self->stash->{gadiff} = '';

  # アナリティクスビューIDの取得
  my $kaiseki = Kaiseki::Model::Kaiseki->new;
  my ($view_id) = $kaiseki->getgaviewid(2, 2);

  if ($metrics && $metrics =~ /^ga:/) {

    my $gagood;
    my $gabad;
    my $gadiff;
    eval{
        # アナリティクス認証データの取得
        my ($client_id, $client_secret, $refresh_token) = $kaiseki->getgaauth(2);

        # アナリティクスデータログの格納ファイルパス
        my $homedir = $self->app->home;
        my $filedir = $homedir . "/public/datas/senk";

        # 比較用のデータファイル名
        my $gfile = $filedir . "/" . "${view_id}_good.dat";
        my $bfile = $filedir . "/" . "${view_id}_bad.dat";

        # ハッシュ生成(ファイルを生成したあとでサービス上限の節約をしたいときはここコメントアウトしてちょ)
        # my %gagood = $kaiseki->getGadata($client_id, $client_secret, $refresh_token, $view_id, $metrics . ">0", $start_date, $end_date, $homedir);
        # my %gabad = $kaiseki->getGadata($client_id, $client_secret, $refresh_token, $view_id, $metrics . "<=0", $start_date, $end_date, $homedir);
        # nstore \%gagood, $gfile;
        # nstore \%gabad, $bfile;

        # ハッシュ読み出し
        $gagood = retrieve($gfile);
        $gabad = retrieve($bfile);

        # 英語から日本語へ変換
        $gagood = $kaiseki->entoJp($gagood);
        $gabad = $kaiseki->entoJp($gabad);

        # 差分の生成
        # $gadiff = $kaiseki->diffGahash($gagood, $gabad);
        $gadiff = $kaiseki->diffGahash($gabad, $gagood);

    };

    $self->stash->{error} = $@ if $@;
    $self->stash->{caption} = $metrics;
    $self->stash->{gagood} = $gagood;
    $self->stash->{gabad} = $gabad;
    $self->stash->{gadiff} = $gadiff;
    $self->render('example/index');
  }
  elsif ($metrics) {
    $self->stash->{error} = '比較基準を正しく入力してください';
    $self->render('example/index');
  }
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