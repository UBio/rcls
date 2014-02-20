#!/usr/bin/env perl
$|=1;
use strict;
use Config::IniFiles;
use LIB::http_response_error;
use JSON qw( decode_json );
use CGI ;

my $cgi=new CGI;

##################################################################################################################
##################################################################################################################
##################################################################################################################
##################################################################################################################
##################################################################################################################
my $cfg_confocal = Config::IniFiles->new( -file => $ENV{CONFOCAL_INI});
my $tmp=$cfg_confocal->val( 'FILES', 'tmp' );
my $dirImages=$cfg_confocal->val( 'FILES', 'MatrixScreenerImages' );
##################################################################################################################
##################################################################################################################
##################################################################################################################
##################################################################################################################
##################################################################################################################
my $name=$cgi->param("name");
my $confFile=$cfg_confocal->val( 'INI', $name);

my $step=$cgi->param("step");
my $nameStep1=$cgi->param("nameStep1");
my $nameStep2=$cgi->param("nameStep2");
my $dir=$cgi->param("dir");
my $black=$cgi->param("black");
my $thresholdMin=$cgi->param("thresholdMin");
my $thresholdMax=$cgi->param("thresholdMax");
my $size=$cgi->param("size");
my $maxsize=$cgi->param("maxsize");
my $codecolor=$cgi->param("codecolor");

if($maxsize eq "")
{
	$maxsize="Infinity";
}
my $circularity=$cgi->param("circularity");
my $macro_detection=$cgi->param("macro_detect");
my $macro_stitching=$cgi->param("macro_stitching");
my $macro_blacks=$cgi->param("macro_blacks");
my $template_step1=$cgi->param("template_step1");
my $template_step2=$cgi->param("template_step2");

my $template_high=$cgi->param("template_high");



##################################################################################################################
##################################################################################################################
##################################################################################################################
##################################################################################################################
##################################################################################################################
# export PERL5LIB=$PERL5LIB:/Users/acarro/Sites/Confocal/libexe;/Users/acarro/Sites/Confocal/libexe/LeicaWorkFlow.pl 
# --conf /Users/acarro/Sites/Confocal/CONF/localhost.white.ini  
# --create --imagej --dir 01-multiwell -thresholdMin 11 -thresholdMax 255 -size 5000 
# -maxsize Infinity -circularity 0 -macro_detection detect/MultiWell.ijm   -name_micro white
my $args="";
if($step eq 'merge')
{
	my $templates=$cgi->param("merge");
	$templates=~s/,/ /g;
	$args="--conf $confFile -name_micro $name -merge $templates";
}
else
{
	if($step ne 'high')
	{
		if($step ne 'join') #stitching
		{
			if($cgi->param("coor") eq 'true')
			{
				$args="--coor";
		
			}
			$args.=" --conf $confFile -template_step1 $template_step1 -name_micro $name";
		}
		else
		{
			$args.=" --conf $confFile -template_step2 $template_step2 -name_micro $name";
			# print "Content-type: text/txt \n\n";
			# print "[{'name':'Slide--S00_Chamber--U00--V00.tif','path':'/Volumes/MatrixScreenerImagesAlternative//experiment--2013_02_27_16_22-stitching'},{'name':'Slide--S00_Chamber--U01--V00.tif','path':'/Volumes/MatrixScreenerImagesAlternative//experiment--2013_02_27_16_22-stitching'}]";
			# exit;
		}
	}
	else
	{
		$args="--high --template_high $template_high --conf $confFile -name_micro $name -template_step2 $template_step2"
	}
}

if($macro_detection)
{
	$args.=" -macro_detection $macro_detection";
}
if($macro_blacks)
{
	$args.=" -macro_black $macro_blacks";
}
if($macro_stitching)
{
	$args.=" -macro_stitching $macro_stitching";
}


if(-e "$tmp/".$name.".lock")
{	
	print_http_response(409,"$name".$HTTP_ERROR_409);
}

system("touch $tmp/".$name.".lock");




my $CMD=$cfg_confocal->val( 'WEB', 'CMD' );
if($step eq 'step1')
{
	$args.=" --".$step;
}
if($step eq 'imagej')
{
	$args.=" -template_step2 $template_step2  -thresholdMin $thresholdMin -thresholdMax $thresholdMax -size $size -maxsize $maxsize -circularity $circularity ";
	
	$args.=" --create --".$step;
	if($dir ne "")
	{
		$args.=" --dir ".$dir;
	}

	if($black eq 'true')
	{
		$args.=" --black";
	}	
}


