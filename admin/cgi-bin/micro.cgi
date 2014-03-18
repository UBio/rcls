#!/usr/bin/env perl
$|=1;
use strict;
use Config::IniFiles;
use File::Basename;
use LIB::http_response_error;
use LIB::mount;

use CGI ;

my $cgi=new CGI;

my $ACTION=$cgi->param("ACTION");

my $cfg_confocal = Config::IniFiles->new( -file => $ENV{CONFOCAL_INI});
my $objetivos_files=$cfg_confocal->val('MICRO','objetives');
sub existsObjetive
{
	my (%args)=@_;
	my $cfg_confocal = Config::IniFiles->new( -file => $ENV{CONFOCAL_INI});
	my $objetivos_files=$cfg_confocal->val('MICRO','objetives');
	
	open(INI,$objetivos_files);
	while(<INI>)
	{
		chomp;
		if($_ !~ /^#/)
		{
			my ($magnification,$size)=split(/\t/,$_);
			if($magnification eq $args{-magnification})
			{
				return 1;
			}
		}
	}
	close INI;
	return 0;
}

# our $HTTP_ERROR_433="Parcentricity exists, please remove befero to insert";
# our $HTTP_ERROR_434="Format error: id,magnification,x,y (ej:11506511,10,73375,41556)";

if($ACTION eq "parcentricity")
{
	my $file_micro=$cfg_confocal->val('INI',$cgi->param("micro"));
	my $cfg_micro = Config::IniFiles->new( -file => $file_micro);
	# exists($section, $parameter)
	# SectionExists ( $sect_name )
	if($cfg_micro->SectionExists('PARCENTRICITY'))
	{
		print_http_response(433,$HTTP_ERROR_433);
	}
	else
	{
		my $parcentricity_value=$cgi->param("parcentricity");
		my @parcentricity_values=split(/\$/,$parcentricity_value);
		for(my $iparcentricity=0;$iparcentricity<=$#parcentricity_values;$iparcentricity++)
		{
			my @parcentricity_objetive=split(/,/,$parcentricity_values[$iparcentricity]);
			if($#parcentricity_objetive!=3)
			{
				print_http_response(434,$HTTP_ERROR_434);
				exit;
			}
			else
			{
				if($iparcentricity==0)
				{
					$cfg_micro->AddSection("PARCENTRICITY");
				}
				$cfg_micro->newval ("PARCENTRICITY", $parcentricity_objetive[0], $parcentricity_objetive[1].','.$parcentricity_objetive[2].','.$parcentricity_objetive[3]);
			}
		}
		$cfg_micro->RewriteConfig();
		print "Content-type: text/text \n\n";
	}
}

# our $HTTP_ERROR_435="Parcentricity not exists";

if($ACTION eq "deleteparcentricity")
{
	my $file_micro=$cfg_confocal->val('INI',$cgi->param("micro"));
	my $cfg_micro = Config::IniFiles->new( -file => $file_micro);
	if(!$cfg_micro->SectionExists('PARCENTRICITY'))
	{
		print_http_response(435,$HTTP_ERROR_435);
	}
	else
	{
		$cfg_micro->DeleteSection('PARCENTRICITY');
		$cfg_micro->RewriteConfig();
		print "Content-type: text/text \n\n";
	}
}

if($ACTION eq "insertobjetivo")
{
	
	my $magnification=$cgi->param("magnification");
	my $size=$cgi->param("size");
	
	my $exists=existsObjetive(-magnification=>$magnification);
	if($exists==0)
	{
		print "Content-type: text/text \n\n";
		
		open(INI,">>".$objetivos_files);
		print INI $magnification."\t".$size."\n";
		close INI;
	}
	else
	{	
		print_http_response(418,$HTTP_ERROR_418);
	}
}


if($ACTION eq "insertmicro")
{
	my $name=$cgi->param("name");
	my $instance=$ENV{CONFOCAL_INSTANCE};
	my $fileInstance=dirname($ENV{CONFOCAL_INI})."/".$instance.'.'.$name.'.ini';
	
	# my $mounts=dirname($ENV{CONFOCAL_INI})."/../admin/cgi-bin/mounts/";
	# my $shared=dirname($ENV{CONFOCAL_INI})."/../shared/";
	
	my $mounts=$cfg_confocal->val('SHARE','bin');
	my $shared=$cfg_confocal->val('SHARE','mnt');
	
	my $shared_templates=$shared.'/'.$cgi->param("templatesdir");
	my $shared_images=$shared.'/'.$cgi->param("imagesdir");
	

	
	if(!$cfg_confocal->exists('INI',$name))
	{
		
		my $error=new_mount(-dir_shared_images=>$shared_images,
							-dir_shared_templates=>$shared_templates,
							-dir_bin_mounts=>$mounts,
							-name_micro=>$name,
							-ip=>$cgi->param("ip"),
							-user=>$cgi->param("user"),
							-password=>$cgi->param("passwd"),
							-win_shared_images=>$cgi->param("sharingimagesdir"),
							-win_shared_templates=>$cgi->param("sharingtemplatesdir"));

		if($error==-1)
		{
			print_http_response(431,$HTTP_ERROR_431);
			exit -1;
		}
		else
		{
			if($error==-2)
			{	
				print_http_response(431,$HTTP_ERROR_432);
				exit -2;
			}
		}

		# 

		
	
		mount(-name=>$name);
		my $error_mount=check_mount(-name=>$name);
		if($error_mount eq 'NOT_MOUNT')
		{
			unlink $mounts."/mount\.".$name;
			unlink $mounts."/umount\.".$name;
			unlink $shared_templates;
			unlink $shared_images;
			print_http_response(430,$HTTP_ERROR_430);
		}
		else
		{
			print "Content-type: text/text \n\n";
			$cfg_confocal->newval("INI", $name, $fileInstance);
			$cfg_confocal->RewriteConfig();
			my $cfg = Config::IniFiles->new();
			$cfg->AddSection("HOST");
			$cfg->newval ("HOST", "ip", $cgi->param("ip"));
			$cfg->AddSection("FILES");
			$cfg->newval ("FILES", "templates", $shared_templates);
			$cfg->newval ("FILES", "MatrixScreenerImages", $shared_images);
			$cfg->AddSection("SHAREDIR");
			$cfg->newval ("SHAREDIR", "templates", $cgi->param("sharingtemplatesdir"));
			$cfg->newval ("SHAREDIR", "MatrixScreenerImages", $cgi->param("sharingimagesdir"));
			$cfg->WriteConfig ($fileInstance);
		}

		
			
	}
	else 
	{
		print_http_response(419,$HTTP_ERROR_419);
	}
	
}

if($ACTION eq "deletemicro")
{
	print "Content-type: text/text \n\n";
	
	my $file_micro=$cfg_confocal->val('INI',$cgi->param("micro"));
	my $dir_templates=$cfg_confocal->val('FILES','templates');
	my $dir_Images=$cfg_confocal->val('FILES','MatrixScreenerImages');
	$cfg_confocal->delval('INI',$cgi->param("micro"));
	
	# umount(-name=>$cgi->param("micro"));
	if(-e $dir_templates)
	{
		system('rmdir '.$dir_templates);
	}
	if(-e $dir_Images)
	{
		system('rmidr '.$dir_Images);
	}
	unlink $file_micro;
	
	$cfg_confocal->WriteConfig ($ENV{CONFOCAL_INI});
	
	# templates=/Volumes/ScanningTemplates/
	# MatrixScreenerImages=/Volumes/MatrixScreenerImagesAlternative/
}






















