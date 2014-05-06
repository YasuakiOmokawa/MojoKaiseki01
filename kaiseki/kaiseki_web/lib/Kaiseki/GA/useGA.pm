package Kaiseki::GA::useGA;

use utf8;
use Net::Google::Analytics;
use Net::Google::Analytics::OAuth2;
use Data::Dumper;
use Log::Minimal;

# debug is ok? 1 is ok.
$ENV{LM_DEBUG} = 1;
$Log::Minimal::TRACE_LEVEL = 1;

sub new {	

	# googleAnalyticsGetV1.pl を使って取得したRefresh token 
	# を使ってデータを取りだす　←　これ自動でやりたい。。。

	########## リクエストパラメータの取得  #############
	# Google Analytics のプロファイルはビューに名称変更された。
	my ($self,
		$client_id,
		$client_secret,
		$refresh_token
	) = @_;
	######################################


	# Google Analytics APIの認証
	debugf("start googleAnalytics api authent");
	eval {
		my $analytics = Net::Google::Analytics->new;
		my $oauth = Net::Google::Analytics::OAuth2->new(
			client_id => $client_id,
			client_secret => $client_secret,
			redirect_uri => 'http://localhost/oauth2callback',
		);
		my $token = $oauth->refresh_access_token($refresh_token);
		$analytics->token($token);
		print Dumper $analytics;
		return $analytics;
	};

	if($@) {
		warnf("googleAnalytics api authent failed. $@");
		exit(255);
	}

}

1;