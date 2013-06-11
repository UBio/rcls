#!/usr/bin/env perl
$|=1;
use strict;
use Config::IniFiles;

use CGI ;
my $cgi=new CGI;

my $from=$cgi->param('from');
my $to=$cgi->param('to');

my $cfg_confocal = Config::IniFiles->new( -file =>$ENV{CONFOCAL_INI} );
my $dirMacros=$cfg_confocal->val( 'MACROS', 'dir' );


system("mv $dirMacros/$from $dirMacros/$to/");

print "Content-type: text/txt \n\n";
