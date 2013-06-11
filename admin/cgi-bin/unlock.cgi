#!/usr/bin/env perl
$|=1;
use strict;
use Config::IniFiles;

use CGI ;

my $cgi=new CGI;


my $cfg_confocal = Config::IniFiles->new( -file => $ENV{CONFOCAL_INI});
my $tmp=$cfg_confocal->val( 'FILES', 'tmp' );


print "Content-type: text/txt \n\n";

my $conf=$cgi->param('conf');

if(-e $tmp."/".$conf.".lock")
{
  system("rm ".$tmp."/".$conf.".lock");
}
