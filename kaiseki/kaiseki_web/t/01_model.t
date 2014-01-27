#!/usr/bin/env perl
# Modelロジックのテストを行うためのスクリプト
use strict;
use warnings;
use Data::Dumper;
use JSON;
# use utf8;
# use LWP::Simple;
# use URI;
# use Storable;
# use Storable qw(nstore);
# Modelを読み込むためのライブラリのパスの設定
use FindBin;
use lib "$FindBin::Bin/../lib";
# Modelの利用
use Kaiseki::Model::Kaiseki;
use feature 'say';
use Storable;
use Storable qw(nstore);

# 以下にテストロジックを書く
# ファイル存在確認後消去ロジック
# my $file = 'text.txt';
# -e $file and unlink $file;

# 辞書翻訳ロジック
# my @array = qw(hello my friend);
# my @array2 = qw(you love summer);
# ハッシュ差分表示ロジック
my %bad = (
'pv' => '1320',
'visits' => '198',
'repeats' => '1',
'new_visits' => '45.0',
'baunce' => '54.0',
);

my %good = (
'pv' => '1625',
'visits' => '346',
'repeats' => '3',
'new_visits' => '50.0',
'baunce' => '45.0',
);

# my $hashref = &diffGahash(\%bad, \%good);

sub diffGahash {
  my ($bad, $good) = @_;
  my %diff;
  while (my ($key, $value) = each %$bad) {
    $value = $value - $good->{$key};
    $diff{$key} = $value;  
  }
  return \%diff;
}

# my $file = "test.dat";
# nstore \%hash, $file;

# my $gagood = retrieve($file);
# print Dumper $gagood;
my %gagood = (
    'visits' => [ '0', 'ga:visits' ],
    'bounces' => [ '0', 'ga:bounces' ],
);

my $gagood = &entoJp(\%gagood);
 # print "\n";
 # print "1: ハッシュのすべての要素をeach関数を使ってwhileループで出力する\n";
 # while (my ($key, $value) = each %hash) {
 #  print $key . " => " . $value, "\n";
 # }
 # print "\n";
 print "2: ハッシュのすべての要素をforeachを使ってsort出力する\n";
 foreach my $key (sort keys(%$gagood)) {
  print $key . " => [" . $gagood->{$key}[0] . ', ' . $gagood->{$key}[1], "]\n";
 }
 print "\n";

sub entoJp {
  my ($hashref) = @_;
  # my ($self, $hashref) = @_;
  # my @arrays = (\@array, \@array2);
  # ハッシュキー辞書変換ロジック
  my %dict = (
    'visitors' => '訪問者数',
    'visits' => 'セッション数',
    'organic_searches' => '自然検索',
    'new_visits' => '新規訪問者数',
    'bounces' => '直帰数',
    'avg_time_on_site' => '平均滞在時間[秒]',
    'percent_new_visits' => '新規訪問率',
    'visit_bounce_rate' => '直帰率',
    'time_on_site' => '滞在時間[秒]',
    '_c_p_c' => '広告クリック単価',
    'cost_per_transaction' => '広告トランザクション単価',
    '_r_p_c' => '広告収益単価',
    'ad_clicks' => '広告クリック数',
    '_c_p_m' => '広告インプレッション単価',
    'cost_per_goal_conversion' => '広告コンバージョン単価',
    'ad_cost' => '広告コスト',
    '_c_t_r' => '広告クリック率',
    'impressions' => '広告表示回数',
    'cost_per_conversion' => '広告コンバージョン単価',
    'goal_abandons_all' => '目標達成プロセスの放棄数',
    'goal_value_all' => '合計目標値',
    'goal_completions_all' => '合計目標完了数',
    '_r_o_i' => '投資利益率',
    'goal_abandon_rate_all' => 'コンバージョン全体の放棄率',
    'goal_value_per_visit' => '平均目標値',
    'entrances' => '閲覧開始数',
    'goal_starts_all' => 'すべての目標の開始数',
    'goal_conversion_rate_all' => '全ての目標のコンバージョン率',
    'page_value' => 'ページの価値',
    'pageviews' => 'ページビュー数',
    'unique_pageviews' => 'ページ別訪問数',
    'time_on_page' => 'ページの閲覧時間',
    'exits' => '離脱数',
    'pageviews_per_visit' => '訪問別ページビュー',
    'avg_time_on_page' => '平均ページ滞在時間',
    'entrance_rate' => '閲覧開始率',
    'search_uniques' => '合計ユニーク検索数',
    'exit_rate' => '離脱率',
    'search_result_views' => '検索結果ページのページビュー',
    'avg_search_result_views' => '平均検索結果ページビュー',
    'search_duration' => '検索後の時間',
    'search_depth' => '検索深度',
    'search_exits' => '検索結果の離脱',
    'avg_search_duration' => '検索後の平均時間',
    'search_refinements' => '再検索数',
    'search_visits' => 'サイト内検索の利用数',
    'percent_visits_with_search' => 'サイト内検索の利用率',
    'avg_search_depth' => '平均検索深度',
    'percent_search_refinements' => '再検索率',
    'page_load_time' => 'ページロード時間[ミリ秒]',
    'domain_lookup_time' => 'ドメインのルックアップ時間[ミリ秒]',
    'page_load_sample' => 'ページロードサンプル',
    'page_download_time' => 'ページのダウンロード時間[ミリ秒]',
    'goal_value_all_per_search' => '検索別の平均目標値',
    'avg_page_download_time' => 'ページの平均ダウンロード時間[秒]',
    'search_goal_conversion_rate_all' => '検索コンバージョン率',
    'avg_page_load_time' => '平均ページロード時間[秒]',
    'search_exit_rate' => '検索結果の離脱率',
    'avg_domain_lookup_time' => 'ドメインの平均ルックアップ時間[秒]',
    'avg_dom_interactive_time' => '',
    'avg_server_connection_time' => '',
    'redirection_time' => '',
    'server_connection_time' => '',
    'speed_metrics_sample' => '',
    'dom_interactive_time' => '',
    'avg_redirection_time' => '',
    'dom_content_loaded_time' => '',
    'avg_server_response_time' => '',
    'server_response_time' => '',
    'dom_latency_metrics_sample' => '',
    'avg_event_value' => '',
    'screenviews' => '',
    'screenviews_per_session' => '',
    'event_value' => '',
    'total_events' => '',
    'unique_screenviews' => '',
    'avg_dom_content_loaded_time' => '',
    'time_on_screen' => '',
    'avg_screenview_duration' => '',
    'transactions_per_visit' => '',
    'transaction_shipping' => '',
    'visits_with_event' => '',
    'transactions' => '',
    'transaction_revenue_per_visit' => '',
    'revenue_per_transaction' => '',
    'transaction_revenue' => '',
    'total_value' => '',
    'transaction_tax' => '',
    'events_per_visit_with_event' => '',
    'unique_purchases' => '',
    'local_transaction_tax' => '',
    'local_transaction_shipping' => '',
    'revenue_per_item' => '',
    'items_per_purchase' => '',
    'item_quantity' => '',
    'local_item_revenue' => '',
    'social_interactions' => '',
    'local_transaction_revenue' => '',
    'item_revenue' => '',
    'exceptions' => '',
    'fatal_exceptions_per_screenview' => '',
    'adsense_revenue' => '',
    'social_interactions_per_visit' => '',
    'fatal_exceptions' => '',
    'user_timing_value' => '',
    'user_timing_sample' => '',
    'avg_user_timing_value' => '',
    'exceptions_per_screenview' => '',
    'unique_social_interactions' => '',
  );

  my %newhash;
  # print Dumper $hashref;
  # print "2: ハッシュの要素を辞書ハッシュを使って入れ替える\n";
  while (my ($key, $value) = each %$hashref) {
    # print $key . " => " . $value, "\n";
    if (exists($dict{$key})) {
      if ($dict{$key} =~ /.+/) {
        # print "\%dict value is $dict{$key}\n";
        # my $newkey = $dict{$key} . "(" . $key . ")";
        my $newkey = $key . '(' . $dict{$key} . ')';
        $newhash{$newkey} = [ $value->[0], $value->[1] ];
      }
    } else {
        $newhash{$key} = [ $value->[0], $value->[1] ];
    }
  }
  # print Dumper \%newhash;
  return \%newhash;
}

