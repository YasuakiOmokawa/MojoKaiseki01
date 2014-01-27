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

sub scrapeGadata {
	my ($self, $email, $pass) = @_;

	my $d = Kaiseki::Scrape::useScrape->new;
	# google analytics ログインの実施
	$d->get('https://accounts.google.com/ServiceLogin?service=analytics&passive=true&nui=1&hl=ja&continue=https%3A%2F%2Fwww.google.com%2Fanalytics%2Fweb%2F%3Fhl%3Dja&followup=https%3A%2F%2Fwww.google.com%2Fanalytics%2Fweb%2F%3Fhl%3Dja');
	$d->find_element('//input[@id="Email"]')->send_keys($email);
	$d->find_element('//input[@id="Passwd"]')->send_keys($pass);
	$d->find_element('//input[@id="signIn"]')->click();

	# 「すべてのウェブサイトのデータ」リンクをクリック
	$d->find_element('//*[@id="9-row-a36581569w64727418p66473324"]/td[2]/div/div/a')->click();
	wait_for_page_to_load($d,10000);


	$d->find_element('//*[@id="ID-reportHeader-reportToolbar"]/div[1]/span[2]')->click();
	wait_for_page_to_load($d,10000);

	# スクリーンショットの取得
	require MIME::Base64;
	open(FH,'>','screenshot.png');
	binmode FH;
	my $png_base64 = $d->screenshot();
	print FH MIME::Base64::decode_base64($png_base64);
	close FH;

	return $d->get_page_source()."\n";

	$d->quit();

	sub wait_for_page_to_load { 
		my ($driver, $timeout) = @_; 
		my $ret = 0; 
		my $sleeptime = 2000; # milliseconds 

		$timeout = (defined $timeout) ? $timeout : 30000 ;
		do { 
			sleep ($sleeptime/1000); # Sleep for the given sleeptime 
			$timeout = $timeout - $sleeptime;
		} while (($driver->execute_script("return document.readyState") ne 'complete') && ($timeout > 0));
		if ($driver->execute_script("return document.readyState") eq 'complete') { 
			$ret = 1;
		}
		return $ret;
	}

}

__PACKAGE__->meta->make_immutable();