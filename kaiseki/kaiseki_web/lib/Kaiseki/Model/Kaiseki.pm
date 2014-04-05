package Kaiseki::Model::Kaiseki;

use Mouse;
use utf8;
use Kaiseki::DB::connDB;
use Kaiseki::GA::useGA;
use Kaiseki::Scrape::useScrape;
use Data::Dumper;
use DateTime;
use JSON;
use LWP::Simple;
use URI;
# use Time::HiRes 'sleep';
use Storable;
use Storable qw(nstore);
use Carp 'croak';

sub tstview {
	my ($self, $param) = @_;
	return $param;
}

sub diffGahash {
 my ($self, $bad, $good) = @_;
   my %diff;
   while (my ($key, $ref_to_A) = each %$bad) {
    my $value = $ref_to_A->[0] - $good->{$key}->[0];
     $diff{$key} = $value;
  }
  return \%diff;
}


sub getGadata {
	my ($self,
		$client_id,
		$client_secret,
		$refresh_token,
		$view_id,
		$metrics,
		$start_date,
		$end_date,
		$homedir ) = @_;

	# メトリクス取得
	# GoogleアナリティクスAPIの一覧を公式リファレンスから取得
	# my $atnd_api = URI->new('https://www.googleapis.com/analytics/v3/metadata/ga/columns?pp=1');
	# my $json = get($atnd_api->as_string);

	# jsonデータのファイル
    my $filedir = $homedir . "/public/datas/gaapi_json";
	my $file = $filedir . "/" . 'gaapiv3json.dat';

	# my $gaapi_data = JSON->new()->decode($json);
	# nstore $gaapi_data, $file;

	# jsonデータ読み出し
	my $gaapi_data = retrieve($file);

	# アナリティクスAPIを使ってデータをリクエスト
	my @metricses;
	# my @header;
	# my @body;
	my %data;
	foreach my $ref ( @{ $gaapi_data->{items} } ) {
		if ($ref->{attributes}->{status} eq 'PUBLIC' and $ref->{attributes}->{type} eq 'METRIC') {
			if (not $ref->{id} =~ /XX|ga:margin|ga:socialActivities|ga:uniqueEvents/) {
			    push @metricses, $ref->{id};
			    # アナリティクスapiの仕様により、一回に指定できるメトリクスが10個のため
			    # こんなクソロジックになる。。
			    if (@metricses == 10) {
					my $res = Kaiseki::GA::useGA->new($client_id,
														$client_secret,
														$refresh_token,
														$view_id,
														$metrics,
														$start_date,
														$end_date,
														@metricses);
					@metricses = ();
					foreach my $key (keys($res->{_totals})) {
						# print "\$key: ", $key, " value: ", $res->_totals->{$key}, "\n";
						# push @header, $key;
						# push @body, $res->_totals->{$key};
						# $data{$key} = $res->_totals->{$key};
						(my $orgkey = $key) =~ s/(_[a-z])/uc($&)/ge;
						$orgkey =~ s/_//g;
						$orgkey = 'ga:' . $orgkey;
						$data{$key} = [ $res->_totals->{$key}, $orgkey ];
					}
			    }
			}			
		}
	}
	# my @data;
	# push @data, \@header;
	# push @data, \@body;
	# return @data;
	# print Dumper @data;
	# print Dumper %data;
	return %data;
}

# sub getGahead {
# 	my ($self,
# 		$client_id,
# 		$client_secret,
# 		$refresh_token,
# 		$view_id,
# 		$metrics,
# 		$start_date,
# 		$end_date,
# 		$homedir ) = @_;

# 	# メトリクス取得
# 	# GoogleアナリティクスAPIの一覧を公式リファレンスから取得
# 	# my $atnd_api = URI->new('https://www.googleapis.com/analytics/v3/metadata/ga/columns?pp=1');
# 	# my $json = get($atnd_api->as_string);

