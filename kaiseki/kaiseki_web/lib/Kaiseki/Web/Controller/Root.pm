package Kaiseki::Web::Controller::Root;

use Mojo::Base 'Mojolicious::Controller';
use Kaiseki::Model::Kaiseki;
use Kaiseki::Model::KaisekiForScrape;
use Kaiseki::GA::useGA;
use Storable;
use Storable qw(nstore);
use Carp qw(croak);
use Mojo::IOLoop;
use JSON qw(encode_json);
# use Carp qw(verbose); # 完全なスタックトレースを実施したい場合はコメントアウトを外してください
use Mojo::Util qw(dumper url_escape);
use Time::Piece;
use Time::Seconds;


# Liteの、get '/' => sub {　部分
sub index {
  my $self = shift;
  $self->stash->{error} = '';

  $self->render('example/index');
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

  # リクエストパラメータの取得処理
  my $start_date = $self->req->param('start_date');
  # my $end_date = $self->req->param('end_date');
  my $goal = $self->req->param('goal') || "ga:goal1Value"; 
  my $metrics = $self->req->param('metrics') || "ga:pageviews";
  my $view_id = $self->req->param('g_view_id');

  # 全てのリクエストパラメータを表示（デバッグ用）
  my $req_params = $self->req->params->to_hash;
  $self->app->log->debug('all request parameter routing /detail dumps below');
  $self->app->log->debug("\n", dumper $req_params);

  ## データ取得用フォームへセットする値の設定
  # データ取得期間
  if ($start_date) {
    # リクエストパラメータが存在する場合、YYYY-mm-ddの形式で渡ってくるので以下の形で変換してやる。
    $start_date = localtime( Time::Piece->strptime($start_date, '%Y-%m-%d') );
  } else {
    $start_date = localtime;
  }
  $self->app->log->debug( "Time::Piece ",$Time::Piece::VERSION,"\n" );
  my $end_date = $start_date->add_months(1);
  $self->app->log->debug("localtime start_date is $start_date");
  $start_date = $start_date->ymd;
  $end_date = $end_date->ymd;
  # 目標値（ゴール）選択ボックス
  my $goal_value = $goal;
  $goal =~ s/[^\d+]//g;

  ## グラフプロットデータファイルの絶対パスの設定
  # ユーザid ←ログイン画面実装後にユーザidにしておく
  my $user_id = 1;
  my $homedir = $self->app->home;
  my $filedir = $homedir . "/public/datas/d" . $user_id;
  if (not -d $filedir) {
    $self->app->log->debug("ディレクトリ $filedir が存在しません。作成します");
    mkdir $filedir;
  }
  my $plot_file = $filedir . "/" . "graph_plot.json";
  $self->app->log->debug("graph_plot json path is " . $plot_file);

  ## jquery.ajax メソッドへ渡すグラフプロットファイルの相対パスの設定
  my $jquery_ajax_plot_path = "datas/d" . $user_id . "/graph_plot.json";


  # $view_idリクエストパラメータが渡されないときは、googleAnalytics APIを使ってデータ取得を行わない
  if ($view_id) {

    eval {
      # 解析モジュール群の使用開始宣言
      my $kaiseki = Kaiseki::Model::Kaiseki->new;

      # アナリティクスapi認証用データを取得
      my ($client_id, $client_secret, $refresh_token) = $kaiseki->get_ga_auth(1);
      $self->app->log->debug('get db parameter for requests analytics api dumps below');
      $self->app->log->debug("\n" . dumper $client_id . "\n" . $client_secret . "\n" . $refresh_token);

      # アナリティクスapi認証を実施
      my $analytics = Kaiseki::GA::useGA->new(
        $client_id,
        $client_secret,
        $refresh_token
      );

      # グラフテンプレートの作成
      my $ga_graph = $kaiseki->get_ga_graph_template($start_date, $end_date);

      # グラフテンプレートへ、アナリティクスAPIから取得した値を置き換えていく
      $ga_graph = $kaiseki->get_ga_graph(
        $analytics,
        $view_id,
        $goal_value,
        $start_date,
        $end_date,
        $metrics,
        $ga_graph,
      );
      my $json_out = encode_json($ga_graph);
      open(FH, "> $plot_file") or die("File Error!: $!");
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
      # 日付の変更
      # foreach my $date ($start_date, $end_date) {
      #   my ($year, $month, $day) = split('-', $date);
      #   $date = $year . "年" . $month . "月" . $day . "日";
      #   # $date = url_escape $date;
      #   $self->app->log->debug("date is $date");
      # }


      $self->stash->{ga_graph} = $ga_graph;
    };
    croak("コントローラでエラー発生: $@") if ($@);
  }
  else {
    $self->stash->{ga_graph} = '';
  }


  #### ↓これは全体指標の項目 ####

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

  #### ここまで ####

  $self->stash->{start_date} = $start_date;
  $self->stash->{jquery_ajax_plot_path} = $jquery_ajax_plot_path;
  $self->stash->{end_date} = $end_date;
  $self->stash->{goal_value} = $goal_value;
  $self->stash->{metrics} = $metrics;
  $self->stash->{goal} = $goal;
  $self->stash->{error} = $@ if $@;

  $self->render('example/detail');
  # Mojo::IOLoop->start;
};


1;