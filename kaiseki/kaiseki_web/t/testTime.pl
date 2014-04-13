#!/usr/bin/env perl

use strict;
use warnings;
use Date::Calc qw(:all);

my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);  
my $start_date = sprintf("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);
my $end_date = sprintf("%04d-%02d-%02d", $year + 1900, $mon + 2, $mday);

Add_Delta_YM($year, $mon, $mday, 0, +1);
$start_date = sprintf("%04d-%02d-%02d", $year, $mon, $mday);


print $start_date,"\n";
print $end_date,"\n";
