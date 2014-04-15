#!/usr/bin/env perl

use strict;
use warnings;

my $goal = "ga:goal20Value";
$goal =~ s/[^\d+]//g;

print $goal,"\n";