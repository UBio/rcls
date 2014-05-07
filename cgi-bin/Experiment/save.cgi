#!/usr/bin/env perl
use strict;
use Config::IniFiles;


use CGI ;
use parameters;

my $cgi=new CGI;


my $cfg_confocal = Config::IniFiles->new( -file => $ENV{CONFOCAL_INI});
my @micros=$cfg_confocal->Parameters ('INI');


my $paramObj=new parameters();

my $exp=$cgi->param("exp");
my $micro=$cgi->param("micro");
my $lowTemplate=$cgi->param("lowTemplate");

my $det_routine_name=$cgi->param("det_routine_name");
my $det_template=$cgi->param("det_template");

my @threshold=split(",",$cgi->param("threshold"));
my @size=split(",",$cgi->param("size"));
my $circularity=$cgi->param("circularity");
# my $correction=$cgi->param("correction");
my $correction='';
my $rm_blacks=$cgi->param("rm_blacks");
my $rm_blacks_template=$cgi->param("rm_blacks_template");

my $highAll=$cgi->param("highAll");
my $stitch_routine_name=$cgi->param("stitch_routine_name");
my $stitch_cod_color=$cgi->param("stitch_cod_color");
my $name_file=$cgi->param("name_file");


$paramObj->set_microscope(-name=>$micro,-experiment=>$exp);
$paramObj->set_low(-template=>$lowTemplate);
$paramObj->set_detection(-routine_name=>$det_routine_name,
                          -template=>$det_template,
                          -correction=>$correction,
                          -threshold_min=>$threshold[0],
                          -threshold_max=>$threshold[1],
                          -size_min=>$size[0],
                          -size_max=>$size[1],
                          -circularity=>$circularity,
                          -rm_blacks=>$rm_blacks,
                          -rm_blacks_template=>$rm_blacks_template);
$paramObj->set_high(-all=>$highAll);
$paramObj->set_stitching(-code_color=>$stitch_cod_color,-routine_name=>$stitch_routine_name);

if($name_file eq '')
{
  $name_file=$micro."_".$exp.".xml";
}
else
{
  if($name_file !~ /\.xml$/)
  {
      $name_file=$name_file.".xml";
  }
}

print "Content-type: application/ms-excel\n";

print "Content-disposition: attachment;filename=".$name_file."\n\n";

$paramObj->print();
