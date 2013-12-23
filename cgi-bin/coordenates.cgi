#!/usr/bin/env perl
$|=1;
use strict;
use Config::IniFiles;
# use ImageJ::ImageJ;
use Image::utils;

use CGI ;
my $cgi=new CGI;

my $cfg_confocal = Config::IniFiles->new( -file => $ENV{CONFOCAL_INI});
my $tmp=$cfg_confocal->val( 'FILES', 'tmp' );
my $tmpWEB=$cfg_confocal->val( 'WEB', 'tmp' );
my $name=$cgi->param("conf");
my $conf=$cfg_confocal->val( 'INI',  $name);
my $cfg = Config::IniFiles->new( -file => $conf );
my $dirImages=$cfg->val( 'FILES', 'MatrixScreenerImages' );


my $rotate=$cgi->param("rotate");

my $file=$cgi->param("image");
my $dir=$cgi->param("dir");
print "Content-type: text/text \n\n";
# my $image=$cfg->val( 'FILES', 'NameImageFileStep1' );

# aqui esta el kit de la kuestion
my ($permisos,$id,$user,$group,$sizem,$day,$mounth,$year);
if($dir eq "")
{
	my @dir=split(/\n/,`ls -ltr $dirImages`);
	($permisos,$id,$user,$group,$sizem,$day,$mounth,$year,$dir)=split(/\s+/,$dir[$#dir]);
}

my $image;
my $imgpng;
my $format='png';
if($file=~/(.*)\.tif/)
{
	$image=$dirImages."/".$dir."/".$1."_control.tif";
	$imgpng=$dirImages."/".$dir."/".$1."_control.png";
}
if(!-e $imgpng)
{
	my $result="";
	print STDERR $image;
	my $imageUtils=Image::utils->new(-file=>$image);
	$imageUtils->resize(-width=>600);

	$imageUtils->write(-format=>$format,-file=>$image);
	# $image =~s/tif/$format/;
}

my $nameFileOutput = "lowResolutionImageJ".int(1+rand(100000000000)).'.'.$format;
system("ln -s $imgpng $tmp/$nameFileOutput");
# system("cp $image $tmp/$nameFileOutput");
# if(-e $image)
# {
# 	unlink  $image;
# }
print $tmpWEB."/$nameFileOutput";