# 	# jsonデータのファイル
#     my $filedir = $homedir . "/public/datas/gaapi_json";
# 	my $file = $filedir . "/" . 'gaapiv3json.dat';

# 	# my $gaapi_data = JSON->new()->decode($json);
# 	# nstore $gaapi_data, $file;

# 	# jsonデータ読み出し
# 	my $gaapi_data = retrieve($file);
# 	my @metricses;
# 	my @gatsv_headers;
# 	foreach my $ref ( @{ $gaapi_data->{items} } ) {
# 		if ($ref->{attributes}->{status} eq 'PUBLIC' and $ref->{attributes}->{type} eq 'METRIC') {
# 			if (not $ref->{id} =~ /XX|ga:margin|ga:socialActivities|ga:uniqueEvents/) {
# 			    push @metricses, $ref->{id};
# 			    # アナリティクスapiの仕様により、一回に指定できるメトリクスが10個のため
# 			    # こんなクソロジックになる。。
# 			    if (@metricses == 10) {
# 					my $res = Kaiseki::GA::useGA->new($client_id,
# 														$client_secret,
# 														$refresh_token,
# 														$view_id,
# 														$metrics,
# 														$start_date,
# 														$end_date,
# 														@metricses);
# 					@metricses = ();
# 					foreach my $key (keys($res->{_totals})) {
# 						# print "\$key: ", $key, " value: ", $res->_totals->{$key}, "\n";
# 						push @gatsv_headers, $key;
# 					}
# 			    }
# 			}			
# 		}
# 	}
# 	return @gatsv_headers;
# 	# print Dumper @gatsv_headers;
# }

# sub getGabody {
# 	my ($self,
# 		$client_id,
# 		$client_secret,
# 		$refresh_token,
# 		$view_id,
# 		$metrics,
# 		$start_date,
# 		$end_date ) = @_;

# 	# メトリクス取得
# 	# GoogleアナリティクスAPIの一覧を公式リファレンスから取得
# 	my $atnd_api = URI->new('https://www.googleapis.com/analytics/v3/metadata/ga/columns?pp=1');
# 	my $json = get($atnd_api->as_string);

# 	# # jsonデータを保存
# 	# my $file = 'gaapiv3json.dat';
# 	# nstore \$json, $file;

# 	# jsonデータ読み出し
# 	my @metricses;
# 	# my $ret = retrieve($file);
# 	my $gaapi_data = JSON->new()->decode($json);
# 	my @gatsv_bodies;
# 	foreach my $ref ( @{ $gaapi_data->{items} } ) {
# 		if ($ref->{attributes}->{status} eq 'PUBLIC' and $ref->{attributes}->{type} eq 'METRIC') {
# 			if (not $ref->{id} =~ /XX|ga:margin|ga:socialActivities|ga:uniqueEvents/) {
# 			    push @metricses, $ref->{id};
# 			    # アナリティクスapiの仕様により、一回に指定できるメトリクスが10個のため
# 			    # こんなクソロジックになる。。
# 			    if (@metricses == 10) {
# 					my $res = Kaiseki::GA::useGA->new($client_id,
# 														$client_secret,
# 														$refresh_token,
# 														$view_id,
# 														$metrics,
# 														$start_date,
# 														$end_date,
# 														@metricses);
# 					@metricses = ();
# 					foreach my $key (keys($res->{_totals})) {
# 						# print "\$key: ", $key, " value: ", $res->_totals->{$key}, "\n";
# 						push @gatsv_bodies, $res->_totals->{$key};
# 					}
# 			    }
# 			}			
# 		}
# 	}
# 	return @gatsv_bodies;
# 	# print Dumper @gatsv_headers;
# }

