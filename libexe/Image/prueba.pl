#!/usr/bin/env perl
use Image::utils;


# my $tmp='/Users/acarro/Sites/Confocal/tmp/prueba_rot.tif';
# my $p=Image::utils->new(-file=>$tmp);
# $p->rotate();
# $p->rotate();
# $p->write(-file=>$tmp);

# 
my $p=Image::utils->new(-file=>$tmp);
my @angles=$p->get_angles();
print "\n".$angles[0].",".$angles[1]."\n\n";


unlink $tmp;