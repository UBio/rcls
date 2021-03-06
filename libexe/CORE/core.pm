package CORE::core;
$VERSION='1.0';
require Exporter;
@ISA=qw(Exporter);
@EXPORT=qw(get_all_images getInfoFromNameFileImage response);
use strict;

# dirImagenes:				Directorio del cual queremos extraer las Imagenes, es un parametro opcional, si no se le pasa coge el ultimo.
# MatrixScreenerImagesDir		Raiz donde se encuentran las imagenes, se suele coger de los fichero de configuracion.
# host						es la ip de la maquina que tiene conectada el micro, es opcional deprecated
# file						Me devuelve el working dir
# Retorno:
# @all_slide_and_chamber		un array con la lista de las imagenes encontradas en el direcotorio

sub get_all_images
{
	my %args=@_;
	my ($permisos,$id,$user,$group,$sizem,$day,$mounth,$year,$file);
	my $dirImagenes='';
	if(exists($args{-dirImagenes}))
	{
		$dirImagenes=$args{-dirImagenes};
	}
	my $MatrixScreenerImagesDir=$args{-MatrixScreenerImagesDir};
	my $host=$args{-host};
	
	my @all_slide_and_chamber;
	my $NameImageFileStep1;
	my @dir=split(/\n/,`ls -ltr $MatrixScreenerImagesDir`);
	($permisos,$id,$user,$group,$sizem,$day,$mounth,$year,$file)=split(/\s+/,$dir[$#dir]);

	if(exists($args{-dirImagenes}) && $dirImagenes ne "NULL" && -e $MatrixScreenerImagesDir."/".$dirImagenes)
	{
		$file=$dirImagenes;
	}
	
	if(exists($args{-file}))
	{
		${$args{-file}}=$file;
	}
	
	my $MyWorkDir="";
	if($host eq "null")
	{
		$MyWorkDir=$MatrixScreenerImagesDir;
	}
	else
	{
		
		$MyWorkDir=$MatrixScreenerImagesDir."/".$file;
	}
	opendir ( SLIDE, $MyWorkDir ) || die "1.Error in opening dir $MyWorkDir\n";
	while( (my $dirSlide = readdir(SLIDE)))
	{
		
		if($dirSlide !~ /^\./ && $dirSlide =~ /^Slide/i)
		{
			my $dirSlideAbsolute;
			
			opendir ( CHAMBER, $MyWorkDir."/".$dirSlide ) || die "2.Error in opening dir: ".$MyWorkDir."/".$dirSlide."\n";
			while( (my $dirChamber = readdir(CHAMBER)))
			{
				if($dirChamber !~ /^\./ && $dirChamber =~ /^Chamber/i)
				{
					my $pathToImage=$MyWorkDir."/".$dirSlide."/".$dirSlideAbsolute."/".$dirChamber;
					push @all_slide_and_chamber,get_all_tiff_from_directory(-dir=>$pathToImage);
					# if($dirChamber =~ /Chamber--U(\d+)--V00/i)
					# {
					# 	my $nChamber=$1;
					# 	
					# 	$NameImageFileStep1="image--L0000--S00--U".$nChamber."--V00--J00--X00--Y00--T0000--Z00--C00.ome.tif";
					# }
					# push (@all_slide_and_chamber,$pathToImage."/".$NameImageFileStep1);
				}
			}
			close CHAMBER;
		}
	}
	closedir SLIDE;
	return @all_slide_and_chamber;
}

sub get_all_tiff_from_directory
{
	my %args=@_;
	my @imagenes;
	opendir ( TIFF, $args{-dir} ) || die "No se puede abrir el directorio de imagenes $args{-dir} \n";
	while( (my $tiff = readdir(TIFF)))
	{
		if($tiff =~ /image--(.*)C00(\.ome)?\.tif/)
		{
			push (@imagenes,$args{-dir}."/".$tiff)
		}
	}
	close TIFF;
	return @imagenes;
}


sub getInfoFromNameFileImage
{
	my %args=@_;
	my $name=$args{-file};
	my %image;
	$image{ERROR}=0;
	my @file=split(/\/+/,$name);
	$image{FILE}=$file[$#file];
	$image{CHAMBER}=$file[$#file-1];
	$image{SLIDE}=$file[$#file-2];
	
	if($name =~ /image--L(\d+)--S(\d+)--U(\d+)--V(\d+)--J(\d\d)--X(\d+)--Y(\d+)--T(\d+)(--Z(\d+))?--C(\d+).ome.tif/)
	{
		$image{L}=$1;
		$image{S}=$2;
		$image{U}=$3;
		$image{V}=$4;
		$image{J}=$5;
		$image{X}=$6;
		$image{Y}=$7;
		$image{T}=$8;
		if($10)
		{
			$image{Z}=$9;
			$image{C}=$10;
		}
		else
		{
			$image{C}=$9;
		}
		return %image;
	}
	$image{ERROR}=-1;
	return %image;
}
sub response
{
	my (%args)=@_;

	my $json;
	$json='{';
	$json.='"code":'.$args{-code};
	$json.=',"msg":"'.$args{-msg}.'"';
	$json.=',"slide":"'.$args{-slide}.'"';
	$json.=',"chamber":"'.$args{-chamber}.'"';
	$json.=',"z":"'.$args{-z}.'"';
	$json.=',"rotate":"'.$args{-rotate}.'"';
	$json.=',"img":"'.$args{-img}.'"';
	$json.='}';
	
	print STDERR $json."\n";
	return $json;
}


















