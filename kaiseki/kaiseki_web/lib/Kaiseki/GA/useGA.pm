package Kaiseki::GA::useGA;

use utf8;
use Net::Google::Analytics;
use Net::Google::Analytics::OAuth2;
use Carp qw(croak);
use Data::Dumper;
# use Carp qw(verbose); # 完全なスタックトレースを実施したい場合はコメントアウトを外してください

sub new {	
	########## リクエストパラメータの取得  #############
	# Google Analytics のプロファイルはビューに名称変更された。
	my ($self,
		$client_id,
		$client_secret,
		$refresh_token
	) = @_;
	######################################

	# Google Analytics APIの認証
	my $analytics;
	eval{
		$analytics = Net::Google::Analytics->new;
		my $oauth = Net::Google::Analytics::OAuth2->new(
			client_id => $client_id,
			client_secret => $client_secret,
			redirect_uri => 'http://localhost/oauth2callback',
		);
		my $token = $oauth->refresh_access_token($refresh_token);
		$analytics->token($token);
	};
  croak("Authentication googleAnalytics API failed: $@") if ($@);
	return $analytics;

	# ▼$analytics変数がapi認証に成功したかどうかを試すコード

	# # 取り出したいパラメータを指定
	# my $req = $analytics->new_request(
	# 	ids			=> "ga:79080027",
	# 	metrics		=> "ga:pageValue",
	# 	start_date	=> "2014-04-26",
	# 	end_date	=> "2014-04-27"
	# );
	# my $res = $analytics->retrieve($req);
	# die("Error: \$metricses is $metricses" . "\n" . $res->error_message) if !$res->is_success;
	# # 取得内容確認
	# print 'responce object below',"\n";
	# print Dumper $res;
}

1;