# sub getGabody {
# 	my ($self,
# 		$client_id,
# 		$client_secret,
# 		$refresh_token,
# 		$view_id,
# 		$metrics,
# 		$start_date,
# 		$end_date ) = @_;
# 	my $res = Kaiseki::GA::useGA->new($client_id,
# 										$client_secret,
# 										$refresh_token,
# 										$view_id,
# 										$metrics,
# 										$start_date,
# 										$end_date);
# 	my @gatsv_bodies;
# 	foreach my $key (keys($res->{_totals})) {
# 		# print "\$key: ", $key, " value: ", $res->_totals->{$key}, "\n";
# 		push @gatsv_bodies, $res->_totals->{$key};
# 	}
# 	return @gatsv_bodies;
# 	# print Dumper @gatsv_bodies;
# }

sub addkekka {
	my ($self, $uranaikekka) = @_;
	my $teng = Kaiseki::DB::connDB->new;
	$teng->txn_begin;
	my $row = $teng->insert(result => {
		text => $uranaikekka,
		created_at => DateTime->now(time_zone => 'local'),
	});
	$teng->txn_commit;
}

sub loadTsv {
	my ($self, $file) = @_;
    -e $file or die qq(not found "$file");
    my @data;
    open my $fh, "<", $file or die qq(can not open "$file" : $!);
    eval{ flock($fh,2); };
    while( <$fh> ){
        chomp;
        my @cells = split /\t/;
        push @data, \@cells;
    }
    close $fh;
    return @data;
}

sub savetoTsv {
	# 2次元配列をTSVへ変換。
	# ファイル作成。あったら消して再作成
	my ($self, $file, @array) = @_;
	# my ($self, $addmode, $file, @array) = @_;
	-e $file and unlink $file;
	my @data;
	for my $str (@array) {
		$str = join("\t", @$str);
		$str = $str . "\n";
		push @data, $str;
		open( my $fh, '>>', $file) or die qq(can not open "$file" : $!);
		# open( my $fh, "$addmode", $file) or die qq(can not open "$file" : $!);
		eval { flock($fh, 2); };
		print $fh $str;
		close $fh;
		print "saved_1line: $str\n";
	}
}

sub entoJp {
	# 入力ハッシュのキーを置換。といっても直接置換はできないので、
	# 元のエントリを削除したあと新しいエントリを追加している。
	my ($self, $hashref) = @_;
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
	  'avg_dom_interactive_time' => 'a',
	  'avg_server_connection_time' => 'a',
	  'redirection_time' => 'a',
	  'server_connection_time' => 'a',
	  'speed_metrics_sample' => 'a',
	  'dom_interactive_time' => 'a',
	  'avg_redirection_time' => 'a',
	  'dom_content_loaded_time' => 'a',
	  'avg_server_response_time' => 'a',
	  'server_response_time' => 'a',
	  'dom_latency_metrics_sample' => 'a',
	  'avg_event_value' => 'a',
	  'screenviews' => 'a',
	  'screenviews_per_session' => 'a',
	  'event_value' => 'a',
	  'total_events' => 'a',
	  'unique_screenviews' => 'a',
	  'avg_dom_content_loaded_time' => 'a',
	  'time_on_screen' => 'a',
	  'avg_screenview_duration' => 'a',
	  'transactions_per_visit' => 'a',
	  'transaction_shipping' => 'a',
	  'visits_with_event' => 'a',
	  'transactions' => 'a',
	  'transaction_revenue_per_visit' => 'a',
	  'revenue_per_transaction' => 'a',
	  'transaction_revenue' => 'a',
	  'total_value' => 'a',
	  'transaction_tax' => 'a',
	  'events_per_visit_with_event' => 'a',
	  'unique_purchases' => 'a',
	  'local_transaction_tax' => 'a',
	  'local_transaction_shipping' => 'a',
	  'revenue_per_item' => 'a',
	  'items_per_purchase' => 'a',
	  'item_quantity' => 'a',
	  'local_item_revenue' => 'a',
	  'social_interactions' => 'a',
	  'local_transaction_revenue' => 'a',
	  'item_revenue' => 'a',
	  'exceptions' => 'a',
	  'fatal_exceptions_per_screenview' => 'a',
	  'adsense_revenue' => 'a',
	  'social_interactions_per_visit' => 'a',
	  'fatal_exceptions' => 'a',
	  'user_timing_value' => 'a',
	  'user_timing_sample' => 'a',
	  'avg_user_timing_value' => 'a',
	  'exceptions_per_screenview' => 'a',
	  'unique_social_interactions' => 'a',
	);
	# キーのみで値が入っていない場合は変換しない。
	my %hash;
	while (my ($key, $ref_to_A) = each %$hashref) {
		if (exists($dict{$key})) {
			my $newkey = $key . '(' . $dict{$key} . ')';
			$hash{$newkey} = [ $ref_to_A->[0], $ref_to_A->[1] ];
		} else {
			$hash{$key} = [ $ref_to_A->[0], $ref_to_A->[1] ];
		}
	}
	# print Dumper \%hash;
	return \%hash;
}

