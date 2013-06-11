#!/usr/bin/env perl
$|=1;
use strict;
use Config::IniFiles;

use CGI ;

my $cgi=new CGI;

my $conf=$cgi->param("conf");
my $cfg_confocal = Config::IniFiles->new( -file => $ENV{CONFOCAL_INI} );
my $tmp=$cfg_confocal->val( 'FILES', 'tmp' );

print "Content-type: text/text \n\n";

#if(-e "../CONF/".$conf.".ini")
#{
	if(-e $tmp."/".$conf.".lock")
	{
	  print "true";
	}
	else
	{
	  print "false";
	}
#}
#else
#{
#	print "false";
#}