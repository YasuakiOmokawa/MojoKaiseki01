package Kaiseki::Scrape::useScrape;

# selenium remote driver + PhantomJS を使ったスクレイピングのサンプル

use strict;
use warnings;
use utf8;
use Selenium::Remote::Driver;
use Test::TCP;
use IPC::Cmd;
# use Test::More tests => 1;

sub new {	
	my $ua = $ARGV[0] || "my original user_agent";

	my $phamtomjs_server = Test::TCP->new(
	    code => sub {
	        my $port = shift;
	        #phantomjsのログがうざいので、IPC::Cmd::runで封じ込め
	        IPC::Cmd::run( command => ['phantomjs', '--ignore-ssl-errors', 'true', '--webdriver', $port], verbose => 0, buffer  => \my $buffer);
	    },
	);

	my $d = Selenium::Remote::Driver->new(
	    remote_server_addr => '127.0.0.1',
	    port => $phamtomjs_server->port,
	    extra_capabilities  => +{"phantomjs.page.settings.userAgent" => $ua },
	    browser_name => 'phantomjs',
	);
	return $d;
}

1;