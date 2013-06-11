#!/usr/bin/env perl
$|=1;
use strict;
use Config::IniFiles;
use UPLOAD::upload;
use CGI ;
use LIB::http_response_error qw (print_http_response $HTTP_ERROR_414 $HTTP_ERROR_417);
my $cgi=new CGI;




my $name=$cgi->param('AddMacro');
my $type=$cgi->param('typeMacro');
# my $macro=$cgi->param('macro');
# my $action=$cgi->param('action');



# $macro=~s/\n//g;

print STDERR $name."\n";
print STDERR $type."\n";

my $cfg_confocal = Config::IniFiles->new( -file =>$ENV{CONFOCAL_INI} );
my $dirMacros=$cfg_confocal->val( 'MACROS', 'dir' );
if(-e $dirMacros."/".$type."/".$name)
{
	print_http_response(414,$HTTP_ERROR_414);
}
else
{
	UPLOAD::upload->new(-file=>'AddMacro',-to=>$dirMacros.'/'.$type.'/');
	print "Content-type: text/html \n\n";
	print "Finish";
}
# print "Content-type: text/text \n\n";


# 
# if($name !~ /\.ijm$/)
# {
# 	$name.="\.ijm";
# }
# if($action eq 'add')
# {
# 	if(-e $dirMacros."/".$type."/".$name)
# 	{
# 		print_http_response(414,$HTTP_ERROR_414);
# 	
# 	}
# }

# if(open(DAT,">".$dirMacros."/".$type."/".$name))
# {
# 	my @lineMacro=split(/;;[;]?/,$macro);
# 	# print STDERR $macro;
# 	for(my $i=0;$i<=$#lineMacro;$i++)
# 	{
# 		# @lineMacro[$i]=~s/;$//g;
# 		# print STDERR $lineMacro[$i]."\n";
# 		print DAT $lineMacro[$i]."\n";
# 	}
# 	close DAT;
# 	print "Content-type: text/text \n\n";
# }
# else
# {
# 	print_http_response(417,$HTTP_ERROR_417);
# }