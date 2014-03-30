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

my $plot_graph = {
  'days' => [
    {
      'day' => '20121205',
      'bad' => 0,
      'diff' => 0,
      'good' => 0,
      'is_holiday' => 'no'
    },
    {
      'bad' => 0,
      'day' => '20121206',
      'diff' => 0,
      'good' => 0,
      'is_holiday' => 'no'
    },
    {
      'bad' => 0,
      'day' => '20121207',
      'diff' => 0,
      'good' => 0,
      'is_holiday' => 'no'
    }
  ]
};

foreach my $row_ref ($plot_graph->{days}) {
	foreach my $elem (@{$row_ref}) {
		# print "date is " . $elem->{day} . ", good is " . $elem->{good},"\n";
		if ($elem->{date} eq $res->{rows_date})
	}
}

