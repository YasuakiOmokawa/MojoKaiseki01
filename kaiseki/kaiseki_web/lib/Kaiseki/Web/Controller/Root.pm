package Kaiseki::Web::Controller::Root;

use Mojo::Base 'Mojolicious::Controller';
use Kaiseki::Model::Kaiseki;
use Kaiseki::Model::KaisekiForScrape;
use Kaiseki::GA::useGA;
use Storable;
use Storable qw(nstore);
use Carp 'croak';
use Mojo::IOLoop;
use JSON qw(encode_json);

# Liteの、get '/' => sub {　部分
sub index {
  my $self = shift;
  my $start_date = 'hello';
  # my $start_date = $self->req->param('start_date');
  # my $end_date = $self->req->param('end_date');
  $self->stash->{start_date} = '';
  $self->stash->{end_date} = '';
  # $self->stash->{start_date} = $start_date;
  # $self->stash->{end_date} = $end_date;
  $self->stash->{error} = '';

  # アナリティクスビューIDの取得
  my $kaiseki = Kaiseki::Model::Kaiseki->new;
  my ($view_id) = $kaiseki->getgaviewid(1, 1);

  if ($start_date) {

    my ($client_id, $client_secret, $refresh_token);
    eval{
      # アナリティクス認証データの取得
        ($client_id, $client_secret, $refresh_token) = $kaiseki->getgaauth(1);
        my $analytics = Kaiseki::GA::useGA->new(
          $client_id,
          $client_secret,
          $refresh_token
        );

        # アナリティクスデータログの格納ファイルパス
        my $homedir = $self->app->home;
        my $filedir = $homedir . "/public/datas/" . $client_id;
        if (not -d $filedir) {
          print "ディレクトリ $filedir が存在しません。作成します\n";
          mkdir $filedir;
        }

        #client_idのドットを置換（ディレクトリ名にしたいので）
        $client_id =~ s/\.//g;
        $client_id = 'a' . $client_id;
        # 比較用のデータファイル名
        # my $gfile = $filedir . "/" . "${view_id}_good.dat";
        # my $bfile = $filedir . "/" . "${view_id}_bad.dat";
        my $file = $filedir . "/" . "graph_plot.json";

        # グラフテンプレートの作成
        my $ga_graph = $kaiseki->get_ga_graph_template('2012-12-05', '2013-01-05');
        # グラフ値の計算
        $ga_graph = $kaiseki->get_ga_graph(
          $analytics,
          $view_id,
          "ga:goal1Value",
          '2012-12-05',
          '2013-01-05',
          'ga:pageviews',
          $homedir,
          $ga_graph,
        );        
        my $json_out = encode_json($ga_graph);
        open(FH, ">$file") or die("File Error!: $!");
        print FH $json_out;
        close(FH);

        # ハッシュ読み出し
        # $gagood = retrieve($gfile);
        # $gabad = retrieve($bfile);

        # 英語から日本語へ変換
        # $gagood = $kaiseki->entoJp($gagood);
        # $gabad = $kaiseki->entoJp($gabad);

        # 差分の生成
        # $gadiff = $kaiseki->diffGahash($gagood, $gabad);
        # $gadiff = $kaiseki->diffGahash($gabad, $gagood);
    };
    # $self->app->log->debug("src is $src");
    $self->stash->{client_id} = $client_id;
    $self->stash->{error} = $@ if $@;
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
  $self->stash->{client_id} = $self->req->param('client_id');

  # アナリティクスデータログの格納ファイルパス
  # my $homedir = $self->app->home;
  # my $filedir = $homedir . "/public/datas";
  # my $file = $filedir . "/" . "allmetrics.txt";

  # テンプレートファイル生成
  # my $kaiseki_scrape = Kaiseki::Model::KaisekiForScrape->new;
  # $kaiseki_scrape->createTemplate($filedir);

  # Web解析データの取得
  # my $kaiseki = Kaiseki::Model::Kaiseki->new;
  # eval{
  #       my @rows = $kaiseki->getCustomerinfo(1);
  #       Mojo::IOLoop->timer(2 => sub { 
  #           $kaiseki_scrape->scrapeGadata($rows[0], $rows[1], $file);
  #         }
  #       );
  # };

  $self->stash->{error} = $@ if $@;
  $self->render('example/detail');
  # Mojo::IOLoop->start;
};


1;