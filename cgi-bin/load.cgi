#!/usr/bin/env perl
$|=1;
use strict;
use Config::IniFiles;
use LIB::mount;
use LIB::http_response_error;

use LICENSE::check;
use CGI ;
use IO::Dir;
my $cgi=new CGI;
# print STDERR $query."\n";


my $result="";
my $ninguno=0;
my $allMacros='';

# our $HTTP_ERROR_421="ERROR mount shared points";
# our $HTTP_ERROR_422="The application is not configured";
# our $HTTP_ERROR_423="The application  not have any microscope configured";
# our $HTTP_ERROR_424="The volumenes are not mounted, please reload this page, if the problem will continue, you send a incidence to bioinformatics";
# our $HTTP_ERROR_425="The Environmet var CONFOCAL_INI is not Defined in Apache Server";


if(!exists($ENV{CONFOCAL_INI}))
{
	print_http_response(425,$HTTP_ERROR_425);	
	exit -4;
}
if(!-e  $ENV{CONFOCAL_INI})
{
	print_http_response(422,$HTTP_ERROR_422);
	exit -4;
}

my $cfg_confocal = Config::IniFiles->new( -file => $ENV{CONFOCAL_INI});
my $license = LICENSE::check->new();

print STDERR $license->{ERROR};

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


my @ini=$cfg_confocal->Parameters('INI');
if($#ini<0)
{
	print_http_response(423,$HTTP_ERROR_423);
	exit -1;
}


my $error_mount=mountall();

if($error_mount ne 'OK')
{
	print_http_response(421,$HTTP_ERROR_421);
	exit -2;
}

my $dirMacros=$cfg_confocal->val( 'MACROS', 'dir' );

for(my $i=0;$i<=$#ini;$i++)
{
	my $name=$ini[$i];
	my $file=$cfg_confocal->val( 'INI', $ini[$i] );

	my $cfg = Config::IniFiles->new( -file => $file);
	my $host=$cfg->val( 'HOST', 'ip' );
	my $MatrixScreenerImages=$cfg->val( 'FILES', 'MatrixScreenerImages' );
	my $templatesdir=$cfg->val( 'FILES', 'templates' );

	opendir(DIR,$dirMacros)||die $dirMacros.':'.$!;
	if($allMacros eq '')
	{
		while( (my $tiposMacro = readdir(DIR)))
		{
		
			if($tiposMacro !~ /^\./)
			{
		    	opendir(DIRM,$dirMacros."/".$tiposMacro);
				my $file_macro_aux='[';
				while( (my $macrofile = readdir(DIRM)))
				{
					if($macrofile !~ /^\./)
					{
						if($file_macro_aux eq '[')
						{
							$file_macro_aux.="'".$macrofile."'";
						}
						else
						{
							$file_macro_aux.=",'".$macrofile."'";
						}
					}
				}
			
				$file_macro_aux.=']';
				close DIRM;
				$file_macro_aux="'".$tiposMacro."':".$file_macro_aux;
				if($allMacros eq '')
				{
					$allMacros=$file_macro_aux;
				}
				else
				{
					$allMacros.=",".$file_macro_aux;
				}
			}
		}
		$allMacros="{".$allMacros."}";
		close DIR;
	}
	
	if(-e $MatrixScreenerImages && -e $templatesdir)
	{
		my $instance="";
		my $entro=0;
		$ninguno=1;
		# if($result eq "")
		# {
			$instance="{'instance':'".$ENV{CONFOCAL_INSTANCE}."','name':'".$name."','ip':'".$host."','templates':[";
		# }
		# else
		# {
		# 	$instance.=",{'instance':'".$ENV{CONFOCAL_INSTANCE}."','name':'".$name."','ip':'".$host."','templates':[";
		# }

		opendir(DIR,$templatesdir) || die $!."\n" ;
		while( (my $filename = readdir(DIR)))
		{
			if($filename =~ /\{ScanningTemplate\}(.*)\.xml/)
			{
				$entro=1;
		    	$instance.="'".$1."',";
			}
		}
		$instance=~s/,$//;
		$instance.="],'dirimages':[";
		closedir(DIR);
		opendir(DIR,$MatrixScreenerImages)||die "$!\n";
		while( (my $filename = readdir(DIR)))
		{
			if($filename !~ /^\./)
			{
				if($entro==1)
				{
					$entro=2;
				}
				#if(-e $MatrixScreenerImages."/".$filename."/".$NameImageFileStep1)
				#{
		    		$instance.="'".$filename."',";
				#}
			}
		}
		$instance=~s/,$//;
		$instance.="]}";	
		closedir(DIR);
		if($entro==2)
		{
			$result.=",".$instance;
		}
	
	}
}
if($ninguno==0 || $result eq '')
{
	print_http_response(424,$HTTP_ERROR_424);
	exit -1;
}
$result=~s/^,//;

print "Content-type: text/html \n\n";
print "[{'micros':[".$result."],'macros':".$allMacros."}]";
close INI;
