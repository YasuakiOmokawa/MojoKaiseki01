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
  '20121205' => {
      'bad' => 1,
      'diff' => 2,
      'good' => 0,
      'is_holiday' => 'no'
  },
  '20121206' => {
      'bad' => 3,
      'diff' => 0,
      'good' => 5,
      'is_holiday' => 'no'
  },
  '20121207' => {
      'bad' => 9,
      'diff' => 0,
      'good' => 0,
      'is_holiday' => 'no'
  },
};

foreach my $ref ($res->{rows_date}) {
  foreach my $elem (@{$ref}) {
    print "date is " . $elem->[0] . ", good is " . $elem->[1],"\n";
    # if ($elem->{date} eq $res->{rows_date})
  }
}

foreach my $day (keys $plot_graph) {
	print "date is " . $day . ", good is " . $plot_graph->{$day}->{good},"\n";
	# if ($elem->{date} eq $res->{rows_date})
}

