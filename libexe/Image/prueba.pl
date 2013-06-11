#!/usr/bin/env perl
use Image::utils;


my $tmp='/tmp/rotate_tmp.tif';
my $p=Image::utils->new(-file=>$ARGV[0]);
$p->rotate();
$p->write(-file=>$tmp);

# 
my $p=Image::utils->new(-file=>$tmp);
my @angles=$p->get_angles();
print "\n".$angles[0].",".$angles[1]."\n\n";


unlink $tmp;