sub getgaauth {
	my ($self, $user_id) = @_;

	my $teng = Kaiseki::DB::connDB->new;
	# DBIのAutoCommit = 0 にするとselect文でもrollback
	# エラー文が出力されるので、全sqlでトランザクション宣言を行う。
	$teng->txn_begin;
	my $itr = $teng->search_by_sql(
		# 第一引数に発行したい生SQL
		# 第二引数にbindさせる値のarrayref
		# 第三引数に結果をどのテーブルをベースにrowオブジェクトにするかの指定
		q{
			SELECT
				client_id,
				client_secret,
				refresh_token
			FROM
				`gaauth`
			WHERE
				user_id = ?
		},
		[$user_id],
		'gaauth'
	);
	$teng->txn_commit;
	# print Dumper $itr;
	my @rows;
	while (my $row = $itr->next) {
		# $row->カラム名 を指定してselectしたカラムの情報を取得する
		push(@rows, $row->client_id);
		push(@rows, $row->client_secret);
		push(@rows, $row->refresh_token);
	}
	# print Dumper @rows;
	return @rows;
}

sub getgaviewid {
	my ($self, $user_id, $id) = @_;

	my $teng = Kaiseki::DB::connDB->new;
	# DBIのAutoCommit = 0 にするとselect文でもrollback
	# エラー文が出力されるので、全sqlでトランザクション宣言を行う。
	$teng->txn_begin;
	my $itr = $teng->search_named(
		# 第一引数に発行したい生SQL
		# 第二引数にバインド値のhashref
		# 第三引数では、第一引数で書いたSQLをsprintfで置き換え（あんまり使わない)
		# 第四引数に結果をどのテーブルをベースにrowオブジェクトにするかの指定
		q{
			SELECT
				view_id
			FROM
				`gaviewid`
			WHERE
				user_id = :user_id
				AND id = :id
		},
		{
			user_id => $user_id,
			id => $id,
		},
		[],
		'gaviewid'
	);
	$teng->txn_commit;
	# print Dumper $itr;
	my @rows;
	while (my $row = $itr->next) {
		# $row->カラム名 を指定してselectしたカラムの情報を取得する
		push(@rows, $row->view_id);
	}
	# print Dumper @rows;
	return @rows;
}

sub getCustomerinfo {
	my ($self, $user_id) = @_;

	my $teng = Kaiseki::DB::connDB->new;
	# DBIのAutoCommit = 0 にするとselect文でもrollback
	# エラー文が出力されるので、全sqlでトランザクション宣言を行う。
	$teng->txn_begin;
	my $itr = $teng->search_named(
		# 第一引数に発行したい生SQL
		# 第二引数にバインド値のhashref
		# 第三引数では、第一引数で書いたSQLをsprintfで置き換え（あんまり使わない)
		# 第四引数に結果をどのテーブルをベースにrowオブジェクトにするかの指定
		q{
			SELECT
				email,
				password
			FROM
				`customer`
			WHERE
				user_id = :user_id
		},
		{
			user_id => $user_id,
		},
		[],
		'customer'
	);
	$teng->txn_commit;
	# print Dumper $itr;
	my @rows;
	while (my $row = $itr->next) {
		# $row->カラム名 を指定してselectしたカラムの情報を取得する
		push(@rows, $row->email);
		push(@rows, $row->password);
	}
	# print Dumper @rows;
	return @rows;
}

