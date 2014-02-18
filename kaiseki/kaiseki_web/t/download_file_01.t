use strict;
use File::Basename;
 
my $filepath = "c:\\okinawa.csv";
my $file = basename($filepath);
my $filesize = -s $filepath;
 
open(F,$filepath) || die "Can't open $filepath";
 
print "Content-type: application/octet-stream; name=\"$file\"\n";
print "Content-Length: $filesize\n";
print "Expires: 0\n";
print "Cache-Control: must-revalidate, post-check=0,pre-check=0\n";
print "Pragma: private\n";
print "Content-Disposition: attachment; filename=\"$file\"\n";
print "\n";
 
binmode(F);
binmode(STDOUT);
while(<F>) {print;}
close(F);
exit;