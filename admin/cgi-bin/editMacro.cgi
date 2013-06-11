#!/usr/bin/env perl
$|=1;
use strict;
use Config::IniFiles;

use CGI ;
my $cgi=new CGI;

my $macro=$cgi->param('macro');
my $action=$cgi->param('action');

my $cfg_confocal = Config::IniFiles->new( -file =>$ENV{CONFOCAL_INI} );
my $dirMacros=$cfg_confocal->val( 'MACROS', 'dir' );



print "Content-type: text/txt \n\n";

if($action eq 'load')
{
	open(DAT,$dirMacros."/".$macro) || die "No encuentro la macro para editar: ".$dirMacros."/".$macro;
	while(<DAT>)
	{
		print $_;
	}
	close DAT;
}