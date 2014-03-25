#!/usr/bin/env perl
# Modelロジックのテストを行うためのスクリプト
use strict;
use warnings;
use Data::Dumper;
use JSON;
use utf8;
# use LWP::Simple;
# use URI;
# use Storable;
# use Storable qw(nstore);
# Modelを読み込むためのライブラリのパスの設定
use FindBin;
use lib "$FindBin::Bin/../lib";
# Modelの利用
use Kaiseki::Model::Kaiseki;
use Kaiseki::Model::KaisekiForScrape;
use feature 'say';
use Storable;
use Storable qw(nstore);
use Mojo::IOLoop;
use Kaiseki::GA::useGA;

# 以下にテストロジックを書く
my $self = shift;
# アナリティクスビューIDの取得
my $kaiseki = Kaiseki::Model::Kaiseki->new;
my ($view_id) = $kaiseki->getgaviewid(1, 1);

# アナリティクス認証データの取得
my ($client_id, $client_secret, $refresh_token) = $kaiseki->getgaauth(1);
my $analytics = Kaiseki::GA::useGA->new(
  $client_id,
  $client_secret,
  $refresh_token
);

my $homedir = "$FindBin::Bin/..";
my $filedir = $homedir . "/public/datas/" . $client_id;

# 比較用のデータファイル名
my $gfile = $filedir . "/" . "${view_id}_good.dat";
my $bfile = $filedir . "/" . "${view_id}_bad.dat";

# ハッシュ生成(ファイルを生成したあとでサービス上限の節約をしたいときはここコメントアウトしてちょ)
# my %gagood = $kaiseki->getGadata($client_id, $client_secret, $refresh_token, $view_id, $metrics . ">0", $start_date, $end_date, $homedir);

# グラフテンプレートの作成
my %ga_graph = $kaiseki->get_ga_graph_template('2012-12-05', '2013-01-05');

# グラフ値の計算
%ga_graph = $kaiseki->get_ga_graph(
  $analytics,
  $view_id,
  "ga:goal1Value",
  '2012-12-05',
  '2013-01-05',
  'ga:pageviews',
  $homedir,
  %ga_graph,
);

print Dumper \%ga_graph,"\n";
# my $html = '<tr><td class="ok-value">0</td><td class="metrics">PV数</td><td class="bad-value">0</td><td class="diff-value">0</td></tr>';
# my $text = 'PV数';
# my $value;
# my $flg_value;
# my $calc;
# # my $searched = first { $_ =~ '検索' } $html;
# print '原文',"\n";
# print $html,"\n";
# # $searched =~ s|検索|置換|;
# $flg_value = 'ok';
# $value = '200';
# $calc = '-1';
# print 'ok_value変換',"\n";
# $html =~ s|(.*?<td class="${flg_value}_value">).*?(</td>(<td>$text</td>)?.*)|${1}$value${2}|;
# $html =~ s|(<td class="diff_value">).*?(</td>)|${1}$calc${2}|;
# print $html,"\n";
# $flg_value = 'bad';
# $value = '2';
# $calc = '-2';
# print 'bad_value変換',"\n";
# $html =~ s|(.*?<td class="${flg_value}_value">).*?(</td>(<td>$text</td>)?.*)|${1}$value${2}|;
# $html =~ s|(<td class="diff_value">).*?(</td>)|${1}$calc${2}|;
# print $html,"\n";
