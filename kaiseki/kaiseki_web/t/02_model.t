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
my $file = $filedir . "/" . "tbl_all_metrics.html";
# $kaiseki_scrape->createTemplate($file);


my @rows = $kaiseki->getCustomerinfo(1);
# Mojo::IOLoop->timer(3 => sub { say 'Reactor tick.' });
Mojo::IOLoop->timer(2 => sub { 
		$kaiseki_scrape->scrapeGadata($rows[0], $rows[1], $file);
	}
);

say 'レンダリング開始やで';
Mojo::IOLoop->start;


# my $html = '<tr><td class="ok-value">0</td><td class="metrics">PV数</td><td class="bad-value">0</td><td class="diff-value">0</td></tr>';
# my $text = 'PV数';
# my $value;
# my $flg_value;
# my $calc;
# # my $searched = first { $_ =~ '検索' } $html;
# print '原文',"\n";
# print $html,"\n";
# # $searched =~ s|検索|置換|;
# $flg_value = 'ok';
# $value = '200';
# $calc = '-1';
# print 'ok_value変換',"\n";
# $html =~ s|(.*?<td class="${flg_value}_value">).*?(</td>(<td>$text</td>)?.*)|${1}$value${2}|;
# $html =~ s|(<td class="diff_value">).*?(</td>)|${1}$calc${2}|;
# print $html,"\n";
# $flg_value = 'bad';
# $value = '2';
# $calc = '-2';
# print 'bad_value変換',"\n";
# $html =~ s|(.*?<td class="${flg_value}_value">).*?(</td>(<td>$text</td>)?.*)|${1}$value${2}|;
# $html =~ s|(<td class="diff_value">).*?(</td>)|${1}$calc${2}|;
# print $html,"\n";
