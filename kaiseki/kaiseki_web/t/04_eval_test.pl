#!/usr/bin/env perl
# Modelロジックのテストを行うためのスクリプト
use strict;
use warnings;
use Data::Dumper;
# evalにBLOCKを指定するサンプル

my $old = 'old.txt';
my $new = 'new.txt';

my ($client_id, $secret);
eval {
    ($client_id, $secret) = 'hello';
    # rename $old, $new or die "rename($old, $new): $!";
};
print $client_id,"\n";
if ($@) {
    # エラー時に実行する処理
    print "Error!\n";
    print $@;
    exit 1;
}
exit 0;


