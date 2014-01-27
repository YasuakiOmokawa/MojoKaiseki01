package Kaiseki::GA::useGA;

use utf8;
use Net::Google::Analytics;
use Net::Google::Analytics::OAuth2;
use Data::Dumper;

sub new {	

	# googleAnalyticsGetV1.pl を使って取得したRefresh token 
	# を使ってデータを取りだす

	########## リクエストパラメータの取得  #############
	# Google Analytics のプロファイルはビューに名称変更された。
	my ($self,
		$client_id,
		$client_secret,
		$refresh_token,
		$view_id,
		$param_filter,
		$start_date,
		$end_date,
		@metricses) = @_;
	######################################


	# リクエストパラメータ用に加工
	my $metricses = join(',', @metricses);

	# Google Analytics APIの認証
	my $analytics = Net::Google::Analytics->new;
	my $oauth = Net::Google::Analytics::OAuth2->new(
		client_id => $client_id,
		client_secret => $client_secret,
		redirect_uri => 'http://localhost/oauth2callback',
	);
	my $token = $oauth->refresh_access_token($refresh_token);
	$analytics->token($token);

	# 取り出したいパラメータを指定
	my $req = $analytics->new_request(
		ids			=> "ga:$view_id",
		metrics		=> "$metricses",
		start_date	=> "$start_date",
		end_date	=> "$end_date",
		filters		=> "$param_filter"
		# dimensions  => "ga:goalCompletionLocation",
	);
	my $res = $analytics->retrieve($req);
	die("Error: \$metricses is $metricses" . "\n" . $res->error_message) if !$res->is_success;
	# 取得内容確認
	# print Dumper $res;
	return $res;
}

1;