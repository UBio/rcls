#!/usr/bin/env perl
$|=1;
use strict;
use Config::IniFiles;

use CGI ;
my $cgi=new CGI;

my $cfg_confocal = Config::IniFiles->new( -file => $ENV{CONFOCAL_INI});
my $name=$cgi->param("conf");
my $conf=$cfg_confocal->val( 'INI',  $name);

my $cfg = Config::IniFiles->new( -file => $conf );
my $dirImages=$cfg->val( 'FILES', 'MatrixScreenerImages' );

print "Content-type: text/text \n\n";
my $dir=$cgi->param("dir");

my ($permisos,$id,$user,$group,$sizem,$day,$mounth,$year,$file);
if($dir eq "")
{
	my @dir=split(/\n/,`ls -ltr $dirImages`);
	($permisos,$id,$user,$group,$sizem,$day,$mounth,$year,$file)=split(/\s+/,$dir[$#dir]);
}
else
{
	$file=$dir;
}
my $Path_to_image=$dirImages."/".$file;
print STDERR $Path_to_image."\n";
opendir(DIR,$Path_to_image);
my $imagen_json="";
while( (my $imagen = readdir(DIR)))
{
	if($imagen =~ /\.tif$/)
	{
		if($imagen_json eq "")
		{
			$imagen_json="{'name':'".$imagen."','path':'".$Path_to_image."'}";
		}
		else
		{
			$imagen_json.=",{'name':'".$imagen."','path':'".$Path_to_image."'}";
		}
	}
}
close DIR;


print "[".$imagen_json."]";