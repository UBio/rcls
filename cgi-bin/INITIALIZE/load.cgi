#!/usr/bin/env perl
$|=1;
use strict;
use Config::IniFiles;
use read;
use LIB::mount;
use LIB::http_response_error;

use LICENSE::check;
use CGI ;
use IO::Dir;
use LOGS::simple;
my $cgi=new CGI;


my $result="";
my $ninguno=0;
my $allMacros='';



my $log_rcls=LOGS::simple->new();

# Comprobamos que existe la variable de entorno CONFOCAL_INI y que es un directorio que existe
if(!exists($ENV{CONFOCAL_INI}))
{
	# our $HTTP_ERROR_425="The Environmet var CONFOCAL_INI is not Defined in Apache Server";
	print_http_response(425,$HTTP_ERROR_425);	
	exit -4;
}

if(!-e  $ENV{CONFOCAL_INI})
{
	# our $HTTP_ERROR_422="The application is not configured";
	print_http_response(422,$HTTP_ERROR_422);
	exit -4;
}
#
# chequeamos la licencia
my $cfg_confocal = Config::IniFiles->new( -file => $ENV{CONFOCAL_INI});
my $license = LICENSE::check->new();

# print STDERR $license->{ERROR};
$log_rcls->print(-msg=>'LICENSE STATUS: '.$license->{ERROR});
if($license->{ERROR} ne 'OK')
{
	# our $HTTP_ERROR_426="Invalid license number";
	# our $HTTP_ERROR_427="Missing license number";
	# our $HTTP_ERROR_428="Invalid mac address";
	# our $HTTP_ERROR_429="Not connect with license server";
	if($license->{ERROR} ==-2)
	{
		print_http_response(426,$HTTP_ERROR_426);
	}
	if($license->{ERROR} ==-1)
	{
		print_http_response(427,$HTTP_ERROR_427);
	}
	if($license->{ERROR} ==-3)
	{
		print_http_response(428,$HTTP_ERROR_428);
	}
	exit -3;
}

#chequeamos que tenemos ficheros de configuración 
my @ini=$cfg_confocal->Parameters('INI');
if($#ini<0)
{
	# our $HTTP_ERROR_423="The application  not have any microscope configured";
	print_http_response(423,$HTTP_ERROR_423);
	exit -1;
}


my $error_mount=mountall();

if($error_mount ne 'OK')
{
	# our $HTTP_ERROR_421="ERROR mount shared points";	
	print_http_response(421,$HTTP_ERROR_421);
	exit -2;
}




my $allMacros=read_dir_macros(-dir=>$cfg_confocal->val( 'MACROS', 'dir' ));
my $micro=0;
for(my $i=0;$i<=$#ini;$i++)
{
	my $name=$ini[$i];
	my $file=$cfg_confocal->val( 'INI', $ini[$i] );

	my $cfg = Config::IniFiles->new( -file => $file);
	my $host=$cfg->val( 'HOST', 'ip' );
	my $MatrixScreenerImages=$cfg->val( 'FILES', 'MatrixScreenerImages' );
	my $templatesdir=$cfg->val( 'FILES', 'templates' );


	
	my %resultTemplates=read_dir_templates(-dir=>$templatesdir);
	my %resultImages=read_dir_images(-dir=>$MatrixScreenerImages);
	my $instance='';
	if(($resultTemplates{error} eq '') && ($resultImages{error} eq ''))
	{
		$instance="{'instance':'".$ENV{CONFOCAL_INSTANCE}."','name':'".$name."','ip':'".$host."','templates':[";		
		$instance.=$resultTemplates{list}."],'dirimages':[";	
		$instance.=$resultImages{list}."]}";
		$micro=1;
	}
	else
	{
		$instance="{'instance':'".$ENV{CONFOCAL_INSTANCE}."','name':'".$name."','ip':'".$host."','warnnings':[";		
		$instance.="'".$resultTemplates{error}."','".$resultImages{error}."']}";
		# print STDERR $resultTemplates{error}."\n";
		# print STDERR $resultImages{error}."\n";
		
	}
	$result.=",".$instance;
}

if($micro==0)
{
	# our $HTTP_ERROR_424="The volumenes are not mounted, please reload this page, if the problem will continue, you send a incidence to bioinformatics";
	print_http_response(424,$HTTP_ERROR_424);
	exit -1;
}
$result=~s/^,//;
$log_rcls->close();
print "Content-type: text/html \n\n";
print "[{'micros':[".$result."],'macros':".$allMacros."}]";
close INI;
