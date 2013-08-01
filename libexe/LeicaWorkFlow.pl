#!/usr/bin/env perl
$|=1;

#
#  LeicaWorkFlow
#
#  Created by acarro on 2011-03-28.
#  Copyright (c) 2011 CNIO. All rights reserved.

$VERSION   = '1.00';

use strict;
use LASAF::CAM::leicaCAM;
use LASAF::TEMPLATE::template;
use LASAF::TEMPLATE::merge;
use ImageJ::ImageJ;
use Getopt::Long;
use File::Basename;
use Config::IniFiles;
use ImageJ::stitching;
use META::metadata;
use Image::utils;
use Exception::Class;
use CORE::core qw(get_all_images);
my $client;

my $help;
my $step1;
my $imagej;
my $high;
my $create;
my $join;
my $html;
my $search_black_fields;
my $confFile="";
my $dirImagenes="NULL";

my $param_thresholdMin;
my $param_thresholdMax;
my $param_size;
my $param_maxsize;
my $param_circularity;
my $param_macro_detection;
my $param_macro_stitching;
my $param_macro_black;
my $param_template_step1;
my $param_template_step2;
my $param_template_high;
my $param_color_code="BRG";
my $param_name_micro="unknow";
my @param_merge_files="";
my $param_merge_output="";
my $param_corregir_coordenadas;
my $param_paracentricidad="";
GetOptions(
    "help"=>\$help,
	"conf=s" => \$confFile,
	"step1" =>\$step1,
	"imagej" =>\$imagej,
	"create" =>\$create,
	"high" =>\$high,
	"black" => \$search_black_fields,
	"join" => \$join,
	"html" => \$html,
	"dir=s" => \$dirImagenes,
	"thresholdMin=s" =>\$param_thresholdMin,
	"thresholdMax=s" =>  \$param_thresholdMax,
	"size=s" => \$param_size,
	"maxsize=s" => \$param_maxsize,
	"circularity=s" => \$param_circularity,
	"macro_detection=s" => \$param_macro_detection,
	"macro_black=s" => \$param_macro_black,
	"macro_stitching=s" => \$param_macro_stitching,
	"macro_black=s" => \$param_macro_black,
	"template_step1=s" => \$param_template_step1,
	"template_step2=s" => \$param_template_step2,
	"template_high=s" =>\$param_template_high,
	"name_micro=s" => \$param_name_micro,
	"codecolor=s" => \$param_color_code,
	"merge=s{2,}" => \@param_merge_files,
	"merge_output=s" => \$param_merge_output,
	"coor" => \$param_corregir_coordenadas,
	"parcentricity" => \$param_paracentricidad
	
);

sub response
{
	my (%args)=@_;

	my $json;
	
	
	
	

	$json='{';
	$json.='"code":'.$args{-code};
	$json.=',"msg":"'.$args{-msg}.'"';
	$json.=',"slice":"'.$args{-slice}.'"';
	$json.=',"chamber":"'.$args{-chamber}.'"';
	$json.=',"z":"'.$args{-z}.'"';
	$json.=',"rotate":"'.$args{-rotate}.'"';
	$json.='}';
	
	return $json;
	
	
}

sub help()
{
	my $usage = qq{
	LeicaWorkFlow.pl -conf <pathToFileConf> [step1|imagej|create|high|black|join]

};

	print STDERR $usage;
	exit(1);
}


if(!$confFile || !-e $confFile)
{
	help();
	exit;
}
# open(STDERR,">>/tmp/confocal_error.log");

##################################################################################################################
##################################################################################################################
##################################################################################################################
##################################################################################################################
if(!exists($ENV{CONFOCAL_INI}))
{
	print "ERROR: -999 MSG: Set the variable CONFOCAL_INI\n";
	exit;
}

my $cfg = Config::IniFiles->new( -file => $confFile );
my $host=$cfg->val( 'HOST', 'ip' );
my $templatesdir=$cfg->val( 'FILES', 'templates' );
my $MatrixScreenerImagesDir=$cfg->val( 'FILES', 'MatrixScreenerImages' );

my %parcentricity_correction;

