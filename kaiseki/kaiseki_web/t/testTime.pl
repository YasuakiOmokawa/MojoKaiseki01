#!/usr/bin/env perl

use strict;
use warnings;

use Time::Piece;
use Time::Seconds;

# Time::Pieceオブジェクトの取得
print "Time::Piece ",$Time::Piece::VERSION,"\n";
my $t;
# $t = "2014-01-29"; # 入力パラメータとかで渡ってきたとする。
if ($t) {
    $t = localtime( Time::Piece->strptime($t, '%Y-%m-%d') );
}
else {
    $t = localtime; # 渡ってこなければ現在時刻
}
# 日付や時刻の情報の表示
print $t->ymd,"\n";
# $t += ONE_MONTH; # 一ヶ月後
$t = $t->add_months(1);
print $t->ymd,"\n";

