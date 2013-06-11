#!/usr/bin/env perl
$|=1;
use strict;
use Config::IniFiles;
use File::Basename;
use Image::utils;
use CORE::core qw(get_all_images);
use CGI ;
my $cgi=new CGI;
my $image=$cgi->param("image");

my $cfg_confocal = Config::IniFiles->new( -file => $ENV{CONFOCAL_INI});
my $tmp=$cfg_confocal->val( 'FILES', 'tmp' );
my $tmpWEB=$cfg_confocal->val( 'WEB', 'tmp' );
print "Content-type: text/text \n\n";



my $JSON="";

if($image eq '')
{
	my $file_micro_conf=$cfg_confocal->val( 'INI', $cgi->param("conf") );
	my $cfg_micro=Config::IniFiles->new( -file => $file_micro_conf);
	my $MatrixScreenerImagesDir=$cfg_micro->val('FILES','MatrixScreenerImages');
	my $host=$cfg_micro->val('HOST','ip');
	my $file;
	my $dirImagenes=$cgi->param("dir");
	my @all_slide_and_chamber=get_all_images(-file=>\$file,-dirImagenes=>$dirImagenes,-MatrixScreenerImagesDir=>$MatrixScreenerImagesDir,-host=>$host);
	$image=$all_slide_and_chamber[0];
	
	foreach my $image (sort @all_slide_and_chamber)
	{
		$JSON.=",{'name':'".basename($image)."','image':'$image'}";
	}
	$JSON=~s/^,//;	
}

my $imageUtils=Image::utils->new;
$imageUtils->convert(-to=>"png",-file=>$image);

$image =~s/tif/png/;
# $image=quotemeta($image);
my $nameFileOutput = "lowResolution".int(1+rand(100000000000)).".png";
system("cp $image ../$tmpWEB/$nameFileOutput");

if($JSON eq '')
{
	print "[{'def':'$tmpWEB/$nameFileOutput','images':[]}]";
}
else
{
	print "[{'def':'$tmpWEB/$nameFileOutput','images':[$JSON]}]";
}













