#!/usr/bin/env perl

use strict;
use warnings;

my $res = {
	'rows_date' => [
		['20121205', '1'],
		['20121206', '2'],
	],
	'total_row' => 2,
};

foreach my $row_ref ($res->{rows_date}) {
	my $rows = @{$row_ref};
	my $index = 0;
	while ($index < $rows) {
		print "date is " . $row_ref->[$index]->[0] . ", value is " . $row_ref->[$index]->[1],"\n";
		$index++;
	}
}