sub get_ga_graph {
	# グラフテンプレートへ理想値と現実値を挿入し、差を計算する
	my ($self,
		$analytics,
		$view_id,
		$filter_param,
		$start_date,
		$end_date,
		$metrics,
		$homedir,
		$elements_for_graph ) = @_;

	foreach my $filtering_sign ("<=0", ">0") {
		my $filter = $filter_param . $filtering_sign;
		print "\$filtering_parameter is: " . $filter,"\n";
		my $req = $analytics->new_request(
			ids					=> "ga:$view_id",
			metrics			=> "$metrics",
			start_date	=> "$start_date",
			end_date		=> "$end_date",
			filters			=> "$filter",
			dimensions  => "ga:date"
		);
		my $res = $analytics->retrieve($req);
		die("Error: " . $res->error_message) if !$res->is_success;
		# 取得内容確認し、返却数が1以上ならテンプレートの書き換えを行う
		# print Dumper \$res;
		if ($res->total_results >= 1) {
			foreach my $row_ref ($res->{rows}) {
				# 理想値、現実値を判別してテンプレートに値を挿入する
				foreach my $day (@{$row_ref}) {
					if ($filter_param =~ />/) {
						$elements_for_graph->{$day->[0]}->{good} = $day->[1];
					}
					else {
						$elements_for_graph->{$day->[0]}->{bad} = $day->[1];
					}
					# diff値を計算する（ここに入れていいか？）
					$elements_for_graph->{$day->[0]}->{diff} = $elements_for_graph->{$day->[0]}->{bad} - $elements_for_graph->{$day->[0]}->{good};
				}
			}
		}
	}
	# print Dumper \%elements_for_graph,"\n";

	return $elements_for_graph;
}

sub get_ga_graph_template {
	# 開始日、終了日からグラフの材料になるハッシュの配列リファレンスを返す
	use Calendar;
	use Calendar::Japanese::Holiday;
	my ($self, $start_date, $end_date) = @_;

	# 開始、終了期間の日数を出す
	foreach my $date ($start_date, $end_date) {
		my ($year, $month, $day) = split('-', $date);
		$date = Calendar->new_from_Gregorian(-year=>$year, -month=>$month, -day=>$day);
	}
	my $days = $end_date - $start_date;	

	my $hash_days = {};
	my %days_common = (
		good	=> 0,
		bad		=> 0,
		diff 	=> 0,
	);
	my $days_common = \%days_common;
	while ($days >= 0) {
		my ($month, $day, $year) = split('/', $start_date);

		# 土日祝日判定(Calendarモジュールはweekdayが 1~5 だと平日)
		my $date = Calendar->new_from_Gregorian(-year=>$year, -month=>$month, -day=>$day);
		my $week = $date->weekday;
		my $holiday_flg = isHoliday($date->year, $date->month, $date->day, 1); # 1が付いてると振替休日判定追加
		# print $holiday_flg;
		$date = $year . $month . $day;
		if ($week =~ m/(0|6)/ or $holiday_flg) {
			$hash_days->{$date} = {
				%$days_common,
				is_holiday => 'yes',
			};
		}
		else {
			$hash_days->{$date} = {
				%$days_common,
				is_holiday => 'no',
			};
		}
		$days--;
		$start_date++;
	}
	return $hash_days;
}


__PACKAGE__->meta->make_immutable();