my ($permisos,$id,$user,$group,$sizem,$day,$mounth,$year,$file);
if($dir eq "")
{
	my @dir=split(/\n/,`ls -ltr $dirImages`);
	($permisos,$id,$user,$group,$sizem,$day,$mounth,$year,$file)=split(/\s+/,$dir[$#dir]);
}
else
{
	$file=$dir;
}
my $image=$dirImages."/".$file;


if($step eq 'join')
{
	$args.=" --".$step;
	if($dir ne "")
	{
		$args.=" --dir ".$dir;
	}
	
	$args.=" --codecolor ".$codecolor;
}



my $PERL5LIB="export PERL5LIB=\$PERL5LIB:".$cfg_confocal->val( 'WEB', 'PERL5LIB' );
print STDERR $PERL5LIB.";".$CMD." ".$args."\n";

my $error=`$PERL5LIB && $CMD $args`;
if($step eq 'merge')
{
	my $response = decode_json($error);
	print STDERR "Code: ".$response->{code}."\n";
	
	if($response->{code}==0)
	{
		$error="[]";
	}
	else
	{
		$error= "[{'ERROR':".$response->{code}.",'MSG':'".$response->{msg}."'}]";
		
	}
	
}

if($step ne 'step1' && $step ne 'high' & $step ne 'merge')
{
	print STDERR "RESULT: ".$error."\n";
	my @response=split(/\}\{/,$error);
	my $JSON="";
	for(my $i=0;$i<=$#response;$i++)
	{
		# $response[$i]=$response[$i];
		print STDERR 'RESULTADO: '.$i.' ====>'.$response[$i]."\n";
		$response[$i]=~s/^\{|\}$|\"//gi;
		
		my %response_hash = split /[,:]/, $response[$i];
		
		
		my $coordenates=$cfg_confocal->val( 'FILES', 'tmp' );
		
		my $num_error=$response_hash{code};
		my $msg=$response_hash{msg};
		my $rotate=$response_hash{rotate};
		my $slide=$response_hash{slide};
		my $chamber=$response_hash{chamber};
		my $img=$response_hash{img};
		my $coor_File=$coordenates."/coordenates_$name--S".$slide."--U".$chamber."\.txt";
		my $z=$response_hash{z};
		
		
		if($num_error<0)
		{
			my $error_imagej=$2;
			if($error_imagej ne "")
			{
				system("rm $tmp/".$name.".lock");
				if($error_imagej =~/DISPLAY/g)
				{
					$error_imagej="java.lang.InternalError: Can't connect to X11 window server";
				}
				$JSON.=",{'ERROR':$num_error,'MSG':'$error_imagej'}";
				
				# print_http_response(412,"ERROR: ".$error.": ".$error_imagej);
			}
			if(-s $coor_File<=0)
			{
				$JSON.=",{'ERROR':$num_error,'MSG':'$HTTP_ERROR_411'}";
			}
			if($error==2)
			{
				$JSON.=",{'ERROR':$num_error,'MSG':'$HTTP_ERROR_415'}";
			
			}	
			if($error==3)
			{
				$JSON.=",{'ERROR':$num_error,'MSG':'$HTTP_ERROR_416'}";
			
			}
			if($error==4)
			{
				$JSON.=",{'ERROR':$num_error,'MSG':'$HTTP_ERROR_420'}";
			
			}
		}
		else
		{	

			if($msg =~ /(.*)-U(\d+)/)
			{
				$JSON.=",{'ERROR':0,'MSG':'$msg',slide:'$slide',chamber:'$chamber',Z:$z,'rotate':'$rotate',img:'$img'}";
			}
		
		}
	}
	$JSON=~s/^,//;
	$JSON="[$JSON]";
	print "Content-type: text/txt \n\n";
	print $JSON;
	print STDERR $JSON."\n";
	if($step eq "black")
	{
		my $coor_File=$cfg_confocal->val( 'FILES', 'tmp')."/black_list_coordentes";
		if(-s $coor_File<=0)
		{
			system("rm $tmp/".$name.".lock");
			print_http_response(410,$HTTP_ERROR_410);
		}
	}
}
else
{
	print "Content-type: text/txt \n\n";
	print $error;
}
system("rm $tmp/".$name.".lock");

