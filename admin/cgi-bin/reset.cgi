#!/usr/bin/env perl
use strict;
use Config::IniFiles;


use CGI ;

my $cgi=new CGI;


my $cfg_confocal = Config::IniFiles->new( -file => $ENV{CONFOCAL_INI});
my @micros=$cfg_confocal->Parameters ('INI');

print "Content-type: text/html \n\n";

for(my $i=0;$i<=$#micros;$i++)
{
	my $file_micro=$cfg_confocal->val('INI',$micros[$i]);
	if(-e $file_micro)
	{
		unlink $file_micro;
	}
	$cfg_confocal->delval('INI',$micros[$i]);
}

$cfg_confocal->RewriteConfig();

print '<meta http-equiv="refresh" content="0; url=../../">';


