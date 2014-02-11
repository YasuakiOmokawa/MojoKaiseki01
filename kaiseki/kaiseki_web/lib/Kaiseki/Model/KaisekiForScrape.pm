package Kaiseki::Model::KaisekiForScrape;

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

sub scrapeGadata {
	use Web::Scraper;

	my ($self, $email, $pass, $file) = @_;

	my $d = Kaiseki::Scrape::useScrape->new;
	# google analytics ログインの実施
	$d->get('https://accounts.google.com/ServiceLogin?service=analytics&passive=true&nui=1&hl=ja&continue=https%3A%2F%2Fwww.google.com%2Fanalytics%2Fweb%2F%3Fhl%3Dja&followup=https%3A%2F%2Fwww.google.com%2Fanalytics%2Fweb%2F%3Fhl%3Dja');
	$d->find_element('//input[@id="Email"]')->send_keys($email);
	$d->find_element('//input[@id="Passwd"]')->send_keys($pass);
	$d->find_element('//input[@id="signIn"]')->click();

	# 「すべてのウェブサイトのデータ」リンクをクリック
	$d->find_element('//*[@id="9-row-a36581569w64727418p66473324"]/td[2]/div/div/a')->click();
	wait_for_page_to_load($d,10000);

	# 期間選択
	$d->find_element('//*[@id="ID-reportHeader-dateControl"]/div[1]/table/tbody/tr/td[2]')->click();
	$d->find_element('//*[@id="ID-reportHeader-dateControl"]/div[2]/table/tbody/tr/td[2]/div/div[2]/input[1]')->clear();
	$d->find_element('//*[@id="ID-reportHeader-dateControl"]/div[2]/table/tbody/tr/td[2]/div/div[2]/input[1]')->send_keys('2012/10/01');
	$d->find_element('//*[@id="ID-reportHeader-dateControl"]/div[2]/table/tbody/tr/td[2]/div/div[2]/input[1]')->clear();
	$d->find_element('//*[@id="ID-reportHeader-dateControl"]/div[2]/table/tbody/tr/td[2]/div/div[2]/input[2]')->send_keys('2013/04/30');
	$d->find_element('//*[@id="ID-reportHeader-dateControl"]/div[2]/table/tbody/tr/td[2]/div/input')->click();
	wait_for_page_to_load($d,10000);

	# 以下、データ取得

	my $src;

	# 全体指標
	$d->find_element('//*[@id="ID-overview-dimensionSummary-miniTable"]/div/div')->click();
	wait_for_page_to_load($d,10000);

# //*[@id="ID-rowTable"]/thead/tr[4]/td[3]/div[1]/div/div
# //*[@id="ID-rowTable"]/thead/tr[4]/td[2]/div[1]/div/div

	my $scraper = scraper {
		# process '', 'PV数' => 'TEXT';
		process '//*[@id="ID-rowTable"]/thead/tr[4]/td[3]/div[1]/div/div', '訪問数' => 'TEXT';
		process '//*[@id="ID-rowTable"]/thead/tr[4]/td[7]/div[1]/div/div', '平均PV数' => 'TEXT';
		process '//*[@id="ID-rowTable"]/thead/tr[4]/td[8]/div[1]/div/div', '平均滞在時間' => 'TEXT';
		process '//*[@id="ID-rowTable"]/thead/tr[4]/td[5]/div[1]/div/p[2]', '新規訪問率' => 'TEXT';
		# process '', 'リピート訪問率' => 'TEXT';
		# process '', 'リピート回数' => 'TEXT';
		# process '', 'リピート間隔' => 'TEXT';
		process '//*[@id="ID-rowTable"]/thead/tr[4]/td[6]/div[1]/div/div', '直帰率' => 'TEXT';
		# process '', 'CV数' => 'TEXT';
		# process '', 'CVR' => 'TEXT';
		# process '', 'CV期間' => 'TEXT';
	};


	# 理想値
	print "理想値を表示します\n";
	$d->find_element('//*[@id="ID-explorer-table-tableControl"]/div/div[1]/ul/li[2]/div')->click();
	$d->find_element('//*[@id="ID-explorer-table-tableControl"]/div/div[2]/div[1]/div[1]/div[1]/div[1]/div/div/div[2]/div')->click();
	$d->find_element('//*[@id="ID-explorer-table-tableControl"]/div/div[2]/div[1]/div[1]/div[2]/div/div[1]/div[4]/div[1]')->click();
	$d->find_element('//*[@id="ID-explorer-table-tableControl"]/div/div[2]/div[1]/div[1]/div[2]/div/div[1]/div[4]/div[2]/div[1]/div[1]')->click();
	$d->find_element('//*[@id="ID-explorer-table-tableControl"]/div/div[2]/div[1]/div[1]/div[1]/div[1]/div/div/div[4]/input')->send_keys(0);
	$d->find_element('//*[@id="ID-explorer-table-tableControl"]/div/div[2]/div[2]/span[1]')->click();
	wait_for_page_to_load($d,10000);

	$src = $scraper->scrape($d->get_page_source);
	saveToFile($file, $src);

	# 現実値
	$d->find_element('//*[@id="ID-explorer-table-tableControl"]/div/div[1]/ul/li[2]/div')->click();
	$d->find_element('//*[@id="ID-explorer-table-tableControl"]/div/div[2]/div[1]/div[1]/div[1]/div[1]/div/div/div[3]/div')->click();
	$d->find_element('//*[@id="ID-explorer-table-tableControl"]/div/div[2]/div[1]/div[4]/div[1]')->click();
	$d->find_element('//*[@id="ID-explorer-table-tableControl"]/div/div[2]/div[2]/span[1]')->click();
	wait_for_page_to_load($d,10000);

	$src = $scraper->scrape($d->get_page_source);
	saveToFile($file, $src);
	# print Dumper $scraper->scrape($d->get_page_source);
	# $d->find_element('')->click();
	# wait_for_page_to_load($d,3);
	# $d->find_element('')->click();
	# wait_for_page_to_load($d,3);
	# $d->find_element('')->click();
	# wait_for_page_to_load($d,3);
	# $d->find_element('')->click();
	# wait_for_page_to_load($d,3);

	# スクリーンショットの取得
	require MIME::Base64;
	open(FH,'>','screenshot.png');
	binmode FH;
	my $png_base64 = $d->screenshot();
	print FH MIME::Base64::decode_base64($png_base64);
	close FH;

	# return $d->get_page_source()."\n";

	$d->quit();

	sub wait_for_page_to_load { 
		my ($driver, $timeout) = @_; 
		my $ret = 0; 
		my $sleeptime = 1000; # milisecond

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

	sub saveToFile {
		my ($file, $hashref) = @_;
		# -e $file and unlink $file;
		while (my ($key, $val) = (each %$hashref)) {
		# my @data;
		# for my $str (keys $hash) {
			# $str = join("\t", @$str);
			# $str = $str . "\n";
			# push @data, $str;
			open( my $fh, '>>', $file) or die qq(can not open "$file" : $!);
			# open( my $fh, "$addmode", $file) or die qq(can not open "$file" : $!);
			eval { flock($fh, 2); };
			# print "$key and $val\n";
			print $fh $key . "\t" . $val . "\n";
			close $fh;
			# print "saved_1line: $str\n";
		}
	}

}




__PACKAGE__->meta->make_immutable();