#!/usr/bin/env perl
$|=1;
use strict;
use Config::IniFiles;
use LIB::http_response_error qw (print_http_response $HTTP_ERROR_417);

use CGI ;
my $cgi=new CGI;

my $macro=$cgi->param('macro');

my $cfg_confocal = Config::IniFiles->new( -file =>$ENV{CONFOCAL_INI} );
my $dirMacros=$cfg_confocal->val( 'MACROS', 'dir' );


if(open(DAT,">".$dirMacros."/".$macro))
{
	close DAT;
	system("rm $dirMacros/$macro");
	print "Content-type: text/txt \n\n";
	
}
else
{
	print_http_response(417,$HTTP_ERROR_417);
}
