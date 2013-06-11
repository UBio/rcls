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


my $image=$dirImages."/".$dir."/".$file;
my $coordenates=$cfg_confocal->val( 'FILES', 'tmp')."/coordenates_$name";

if($file =~ /(.*)image--L0000--S(\d+)--U(\d+)--V00--J00--X00--Y00--T0000--Z00--C00.ome.tif/)
{
	$coordenates=$coordenates."--S".$2."--U".$3."\.txt";
}

open(COOR,"$coordenates") || die "no puedo abrir el fichero coordenates: $coordenates\n";

print STDERR $coordenates."\n";
my $head=<COOR>;
# $head=~s/^\s+//;
# my ($h1,$h2,$h3,$h4)=split(/\s+/,$head);
my $result="";
print STDERR $image;
my $imageUtils=Image::utils->new(-file=>$image);

if($rotate!=0)
{
	$imageUtils->rotate;
}

# if($h1 eq "BX" && $h2 eq "BY" && $h3 eq "Width" && $h4 eq "Height")
# {
	while(<COOR>)
	{
		chomp;
		my ($index,$x,$y,$w,$h)=split(/\s+/,$_);
		my $box=$x.",".$y." ".($x+$w).",".($y+$h);
		$imageUtils->box(-box=>$box,-label=>$index);
	}
	close COOR;
# }
$imageUtils->binary();
$imageUtils->resize(-width=>600);

my $format='png';

$imageUtils->write(-format=>$format,-file=>$image);


$image =~s/tif/$format/;

my $nameFileOutput = "lowResolutionImageJ".int(1+rand(100000000000)).'.'.$format;

system("cp $image $tmp/$nameFileOutput");
# if(-e $image)
# {
# 	unlink  $image;
# }
print $tmpWEB."/$nameFileOutput";



