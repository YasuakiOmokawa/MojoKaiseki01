#!/usr/bin/env perl

# selenium remote driver + PhantomJS を使ったスクレイピングのサンプル
# 2013/1/22 ファイルダウンロード一歩手前まで復旧

use strict;
use warnings;
use utf8;
use Selenium::Remote::Driver;
use Test::TCP;
use IPC::Cmd;
# use Test::More tests => 1;

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

# google analytics ログインの実施
$d->get('https://accounts.google.com/ServiceLogin?service=analytics&passive=true&nui=1&hl=ja&continue=https%3A%2F%2Fwww.google.com%2Fanalytics%2Fweb%2F%3Fhl%3Dja&followup=https%3A%2F%2Fwww.google.com%2Fanalytics%2Fweb%2F%3Fhl%3Dja');
my $email = '';
my $pass = '';
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

print $d->get_page_source()."\n";

$d->quit();

undef $phamtomjs_server;

sub wait_for_page_to_load { 
	my ($driver,$timeout) = @_; 
	my $ret = 0; 
	my $sleeptime = 1000; # milliseconds 

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
