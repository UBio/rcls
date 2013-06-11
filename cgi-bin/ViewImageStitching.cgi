#!/usr/bin/env perl
$|=1;
use strict;
use Config::IniFiles;
use Image::utils;


use CGI ;
my $cgi=new CGI;
my $image=$cgi->param("image");

my $cfg_confocal = Config::IniFiles->new( -file => $ENV{CONFOCAL_INI});

my $tmp=$cfg_confocal->val( 'FILES', 'tmp' );
my $tmpWEB=$cfg_confocal->val( 'WEB', 'tmp' );

print "Content-type: text/text \n\n";


my $imageUtils=Image::utils->new;
$imageUtils->convert(-to=>"png",-file=>$image,-channels=>$cgi->param("channels"));


$image =~s/tif/png/;


my $nameFileOutput = "stitching".int(1+rand(100000000000)).".png";

system("cp $image ../$tmpWEB/$nameFileOutput");
print $tmpWEB."/".$nameFileOutput;
