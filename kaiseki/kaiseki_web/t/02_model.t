#!/usr/bin/env perl
# Modelロジックのテストを行うためのスクリプト
use strict;
use warnings;
use Data::Dumper;
use JSON;
# use utf8;
# use LWP::Simple;
# use URI;
# use Storable;
# use Storable qw(nstore);
# Modelを読み込むためのライブラリのパスの設定
use FindBin;
use lib "$FindBin::Bin/../lib";
# Modelの利用
use Kaiseki::Model::Kaiseki;
use feature 'say';
use Storable;
use Storable qw(nstore);

# 以下にテストロジックを書く
my $kaiseki = Kaiseki::Model::Kaiseki->new;

my @rows = $kaiseki->getCustomerinfo(1);

my $src = $kaiseki->scrapeGadata($rows[0], $rows[1]);

print $src;
