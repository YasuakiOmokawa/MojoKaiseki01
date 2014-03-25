#!/usr/bin/env perl

use strict;
use warnings;
use Calendar::Japanese::Holiday;

use Encode;

use Data::Dumper;



my $holidays = encode('utf8', getHolidays(2012, 10, 1));
#my $holidays = getHolidays(2012, 10, 1);



print Dumper $holidays,"\n";


