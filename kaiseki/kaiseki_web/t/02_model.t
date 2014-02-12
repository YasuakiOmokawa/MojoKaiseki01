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

# 以下にテストロジックを書く
my $self = shift;
my $kaiseki = Kaiseki::Model::Kaiseki->new;
my $kaiseki_scrape = Kaiseki::Model::KaisekiForScrape->new;


my $homedir = "$FindBin::Bin/..";
my $filedir = $homedir . "/public/datas";
my $file = $filedir . "/" . "all_metrics.txt";
$kaiseki_scrape->createTemplate($filedir);


my @rows = $kaiseki->getCustomerinfo(1);
# Mojo::IOLoop->timer(3 => sub { say 'Reactor tick.' });
Mojo::IOLoop->timer(2 => sub { 
		$kaiseki_scrape->scrapeGadata($rows[0], $rows[1], $file);
	}
);

say 'レンダリング開始やで';
# Mojo::IOLoop->start;