# my @data;
# for my $words (@arrays) {
#  for my $word (@$words) {
#   if (exists($dict{$word})) {
#    if ($dict{$word} =~ /.+/) {
#     $word =~ s|$word|$dict{$word}($word)|;
#    }
#   }
#  }
# }
# return @arrays;
# print "originai array\n";
# print Dumper @arrays;
# print "substituted array\n";
# print Dumper @data;
# # GoogleアナリティクスAPIの一覧を公式リファレンスから取得
# my $atnd_api = URI->new('https://www.googleapis.com/analytics/v3/metadata/ga/columns?pp=1');
# my $json = get($atnd_api->as_string);
# # jsonデータのファイル
# my $file = 'gaapiv3json.dat';
# my $gaapi_data = JSON->new()->decode($json);
# nstore $gaapi_data, $file;
# # jsonデータ読み出し
# $gaapi_data = retrieve($file);
# # my $jsond = JSON->new()->encode($ret);
# # my $gaapi_data = JSON->new()->decode($jsond);
# # my $gaapi_data = JSON->new()->decode($json);
# my $metricses;
# my @metricses;
# foreach my $ref ( @{ $gaapi_data->{items} } ) {
#  if ($ref->{attributes}->{status} eq 'PUBLIC' and $ref->{attributes}->{type} eq 'METRIC') {
#   if ( not $ref->{id} =~ /XX|ga:margin|ga:socialActivities|ga:uniqueEvents/) {
#       push @metricses, $ref->{id};
#       if (@metricses == 10) {
#        $metricses = join(',', @metricses);
#        # $metricses =~ s/^,//g;
#        print $metricses, "\n";
#        @metricses = ();
#        # print $#metricses;
#       }  
#   }  
#  }
# }
# print $#metricses;
# my $kaiseki = Kaiseki::Model::Kaiseki->new;
# my @rows = $kaiseki->getgaauth(1);
# my @rows = $kaiseki->getgaview(1, 1);
# my ($client_id, $client_secret, $refresh_token) = $kaiseki->getgaauth(1);
# my ($view_id) = $kaiseki->getgaviewid(1, 1);
# my ($view_id) = $kaiseki->getgaviewid(1, 1);
# my @head = $kaiseki->loadTsv("${view_id}_header.tsv");
# print $client_id,"\n";
# print $client_secret,"\n";
# print $refresh_token,"\n";
# print $view_id,"\n";
# print Dumper @head;

# ga:visitors,
# ga:newVisits,
# ga:percentNewVisits,
# ga:visits,
# ga:bounces,
# ga:entranceBounceRate,
# ga:visitBounceRate,
# ga:timeOnSite,
# ga:avgTimeOnSite,
# ga:organicSearches,
# ga:impressions
 