if($cfg->SectionExists ('PARCENTRICITY'))
{
	print STDERR "READ PARCENTRICITY\n";
	my @params=$cfg->Parameters ('PARCENTRICITY');
	for(my $i=0;$i<=$#params;$i++)
	{
		print STDERR $params[$i]."\n";
		
		my ($magnification,$x,$y)=split(",",$cfg->val('PARCENTRICITY',$params[$i]));
		print STDERR "$magnification,$x,$y\n";
		$parcentricity_correction{$magnification}{X}=$x;
		$parcentricity_correction{$magnification}{Y}=$y;
		# print $magnification."\t".$parcentricity_correction{$magnification}{X}."\t".$parcentricity_correction{$magnification}{Y}."\n";
	}
	print STDERR "END PARCENTRICITY\n";
}

if(scalar(@param_merge_files)>1)
{
	print STDERR "NOTICE: Start Merge Files\n";
	if(!$param_merge_output)
	{
		$param_merge_output="join";
		print STDERR "NOTICE: no output file, used default name: $param_merge_output\n";
	}
	my %error=LASAF::TEMPLATE::merge->new(-files=>\@param_merge_files,-templatesdir=>$templatesdir,-output=>$param_merge_output);
	# print "ERROR: ".$error{code}." MSG: ".$error{msg}." Slide:  Chamber:  Z:\n";
	
	print response(-code=>$error{code},
				-msg=>$error{msg},
				-slice=>'',
				-chamber=>'',
				-z=>'',
				-rotate=>'');
				
	print STDERR "\nNOTICE: End Merge Files\n";
	
}
# print "Hollaaa\n";
# exit;





my $cfg_confocal = Config::IniFiles->new( -file => $ENV{CONFOCAL_INI});
##################################################################################################################
##################################################################################################################
##################################################################################################################
##################################################################################################################
##################################################################################################################
my $dirMacros=$cfg_confocal->val( 'MACROS', 'dir' );
my $macro=$dirMacros."/".$cfg_confocal->val( 'MACROS', 'detection' );
if($param_macro_detection)
{
	$macro=$dirMacros."/".$param_macro_detection;
}
##################################################################################################################
my $PathToMacroBlackSearch=$dirMacros."/".$cfg_confocal->val( 'MACROS', 'searchBlackRectangles' );
if($param_macro_black)
{
	$PathToMacroBlackSearch=$dirMacros."/".$param_macro_black;
}

my $PathToMacroStitching=$dirMacros."/".$cfg_confocal->val( 'MACROS', 'stiching' );
if($param_macro_stitching)
{
	$PathToMacroStitching=$dirMacros."/".$param_macro_stitching;
}
##################################################################################################################
##################################################################################################################
##################################################################################################################
##################################################################################################################
##################################################################################################################
my $image_control_grid=$cfg_confocal->val( 'FILES', 'tmp' )."/".$param_name_micro."_control_grid.tif";
##################################################################################################################
##################################################################################################################
my $outputFileImageJ;
my $fileBlackList=$cfg_confocal->val( 'FILES', 'tmp' )."/black_list_coordenates";
##################################################################################################################
##################################################################################################################
##################################################################################################################
##################################################################################################################
##################################################################################################################
my $STEP1NAME=$cfg_confocal->val( 'STEP1', 'name' );
if($param_template_step1)
{
	$STEP1NAME=$param_template_step1;
}
my $STEP1FILE=$templatesdir .'/{ScanningTemplate}'.$STEP1NAME.'.xml';
my $STEP2NAME=$cfg_confocal->val( 'STEP2', 'name' );
if($param_template_step2)
{
	$STEP2NAME=$param_template_step2;
}
my $STEP2FILE=$templatesdir .'/{ScanningTemplate}'.$STEP2NAME.'.xml';
##################################################################################################################
##################################################################################################################
##################################################################################################################
##################################################################################################################
##################################################################################################################
my @thresholdMin=split(/,/,$cfg_confocal->val( 'IMAGEJ', 'thresholdMin' ));
if($param_thresholdMin||$param_thresholdMin==0)
{
	@thresholdMin=split(/,/,$param_thresholdMin);
}
my @thresholdMax=split(/,/,$cfg_confocal->val( 'IMAGEJ', 'thresholdMax' ));
if($param_thresholdMax)
{
	@thresholdMax=split(/,/,$param_thresholdMax);
}
my @sizeParticule=split(/,/,$cfg_confocal->val( 'IMAGEJ', 'size' ));
if($param_size)
{
	@sizeParticule=split(/,/,$param_size);
}
my @sizeParticuleMax=split(/,/,$cfg_confocal->val( 'IMAGEJ', 'maxsize' ));
if($param_maxsize)
{
	@sizeParticuleMax=split(/,/,$param_maxsize);
}
my @circularity=split(/,/,$cfg_confocal->val( 'IMAGEJ', 'circularity' ));
if($param_circularity)
{
	@circularity=split(/,/,$param_circularity);
}
##################################################################################################################
##################################################################################################################
##################################################################################################################
##################################################################################################################
##################################################################################################################

my $sort=$cfg_confocal->val( 'MICRO', 'sort' );

my $verbose=$cfg_confocal->val( 'DEBUG', 'verbose' );
if($verbose==1)
{
	open STDERR, ">".$cfg_confocal->val( 'DEBUG', 'errorlog' );
}
my $redirect=$cfg_confocal->val( 'DEBUG', 'redirect' );
if($redirect==1)
{
	open STDOUT, ">".$cfg_confocal->val( 'DEBUG', 'outputlog' );
}
my $leica;
##################################################################################################################
##################################################################################################################
##################################################################################################################
##################################################################################################################
##################################################################################################################
if($param_paracentricidad)
{
	my $parcentricity_name="objetivos";
	my $parcentricity=$templatesdir .'/{ScanningTemplate}'.$parcentricity_name.'.xml';
	
	my $templateStep1=LASAF::TEMPLATE::template->new(-template=>$parcentricity);
	if($templateStep1->isEnableCam() eq "false")
	{
		$templateStep1->enableCam();
		$templateStep1->write(-file=>$parcentricity);
	}
	
	my %InfoObjetives=$templateStep1->getAllInfoObjectives();
	
	$leica=LASAF::CAM::leicaCAM->new(-host=>$host);
	$leica->load_template(-template=>$parcentricity_name);
	
	
	foreach my $objNumber (keys %InfoObjetives)
	{
		foreach my $jobname (keys %{$InfoObjetives{$objNumber}})
		{
			$leica->change_job(-job=>$jobname);
			$leica->getInfo();
			$InfoObjetives{$objNumber}{$jobname}=$InfoObjetives{$objNumber}{$jobname}."\t".$leica->{XPOS}."\t".$leica->{YPOS};
		}
	}
	
	$leica->close();
	undef $leica;
	
	if($cfg->SectionExists('PARCENTRICITY'))
	{
		$cfg->DeleteSection('PARCENTRICITY');
	}
	$cfg->AddSection('PARCENTRICITY');
	
	foreach my $objNumber (keys %InfoObjetives)
	{
		print STDERR $objNumber."\t";
		foreach my $jobname (keys %{$InfoObjetives{$objNumber}})
		{
			my ($magnification,$x,$y)=split(/\t/,$InfoObjetives{$objNumber}{$jobname});
			print STDERR $jobname."\t".$InfoObjetives{$objNumber}{$jobname}."\n";
			$cfg->newval('PARCENTRICITY', $objNumber, "$magnification,$x,$y");
		}
	}
	
	$cfg->RewriteConfig();
}


####################################################################################################
####################################################################################################
####################################################################################################
#  Lee un template y lanza un autofocus y un scaneo el resultado es una imagen a baja resolucion
if($step1)
{
	my $templateStep1=LASAF::TEMPLATE::template->new(-template=>$STEP1FILE);
	if($templateStep1->isEnableCam() eq "false")
	{
		$templateStep1->enableCam();
		$templateStep1->write(-file=>$STEP1FILE);
	}
	
	
	$leica=LASAF::CAM::leicaCAM->new(-host=>$host);
	$leica->load_template(-template=>$STEP1NAME);
	$leica->autofocus();
	$leica->start();
	$leica->close();
	undef $leica;
	
	my @all_images_step1=get_all_images(-MatrixScreenerImagesDir=>$MatrixScreenerImagesDir,-host=>$host);
	
	my $JSON="";
	foreach my $image (sort @all_images_step1)
	{
		$JSON.=",{'name':'".basename($image)."','image':'$image'}";
	}
	$JSON=~s/^,//;
	print "[$JSON]";
	
	# my $metadata=META::metadata->new(-file=>"");
	# $metadata->step1(-template=>$STEP1NAME);
	# $metadata->write();
	
}
if($high)
{
	my $templateHigh=LASAF::TEMPLATE::template->new(-template=>$STEP2FILE);
	if($templateHigh->isEnableCam() eq "false")
	{
		$templateHigh->enableCam();
		$templateHigh->write(-file=>$STEP2FILE);
	}
	
	print STDERR "Scaneamos: $param_template_high en el micro: $host\n";
	$leica=LASAF::CAM::leicaCAM->new(-host=>$host);
	$leica->load_template(-template=>$STEP2NAME);
	$leica->close();
	# sleep(60);
	
	my $template_high_file=$templatesdir .'/{ScanningTemplate}'.$param_template_high.'.xml';
	my $templateHigh=LASAF::TEMPLATE::template->new(-template=>$template_high_file);
	if($templateHigh->isEnableCam() eq "false")
	{
		$templateHigh->enableCam();
		$templateHigh->write(-file=>$template_high_file);
	}
	
	
	$leica=LASAF::CAM::leicaCAM->new(-host=>$host);
	$leica->load_template(-template=>$param_template_high);
	$leica->close();
	undef $leica;
}
# __END__
####################################################################################################
###################################################################################################
####################################################################################################
####################################################################################################
# Generamos el fichero con las posiciones de las celulas
my (@all_slide_and_chamber);
##############################################################################################################################
my $file; #Esta variable se le paso a la funcion get_all_images para que te devuelva el nombre del working directori
##############################################################################################################################
my $utils;
if($imagej || $search_black_fields || $create)
{
	@all_slide_and_chamber=get_all_images(-file=>\$file,-dirImagenes=>$dirImagenes,-MatrixScreenerImagesDir=>$MatrixScreenerImagesDir,-host=>$host);
	print STDERR "Select DIR:".$file."\n";
}

my $NameImageFileStep1;
my %sizes_images;
foreach $NameImageFileStep1 (@all_slide_and_chamber)
{
	my %error;
	my $slide;
	my $chamber=0;
	my $rotate;
	$outputFileImageJ=$cfg_confocal->val( 'FILES', 'tmp')."/coordenates_$param_name_micro";
	if($imagej)
	{
	
		print STDERR "******IMAGEJ*********************************************************************\n";
		if($NameImageFileStep1 =~ /(.*)image--L0000--S(\d+)--U(\d+)--V(\d+)--J00--X00--Y00--T0000--Z00--C00.ome.tif/)
		{
			# my @aux=split(/\./,$outputFileImageJ);#Le quietamos la extension
			$outputFileImageJ=$outputFileImageJ."--S".$2."--U".$3."\.txt";
			$slide=$2;
			if($3 ne '00')
			{
				$chamber=$3;
			}
			if($4 ne '00')
			{
				$chamber=$4;
			}
		}
		my $imageJ=ImageJ::ImageJ->new(-macro=>$macro,-image=>$NameImageFileStep1,-output=>$outputFileImageJ, -conf=>$confFile);
		#Queremos que el fichero de salida se crea nuevo siempre
		
	
		if($#sizeParticuleMax>0)
		{
			print STDERR "Threshold: ".$thresholdMin[$chamber]."\t".$thresholdMax[$chamber]."\n";
			print STDERR "Size: ".$sizeParticule[$chamber]."\t".$sizeParticuleMax[$chamber]."\n";
			print STDERR "Circularity: ".$circularity[$chamber]."\n";
			
			
			%error=$imageJ->runPipe(-maxsize=>$sizeParticuleMax[$chamber],
								-size=>$sizeParticule[$chamber],
								-circularity=>$circularity[$chamber],
								-thresholdMin=>$thresholdMin[$chamber],
								-thresholdMax=>$thresholdMax[$chamber],
								-type=>'>');
		}
		else
		{
			print STDERR "Threshold: ".$thresholdMin[0]."\t".$thresholdMax[0]."\n";
			print STDERR "Size: ".$sizeParticule[0]."\t".$sizeParticuleMax[0]."\n";
			print STDERR "Circularity: ".$circularity[0]."\n";
			
			%error=$imageJ->runPipe(-maxsize=>$sizeParticuleMax[0],
								-size=>$sizeParticule[0],
								-circularity=>$circularity[0],
								-thresholdMin=>$thresholdMin[0],
								-thresholdMax=>$thresholdMax[0],
								-type=>'>');
		}
		
		if($error{code}<0)
		{
			$error{msg}=~s/\n/ /gi;
			print STDERR "ERROR: ".$error{code}." MSG: ".$error{msg}." Rotate: ".$imageJ->{ROTATE}." Slide: $slide Chamber: $chamber Z:\n";
			print "ERROR: ".$error{code}." MSG: ".$error{msg}." Rotate: ".$imageJ->{ROTATE}." Slide: $slide Chamber: $chamber Z:\n";
		}
		$rotate=$imageJ->{ROTATE};
		#$imageJ->run();
		print STDERR "******FINISH IMAGEJ**************************************************************\n";
		$utils=Image::utils->new(-file=>$NameImageFileStep1);
		
		# $sizes_images{WIDTH_WITH_STITCHING}=$utils->getWidth();
		# $sizes_images{HEIGHT_WITH_STITCHING}=$utils->getHeight();
	
		
	
	}
	my @blackPoints;
	if($error{code}>=0 && $search_black_fields)
	{
		print STDERR "******SEARCH BLACKS**************************************************************\n";
	
		my $templateStep1=LASAF::TEMPLATE::template->new(-template=>$STEP1FILE,-errorfile=>$outputFileImageJ);
		$templateStep1->{STEP1}=$templateStep1;
		my ($w,$h)=$templateStep1->getDimension();
		#my ($w,$h)=split(/x|X/,$dimension);
		my $magnetificationStep1=$templateStep1->getMagnification();
	
		my $templateStep2=LASAF::TEMPLATE::template->new(-template=>$STEP2FILE,-errorfile=>$outputFileImageJ,-step1=>$templateStep1);
		#my ($w,$h)=$templateStep2->getDimension();
		my $magnetificationStep2=$templateStep2->getMagnification();
		my $zoom=$templateStep2->getZoom();
		my $imageJ=ImageJ::ImageJ->new(-macro=>$PathToMacroBlackSearch,-image=>$NameImageFileStep1,-output=>$fileBlackList,  -conf=>$confFile);
	
		my @posCelulas=$templateStep1->readFileInPixels(-file=>$outputFileImageJ);
	

# Cambio realizado el 25 de junio	#####
		# my $widthBlackRectangle=($w/($magnetificationStep2/$magnetificationStep1))/$zoom;
		# my $heightBlackRectangle=($h/($magnetificationStep2/$magnetificationStep1))/$zoom;
		# my ($widthBlackRectangle,$heightBlackRectangle)=$templateStep2->getDimension();
		my $widthBlackRectangle=$templateStep2->meters2pixel(-meters=>$templateStep2->getFieldDistanceX());
		my $heightBlackRectangle=$templateStep2->meters2pixel(-meters=>$templateStep2->getFieldDistanceY());
##################################	#####
		print STDERR "\tMagnetification Step1: ".$magnetificationStep1."\n";
		print STDERR "\tMagnetification Step2: ".$magnetificationStep2."\n";
		print STDERR "\tDimension Step 1     : ".$w."X".$h."\n";
		print STDERR "\tZOOM Step1           : ".$templateStep1->getZoom()."\n";
		print STDERR "\tZOOM Step2           : ".$zoom."\n";
		
		print STDERR "\tBlack Size: w: ".$widthBlackRectangle."\th: ".$heightBlackRectangle."\n";
		
		for(my $i=0;$i<=$#posCelulas;$i++)
		{
			# Ponemos como type >> porque queremos que las posiciones de los cuadrados negros se vayan añadiendo al fichero de salida
			
			
			if($#sizeParticuleMax>0)
			{
				print STDERR "Threshold: ".$thresholdMin[$chamber]."\t".$thresholdMax[$chamber]."\n";
				my %error=$imageJ->runPipe(-width=>$widthBlackRectangle,
											-height=>$heightBlackRectangle,
											-pos=>$posCelulas[$i],
											-thresholdMin=>$thresholdMin[$chamber],
											-thresholdMax=>$thresholdMax[$chamber],
											-type=>'>>');
										}
			else
			{
				print STDERR "Threshold: ".$thresholdMin[0]."\t".$thresholdMax[0]."\n";
			
				my %error=$imageJ->runPipe(-width=>$widthBlackRectangle,
											-height=>$heightBlackRectangle,
											-pos=>$posCelulas[$i],
											-thresholdMin=>$thresholdMin[0],
											-thresholdMax=>$thresholdMax[0],
											-type=>'>>');
			}
			
			
			if($error{code}<0)
			{
				print STDERR "ERROR: ".$error{code}." MSG: ".$error{msg}." Rotate: ".$imageJ->{ROTATE}." Slide: Chamber: Z:\n";
				print "ERROR: ".$error{code}." MSG: ".$error{msg}." Rotate: ".$imageJ->{ROTATE}." Slide: Chamber: Z:\n";
			}
		}
	
		open(BLACK,$fileBlackList);	
		while(<BLACK>)
		{
			chomp;
			my @linea=split(/\s+/,$_);
			my $pointBlack={'x'=>$linea[0],'y'=>$linea[1],'w'=>$widthBlackRectangle,'h'=>$heightBlackRectangle};
			push @blackPoints,$pointBlack;
		}
		close BLACK;
		# unlink $fileBlackList;
		print STDERR "******FINISH SEARCH BLACKS*******************************************************\n";
	}
	# __END__
	####################################################################################################
	####################################################################################################
	####################################################################################################
	#Generamos el template con todas las posiciones
	my $template;
	my $gridXStep2;
	my $gridYStep2;
	if($error{code}>=0 &&  $create)
	{
		print STDERR "******CREATE TEMPLATE************************************************************\n";
		my $templateStep1=LASAF::TEMPLATE::template->new(-template=>$STEP1FILE,-errorfile=>$outputFileImageJ);
		print STDERR "CHAMBER: $chamber\n";
		my @iniPosition=$templateStep1->getStartPosition(-chamber=>$chamber);
		
		my $rows=$templateStep1->getRows();
		my $cols=$templateStep1->getCols();
		my ($sizeStep1w,$sizeStep1h)=$templateStep1->getDimension();
		
		my $magnetificationStep1=$templateStep1->getMagnification();
	
		my $templateStep2=LASAF::TEMPLATE::template->new(-template=>$STEP2FILE,-errorfile=>$outputFileImageJ);
		my ($w,$h)=$templateStep2->getDimension();
		my $zoom=$templateStep2->getZoom();
		my $magnetificationStep2=$templateStep2->getMagnification();
		

		
		print STDERR "DATA Step1: \n\tObjetivo Step1: ".$magnetificationStep1 ."x\n\tDIMENSION STEP 1: ".$sizeStep1w."X".$sizeStep1h." px\n";
		# print STDERR "Rows: $rows COLS: $cols\n";
		# 
		# 
		# print STDERR "\tCHAMBER:".$chamber."\n";
		
		print STDERR "\tINIT POSITION  STEP1 X:".$iniPosition[0]."\tY: ".$iniPosition[1]."\n";
		
		$iniPosition[0]=$iniPosition[0]-$templateStep1->{CONVERSION}->microns2meters(-microns=>$templateStep1->{MosaicSingleImage}->{$templateStep1->getMagnification()}->{w})/2;
		$iniPosition[1]=$iniPosition[1]-$templateStep1->{CONVERSION}->microns2meters(-microns=>$templateStep1->{MosaicSingleImage}->{$templateStep1->getMagnification()}->{h})/2;

	
		# print STDERR "--------".$templateStep1->{MosaicSingleImage}->{$templateStep1->getMagnification()}->{w}."\n";
		# print STDERR "--------".$templateStep1->{MosaicSingleImage}->{$templateStep1->getMagnification()}->{h}."\n";
		
		# Eliminamos el zoom de la ecuacion porque el inicio es el mismo con y sin zoom
		# $iniPosition[0]=$iniPosition[0]-$templateStep1->{CONVERSION}->microns2meters(-microns=>$templateStep1->{MosaicSingleImage}->{$templateStep1->getMagnification()})/(2*$zoom);
		# $iniPosition[1]=$iniPosition[1]-$templateStep1->{CONVERSION}->microns2meters(-microns=>$templateStep1->{MosaicSingleImage}->{$templateStep1->getMagnification()})/(2*$zoom);
		
		$template=LASAF::TEMPLATE::template->new(-errorfile=>$outputFileImageJ,
													-zoom=>$zoom,
													-dimension=>$w."X".$h,
													-template=>$STEP2FILE,
													-step1=>$templateStep1,
													-magnification=>$magnetificationStep2);
		print STDERR "\tZOOM STEP2: ".$zoom."x\n";
		print STDERR "DATA Step2: \n\tObjetivo Step2: ".$magnetificationStep2 ."x\n\tDIMENSION STEP 2: ".$w."X".$h." px\n";
		print STDERR "\tINIT POSITION  STEP2 X:".$iniPosition[0]."\tY: ".$iniPosition[1]."\n";
		
		my $coordenatesXML;
		my $z='true';
								   # image--L0000--S00--U00--V00--J01--X00--Y00--T0000--C00.ome.tif
		if($NameImageFileStep1 =~ /image--L0000--S00--U(\d+)--V(\d+)--J\d\d--X00--Y00--T0000(--Z00)?--C00.ome.tif/)
		{
			if($3 eq '')
			{
				$z='false';
			}
			my $name=basename($outputFileImageJ);
			my @name=split(/\./,$file);
			$coordenatesXML=$templatesdir."/".$name[0]."-U".$1."-V".$2;
		}
		if($coordenatesXML eq '')
		{
			my %error;
			$error{code}=-4;
			$error{msg}="ERROR IN NAME FILE FORMAT IMAGE IS: ".'image--L0000--S00--U(\d+)--V(\d+)--J00--X00--Y00--T0000(--Z00)?--C00.ome.tif';
			print STDERR "ERROR: $error{code} MSG: ".$error{msg}." Rotate: 0 Slide: 0 Chamber: 0 Z:0\n";		
			print "ERROR: $error{code} MSG: ".$error{msg}." Rotate: 0 Slide: 0 Chamber: 0 Z:0\n";
			exit 4;
		}
		print STDERR "FILE TEMPLATE: ".$coordenatesXML."\n";
		
		$template->readFile(-file=>$outputFileImageJ,-sort=>$sort);
		if($param_corregir_coordenadas)
		{
			 eval
			 {
				# my $tmp='/tmp/rotate_tmp.tif';
				# print STDERR "FICHERO: ".$NameImageFileStep1."\n";
				
				# my $p=Image::utils->new(-file=>$NameImageFileStep1);
		# 		$p->rotate();
		# 		$p->write(-file=>$tmp);

				# 
				my $p=Image::utils->new(-file=>$NameImageFileStep1);
				my @angles=$p->get_angles();

				$template->coor(-angles=>\@angles,-height=>$utils->getHeight(),-width=>$utils->getWidth());

				# unlink $tmp;
				# $template->coor(-width_with_stitching=>$sizes_images{WIDTH_WITH_STITCHING},
				# 			-height_with_stitching=>$sizes_images{HEIGHT_WITH_STITCHING},
				# 			-width_without_stitching=>$templateStep1->getMosaicImageWidth(),
				# 			-height_without_stitching=>$templateStep1->getMosaicImageHeight(),
				# 			-inix=>$iniPosition[0],-iniy=>$iniPosition[1],-angles=>\@angles);
			 }or do
			 {
				my $e;
			 	if($e = Exception::Class->caught('LASAF::TEMPLATE::template::CoorSQRTnegative'))
			 	{
			 		print STDERR 'ERROR: '.$e->error." EL PROCESO CONTINUA SIN REALZAR CORRECIONES\n";
			 	}
				print STDERR "ERROR: \n";
			};
		}
		
						# $template->coor(-width_with_stitching=>$sizes_images{WIDTH_WITH_STITCHING},
						# 				-height_with_stitching=>$sizes_images{HEIGHT_WITH_STITCHING},
						# 				-width_without_stitching=>$sizeStep1w*$cols,
						# 				-height_without_stitching=>$sizeStep1h*$rows);
		
		print STDERR "Paracentry STEP1 X: ".$parcentricity_correction{$magnetificationStep1}{X}."\n";			
		print STDERR "Paracentry STEP1 Y: ".$parcentricity_correction{$magnetificationStep1}{Y}."\n";	
		print STDERR "Paracentry STEP2 X: ".$parcentricity_correction{$magnetificationStep2}{X}."\n";			
		print STDERR "Paracentry STEP2 Y: ".$parcentricity_correction{$magnetificationStep2}{Y}."\n";	
				
		print STDERR "Paracentry Correction X: ".($parcentricity_correction{$magnetificationStep1}{X}-$parcentricity_correction{$magnetificationStep2}{X})."\n";
		print STDERR "Paracentry Correction Y: ".($parcentricity_correction{$magnetificationStep1}{Y}-$parcentricity_correction{$magnetificationStep2}{Y})."\n";
		print STDERR "FICHERO: ".$NameImageFileStep1."\n";
		
		system('cp '.$NameImageFileStep1.' '.$image_control_grid);

		
		($gridXStep2,$gridYStep2)=$template->createTemplateFromFile(-sort=>$sort,
																	-black=>\@blackPoints,
																	-file=>$outputFileImageJ,
																	-output_template=>$coordenatesXML,
																	-inix=>$iniPosition[0],-iniy=>$iniPosition[1],
																	-parcentricity_x=>$parcentricity_correction{$magnetificationStep1}{X}-$parcentricity_correction{$magnetificationStep2}{X},
																	-parcentricity_y=>$parcentricity_correction{$magnetificationStep1}{Y}-$parcentricity_correction{$magnetificationStep2}{Y},
																	-control_image=>$image_control_grid
																	);
	
		print STDERR "ERROR: $error{code} MSG: ".$template->getNameTemplate()." Rotate: $rotate Slide: $slide Chamber: $chamber Z:$z\n";		
		print "ERROR: $error{code} MSG: ".$template->getNameTemplate()." Rotate: $rotate Slide: $slide Chamber: $chamber Z:$z\n";
		print STDERR "\tNew Template: ".$template->getNameTemplate()."\n";
		print STDERR "\tGRID: ".$gridXStep2.", ".$gridYStep2."\n";
		print STDERR "******FINISH CREATE TEMPLATE*****************************************************\n";
	
	}
}
####################################################################################################
####################################################################################################
####################################################################################################

if($join)
{
	my $templateStep2=LASAF::TEMPLATE::template->new(-template=>$STEP2FILE,-errorfile=>$outputFileImageJ);
	my ($w,$h)=$templateStep2->getDimension();
	# my $templateStep1=LASAF::TEMPLATE::template->new(-template=>$STEP1FILE);
	# my ($w,$h)=split(/x|X/,$dimension);
	
	# my $grid_y=11;
	# my $grid_x=18;
	
	my ($permisos,$id,$user,$group,$sizem,$day,$mounth,$year,$file);
	my @dir=split(/\n/,`ls -ltr $MatrixScreenerImagesDir`);

	($permisos,$id,$user,$group,$sizem,$day,$mounth,$year,$file)=split(/\s+/,$dir[$#dir]);

	if($dirImagenes ne "NULL" && -e $MatrixScreenerImagesDir."/".$dirImagenes)
	{
		$file=$dirImagenes;
	}
	
	my $DIR=$MatrixScreenerImagesDir."/".$file;
	# if(-e $DIR."/grid.txt")
	# {
		# open(DAT,$DIR."/grid.txt");
		# my $dat=<DAT>;
		# chomp $dat;
		# my ($grid_x,$grid_y)=split(/\t/,$dat);
		
		print STDERR "STITCHING\n";
		print STDERR "\tDimension: ".$w."x".$h."\n";
		# print STDERR "\tGrid_X: ".$grid_x."\t Grid_Y: ".$grid_y."\n";
		print STDERR "\tDir: ".$DIR."\n";
		print STDERR "\tCONF:".$confFile."\n";
		ImageJ::stitching->new(-name=>$param_name_micro,-dirImages=>$DIR,-dimension=>$w."x".$h,-macrostitching=>$PathToMacroStitching,-codecolor=>$param_color_code);
	# }
	# else
	# {
	# 	print STDERR "ERROR: Tienes que ejecutar primero la opcion de create\n";
	# }
}
####################################################################################################
####################################################################################################
####################################################################################################

if($verbose==1)
{
	close STDERR;
}
if($redirect==1)
{
	close STDOUT;
}
# close STDERR;
__END__

