#
#  template
#
#  Created by acarro on 2011-03-28.
#  Copyright (c) 2011 CNIO. All rights reserved.



package LASAF::TEMPLATE::template;
$VERSION='1.0';

use strict;
use XML::DOM;
use File::Basename;
use LASAF::UTILS::conversion;
use LASAF::UTILS::distances;
use Math::Round;
use Math::Trig;
use LOGS::simple;
use CORE::status qw(status_del_file  status_ini status_current);

use Exception::Class(
			'LASAF::TEMPLATE::template::CoorSQRTnegative' => {
					description=>'CoorSQRTnegative'
				}
			);
=head2 new

  Example    : template->new();
  Description: Es el constructor de la clase, abre los fichero xml y lrp para su posterior manejo.
  Params:	 : zoom, dimension, template
  Returntype : objeto de la clase template
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut

sub new
{
	my ($class,%args)=@_;
	my $this={};
	$this->{CONVERSION}=LASAF::UTILS::conversion->new();
	$this->{TEMPLATE}="";
	$this->{LABELX}=['','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','AA','BB','CC','DD','EE','FF'];
	$this->{LABELY}=[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52];
	$this->{ERRORFILE}=$args{-error_file};
	$this->{hWellMax}=0;
	$this->{wWellMax}=0;
	$this->{TOTALFIELDX}=3;
	$this->{TOTALFIELDY}=3;
	$this->{OVERLAPX}=0.1;
	$this->{OVERLAPY}=0.1;
	$this->{ZOOM}=1;
	$this->{WELLY}=1;
	$this->{NAME_MICRO}=$args{-name_micro};
	if(exists($args{-zoom}))
	{
		$this->{ZOOM}=$args{-zoom};
	}
	# if($this->{MAGNIFICATION} eq '63')
	# {
	# 	$this->{ZOOM}=1.2;
	# }
	
	#son los tamaños de las fotos sin quitarle el overlap
	

	my $log_rcls=LOGS::simple->new();
	
	$this->{DIMENSION}=$args{-dimension};
	if(exists($args{-step1}))
	{
		$this->{STEP1}=$args{-step1};
	}
	if(exists($args{-template}))
	{
	
		$this->{TEMPLATE}=$args{-template};
		my $file = basename($this->{TEMPLATE});
		my $dir = dirname($this->{TEMPLATE});

		if($file =~ /\{ScanningTemplate\}(.*)\.(xml)/)
		{
			$this->{NAME_TEMPLATE}=$1;
		}

		my $xml=new XML::DOM::Parser;
		$this->{xml} = $xml->parsefile($this->{TEMPLATE});
		# print STDERR "\tFILE READ: ".$this->{TEMPLATE}."\n";
		$log_rcls->print(-msg=>"FILE READ: ".$this->{TEMPLATE});
		$this->{root} = $this->{xml}->[0]->[0];
		my $xml=new XML::DOM::Parser;
		#print $dir."/\{ScanningTemplate\}".$this->{NAME_TEMPLATE}.".lrp"."\n";
		$this->{lrp} = $xml->parsefile($dir."/\{ScanningTemplate\}".$this->{NAME_TEMPLATE}.".lrp");
		$this->{lrp_root} = $this->{lrp}->[0]->[3];
		
	}
	else
	{
		# print STDERR "ERROR: No existe el template: ".$args{-template}."\n";
		$log_rcls->print(-msg=>"ERROR: No existe el template: ".$args{-template});
		exit -1;

	}
	
	bless($this);
	$this->{MAGNIFICATION}=$this->getMagnification();
	
	if(exists($args{-magnification}))
	{
		$this->{MAGNIFICATION}=$args{-magnification};
	}
	
	#$this->{MosaicSingleImage}={'63'=>246.03,'20'=>775, '40'=>387.5,'10'=>1555};
	my $cfg_confocal = Config::IniFiles->new( -file => $ENV{CONFOCAL_INI});
	$this->{CFG}=$cfg_confocal;
	$this->{MosaicSingleImage}=$this->readObjetives(-file=>$cfg_confocal->val( 'MICRO', 'objetives' ));
	# if(!exists($this->{MosaicSingleImage}->{$this->{MAGNIFICATION}}))
	# {
	# 	print STDERR "ERROR: Missing objetive ".$this->{MAGNIFICATION}."x in file ".$this->{CFG}->val( 'MICRO', 'objetives' )."\n";
	# 	# system("echo \"Missing objetive ".$this->{MAGNIFICATION}."x\" >".$this->{CFG}->val( 'FILES', 'outputFileImageJ' ));
	# 	exit -1
	# }
	if(exists($args{-template}))
	{
	
		if($this->isEnableCam() eq "false")
		{
			# print STDERR "CAM is DISABLED: ".$this->{NAME_TEMPLATE}."\n";
			$log_rcls->print(-msg=>"CAM is DISABLED: ".$this->{NAME_TEMPLATE});
			# exit;
		}
	}
	$log_rcls->close();
	return $this;
}

=head2 new

  Example    : template->new();
  Description: Comprueba el valor de la etiqueta <EnableCAM>true</EnableCAM>
  Params:	 : none
  Returntype : true o false
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub getScanWellArray
{
	my ($this)=@_;
	return $this->{root}->getElementsByTagName("ScanWellArray");
}
=head2 new

  Example    : template->new();
  Description: Comprueba el valor de la etiqueta <EnableCAM>true</EnableCAM>
  Params:	 : none
  Returntype : true o false
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub getScanFieldArray
{
	my ($this)=@_;
	return $this->{root}->getElementsByTagName("ScanFieldArray");
}
=head2 new

  Example    : template->new();
  Description: Comprueba el valor de la etiqueta <EnableCAM>true</EnableCAM>
  Params:	 : none
  Returntype : true o false
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub getScanWellData
{
	my ($this,%args)=@_;
	return $this->{root}->getElementsByTagName("ScanWellData")->item($args{-item});
}
=head2 new
  Example    : template->new();
  Description: Comprueba el valor de la etiqueta <EnableCAM>true</EnableCAM>
  Params:	 : none
  Returntype : true o false
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub getScanFieldData
{
	my ($this,%args)=@_;
	return $this->{root}->getElementsByTagName("ScanFieldData")->item($args{-item});
}
=head2 new

  Example    : template->new();
  Description: Comprueba el valor de la etiqueta <EnableCAM>true</EnableCAM>
  Params:	 : none
  Returntype : true o false
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub getLengthWellData
{
	my ($this)=@_;
	return $this->{root}->getElementsByTagName("ScanWellData")->getLength();
}

=head2 new

  Example    : template->new();
  Description: Comprueba el valor de la etiqueta <EnableCAM>true</EnableCAM>
  Params:	 : none
  Returntype : true o false
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub getLengthFieldData
{
	my ($this)=@_;
	return $this->{root}->getElementsByTagName("ScanFieldData")->getLength();
}


=head2 new

  Example    : template->new();
  Description: Comprueba el valor de la etiqueta <EnableCAM>true</EnableCAM>
  Params:	 : none
  Returntype : true o false
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub readObjetives
{
	my ($this,%args)=@_;
	my $objetives;
	# open(OBJ,$args{-file}) || die "Not open file objetives.ini: ".$!;
	# while(<OBJ>)
	# {
	# 	chomp;
	# 	if($_ !~ /^#/)
	# 	{
	# 		my($objetive,$sizew,$sizeh)=split(/\t/,$_);
	# 		$objetives->{$objetive}->{w}=$sizew;
	# 		$objetives->{$objetive}->{h}=$sizew;
	# 	}
	# }
	# close OBJ;
	my $ScanWellData=$this->{root}->getElementsByTagName("ScanWellData")->item(0);
	
	my $w=$ScanWellData->getAttribute("MosaicSingleImageWidth")*$this->getZoom();
	my $h=$ScanWellData->getAttribute("MosaicSingleImageHeight")*$this->getZoom();
	$w=$this->{CONVERSION}->meters2microns(-meters=>$w);
	$h=$this->{CONVERSION}->meters2microns(-meters=>$h);
	
	my $log_rcls=LOGS::simple->new();
	# print STDERR "\treadObjetives\tZOOM: ".$this->getZoom()." \tSIZE READ: ".$this->getMagnification()."\t".$w."\t".$h."\n";
	$log_rcls->print(-msg=>"readObjetives\tZOOM: ".$this->getZoom()." \tSIZE READ: ".$this->getMagnification()."\t".$w."\t".$h);
	$log_rcls->close();
	
	$objetives->{$this->getMagnification()}->{w}=$w;
	$objetives->{$this->getMagnification()}->{h}=$h;
	
	if(exists($this->{STEP1}))
	{
		my $ScanWellData=$this->{STEP1}->{root}->getElementsByTagName("ScanWellData")->item(0);
		my $w=$ScanWellData->getAttribute("MosaicSingleImageWidth")*$this->{STEP1}->getZoom();
		my $h=$ScanWellData->getAttribute("MosaicSingleImageHeight")*$this->{STEP1}->getZoom();
		$w=$this->{CONVERSION}->meters2microns(-meters=>$w);
		$h=$this->{CONVERSION}->meters2microns(-meters=>$h);
		
		$objetives->{$this->{STEP1}->getMagnification()}->{w}=$w;
		$objetives->{$this->{STEP1}->getMagnification()}->{h}=$h;
		
	}
	return $objetives;
}
=head2 new

  Example    : template->new();
  Description: Comprueba el valor de la etiqueta <EnableCAM>true</EnableCAM>
  Params:	 : none
  Returntype : true o false
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub isEnableCam()
{
	my ($this)=@_;
	my $value=$this->{root}->getElementsByTagName("Properties")->item(0)->getElementsByTagName("EnableCAM")->item(0)->getFirstChild->getNodeValue();
	return $value;
	# if($value eq "false")
	
}
=head2 new

  Example    : template->new();
  Description: Pone a true el cam, en el fichero xml <EnableCAM>true</EnableCAM>
  Params:	 : none
  Returntype : none
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub enableCam()
{
	my ($this)=@_;
	$this->{root}->getElementsByTagName("Properties")->item(0)->getElementsByTagName("EnableCAM")->item(0)->getFirstChild->setNodeValue("true");
}
=head2 new

  Example    : template->new();
  Description: Pone a false el cam, en el fichero xml <EnableCAM>false</EnableCAM>
  Params:	 : none
  Returntype : none
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub disableCam()
{
	my ($this)=@_;
	$this->{root}->getElementsByTagName("Properties")->item(0)->getElementsByTagName("EnableCAM")->item(0)->getFirstChild->setNodeValue("false");
}
=head2 new

  Example    : template->new();
  Description: Retorna el numero de filas que tiene cada well
  Params:	 : none
  Returntype : int
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub getRows()
{
	my ($this)=@_;
	return $this->{root}->getElementsByTagName("Properties")->item(0)->getElementsByTagName("CountOfScanFieldsY")->item(0)->getFirstChild->getNodeValue;
}
=head2 new

  Example    : template->new();
  Description: Retorna el numero de filas que tiene cada well
  Params:	 : none
  Returntype : int
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub getScanWellXData
{
	my ($this,%args)=@_;
	return $this->{root}->getElementsByTagName("ScanWellData")->item($args{-item})->getAttribute('WellX');
}

sub getMosaicImageHeight
{
	my ($this,%args)=@_;
	return $this->{root}->getElementsByTagName("ScanWellData")->item($args{-item})->getAttribute('MosaicImageHeight');
}

sub getMosaicImageWidth
{
	my ($this,%args)=@_;
	return $this->{root}->getElementsByTagName("ScanWellData")->item($args{-item})->getAttribute('MosaicImageWidth');
}


sub getYCountOfFields
{
	my ($this,%args)=@_;
	return $this->{root}->getElementsByTagName("ScanWellData")->item($args{-item})->getAttribute('YCountOfFields');
}

sub getXCountOfFields
{
	my ($this,%args)=@_;
	return $this->{root}->getElementsByTagName("ScanWellData")->item($args{-item})->getAttribute('XCountOfFields');
}


=head2 new

  Example    : template->new();
  Description: Retorna el numero de columnas que tiene cada well
  Params:	 : none
  Returntype : int
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub getCols()
{
	my ($this)=@_;
	return $this->{root}->getElementsByTagName("Properties")->item(0)->getElementsByTagName("CountOfScanFieldsX")->item(0)->getFirstChild->getNodeValue;
}
=head2 new

  Example    : template->new();
  Description: Retorna el numero de columnas que tiene cada well
  Params:	 : none
  Returntype : int
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub getRows()
{
	my ($this)=@_;
	return $this->{root}->getElementsByTagName("Properties")->item(0)->getElementsByTagName("CountOfScanFieldsY")->item(0)->getFirstChild->getNodeValue;
}
=head2 new

  Example    : template->new();
  Description: Retorna la distancia entre un field y el siguiente a la izquierda dentro de una misma well
  Params:	 : none
  Returntype : float
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub getFieldDistanceX()
{
	my ($this)=@_;
	my $ScanFieldStageDistanceX=$this->{root}->getElementsByTagName("Properties")->item(0)->getElementsByTagName("ScanFieldStageDistanceX")->item(0)->getFirstChild->getNodeValue;
	if($ScanFieldStageDistanceX!=0)
	{
		return $this->{CONVERSION}->microns2meters(-microns=>$ScanFieldStageDistanceX);
	}
	else
	{
		my $log_rcls=LOGS::simple->new();
		$log_rcls->print(-msg=>"WARNING:Recalculating value ScanFieldStageDistanceX");
		$log_rcls->close();
		# print STDERR "WARNING:Recalculating value ScanFieldStageDistanceX\n";
		
		my $MosaicImageWidth=$this->getMosaicImageWidth();
		my $XCountOfFields=$this->getXCountOfFields();
		
		return $MosaicImageWidth/($XCountOfFields-1)
	}
	 
}
=head2 new

  Example    : template->new();
  Description: Retorna la distancia entre un field y el siguiente hacia abajo dentro de una misma well
  Params:	 : none
  Returntype : int
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub getFieldDistanceY()
{
	my ($this)=@_;

	my $ScanFieldStageDistanceY=$this->{root}->getElementsByTagName("Properties")->item(0)->getElementsByTagName("ScanFieldStageDistanceY")->item(0)->getFirstChild->getNodeValue;
	if($ScanFieldStageDistanceY!=0)
	{
		return $this->{CONVERSION}->microns2meters(-microns=>$ScanFieldStageDistanceY);
	}
	else
	{
		my $log_rcls=LOGS::simple->new();
		$log_rcls->print(-msg=>"WARNING:Recalculating value ScanFieldStageDistanceY");
		$log_rcls->close();
		# print STDERR "WARNING:Recalculating value ScanFieldStageDistanceY\n";
		my $MosaicImageHeight=$this->getMosaicImageHeight();
		my $YCountOfFields=$this->getYCountOfFields();
		
		return $MosaicImageHeight/($YCountOfFields-1)
	}
	 

} 
=head2 new

  Example    : template->new();
  Description: establece la distancia entre un field y el siguiente a la derecha dentro de una misma well
  Params:	 : none
  Returntype : none
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub setFieldDistanceX()
{
	my ($this,%args)=@_;
	$this->{root}->getElementsByTagName("Properties")->item(0)->getElementsByTagName("ScanFieldStageDistanceX")->item(0)->getFirstChild->setNodeValue($args{-dx});
}
=head2 new

  Example    : template->new();
  Description: establece la distancia entre un field y el siguiente hacia abajo dentro de una misma well
  Params:	 : none
  Returntype : none
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub setFieldDistanceY()
{
	my ($this,%args)=@_;
	$this->{root}->getElementsByTagName("Properties")->item(0)->getElementsByTagName("ScanFieldStageDistanceY")->item(0)->getFirstChild->setNodeValue($args{-dy});;
}
=head2 new

  Example    : template->new();
  Description: Returna la posicion del primer field y del primer well
  Params:	 : none
  Returntype : none
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable
=cut
sub getFirstFieldPostion()
{
	my ($this)=@_;
	my $x=$this->{root}->getElementsByTagName("ScanFieldData")->item(0)->getElementsByTagName("FieldXCoordinate")->item(0)->getFirstChild->getNodeValue;
	my $y=$this->{root}->getElementsByTagName("ScanFieldData")->item(0)->getElementsByTagName("FieldYCoordinate")->item(0)->getFirstChild->getNodeValue;
	return [$x,$y];
}
=head2 new

  Example    : template->new();
  Description: Returna todas las posciones
  Params:	 : none
  Returntype : none
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub getScanFiels()
{
	my ($this)=@_;
	my $size=$this->{root}->getElementsByTagName("ScanFieldData")->getLength();
	for(my $nfield=0;$nfield<$size;$nfield++)
	{
		my $field=$this->{root}->getElementsByTagName("ScanFieldData")->item($nfield);
		my $x=$this->{root}->getElementsByTagName("ScanFieldData")->item($nfield)->getElementsByTagName("FieldXCoordinate")->item(0)->getFirstChild->getNodeValue;
		my $y=$this->{root}->getElementsByTagName("ScanFieldData")->item($nfield)->getElementsByTagName("FieldYCoordinate")->item(0)->getFirstChild->getNodeValue;
		# print $this->{root}->getElementsByTagName("ScanFieldData")->item($nfield)->getAttribute("FieldX")."\t".$this->{root}->getElementsByTagName("ScanFieldData")->item($nfield)->getAttribute("FieldY")."\t";
		# print $x."\t".$y."\n";
	}
}
=head2 new

  Example    : template->new();
  Description: Returna el nanem del template leido
  Params:	 : none
  Returntype : none
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub getNameTemplate()
{
	my ($this)=@_;
	return $this->{NAME_TEMPLATE};
}
=head2 new

  Example    : template->new();
  Description: Returna el nanem del template leido
  Params:	 : none
  Returntype : none
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub getOwner()
{
	my ($this)=@_;
	return $this->{root}->getOwnerDocument();
}
=head2 new

  Example    : template->new();
  Description: Retorna la posicion desde donde se va a empezar a escanear
  Params:	 : none
  Returntype : none
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub getJobName_xml
{
	my ($this)=@_;
	my $ScanFieldData=$this->{root}->getElementsByTagName("ScanFieldData");
	return $ScanFieldData->item(0)->getAttribute ("JobName");
}
=head2 new

  Example    : template->new();
  Description: Retorna la posicion desde donde se va a empezar a escanear
  Params:	 : none
  Returntype : none
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub getJobId_xml
{
	my ($this)=@_;
	my $ScanFieldData=$this->{root}->getElementsByTagName("ScanFieldData");
	return $ScanFieldData->item(0)->getAttribute ("JobId");
}

=head2 new

  Example    : template->getBlockIDFromJobName_lrp();
  Description: Devuelve el BlockId del job seleccionado en el xml a partir de su job id y job name del xml
  Params:	 : none
  Returntype : none
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub getBlockIDFromJobName_lrp
{
	my ($this,%args)=@_;
	my $element_list=$this->{lrp_root}->getElementsByTagName("LDM_Block_Sequence_Element_List")->[0];
	my $element=$element_list->getElementsByTagName('LDM_Block_Sequence_Element');
	my $Job_id_xml=$this->getJobId_xml();
	my $Job_name_xml=$this->getJobName_xml();
	for(my $ielement=0;$ielement<$element->getLength();$ielement++)
	{
		my $blockid=$element->[$ielement]->getAttribute('BlockID');
		if($blockid == $Job_id_xml)
		{
			my $block_sequence=$element->[$ielement]->getElementsByTagName('LDM_Block_Sequence');
						
			for(my $iblock=0;$iblock<$block_sequence->getLength();$iblock++)
			{
				
				my $block_name=$block_sequence->[$iblock]->getAttribute('BlockName');
				# print STDERR "BlockID: $blockid\t$Job_id_xml\t$block_name\t$Job_name_xml\n";
				
				if($block_name eq $Job_name_xml)
				{
					my $block_id_lrp=$block_sequence->[$iblock]->getElementsByTagName('LDM_Block_Sequence_Element')->[0]->getAttribute('BlockID');
					return $block_id_lrp;
				}
			}
			if($block_sequence->getLength()<=0)
			{
				return $blockid;
			}
		}
	}

}
=head2 new

  Example    : template->new();
  Description: Retorna la posicion desde donde se va a empezar a escanear
  Params:	 : none
  Returntype : none
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub getStartPosition()
{
	my ($this,%args)=@_;
	my ($currentX,$currentY);
	# my $currentX=$this->{root}->getElementsByTagName("Properties")->item(0)->getElementsByTagName("ScanFieldStageStartPositionX")->item(0)->getFirstChild->getNodeValue;
	# my $currentY=$this->{root}->getElementsByTagName("Properties")->item(0)->getElementsByTagName("ScanFieldStageStartPositionY")->item(0)->getFirstChild->getNodeValue;

	my $ScanFieldData=$this->{root}->getElementsByTagName("ScanFieldData");
	my $totalFiels=scalar(@{$ScanFieldData});
	$args{-chamber}+=0;
	my $iwell=-1;
	for(my $ifield=0;$ifield<$totalFiels;$ifield++)
	{
		my $xfield=$ScanFieldData->item($ifield)->getAttribute ("FieldX");
		my $yfield=$ScanFieldData->item($ifield)->getAttribute ("FieldY");
		if($xfield==1 && $yfield==1)
		{
			$iwell++;
		}
		if($iwell == $args{-chamber})
		{
			$currentX=$ScanFieldData->item($ifield)->getElementsByTagName("FieldXCoordinate")->item(0)->getFirstChild->getNodeValue;
			$currentY=$ScanFieldData->item($ifield)->getElementsByTagName("FieldYCoordinate")->item(0)->getFirstChild->getNodeValue;
			return ($currentX,$currentY);
		}
	}
	
	# $currentX=$this->{CONVERSION}->microns2meters(-microns=>$currentX);
	# $currentY=$this->{CONVERSION}->microns2meters(-microns=>$currentY);
	return ($currentX,$currentY);
}
=head2 new

  Example    : template->new();
  Description: establece  la posicion desde donde se va a empezar a escanear
  Params:	 : none
  Returntype : none
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub setStartPosition()
{
	my ($this,%args)=@_;
	$this->{root}->getElementsByTagName("Properties")->item(0)->getElementsByTagName("ScanFieldStageStartPositionX")->item(0)->getFirstChild->setNodeValue($args{-x});
	$this->{root}->getElementsByTagName("Properties")->item(0)->getElementsByTagName("ScanFieldStageStartPositionY")->item(0)->getFirstChild->setNodeValue($args{-y});

}
=head2 new

  Example    : template->new();
  Description: retorna el aumento del objetivo seleccionado
  Params:	 : none
  Returntype : none
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub getMagnification
{
	my ($this,%args)=@_;
	if($this->{lrp_root}->getElementsByTagName("ATLConfocalSettingDefinition")->[0])
	{
		return $this->{lrp_root}->getElementsByTagName("ATLConfocalSettingDefinition")->[0]->getAttribute("Magnification");
	}
	else
	{
		return $this->{lrp_root}->getElementsByTagName("ATLCameraSettingDefinition")->[0]->getAttribute("Magnification");
	}
}
=head2 new

  Example    : template->pixel2meters();
  Description: tranforma pixel a metros usando una matriz de conversion sacada 
				La anchura se saca de un matriz de tranformacion con la manificacion del paso anterior
				y el numero de pixel
				 son los pixel de las fotos del paso de baja resolucion
  Params:	 : none
  Returntype : none
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub pixel2meters
{
	my ($this,%args)=@_;
	# if(!exists($this->{MosaicSingleImage}->{$this->{STEP1}->getMagnification()}))
	# {
	# 	# system("echo \"Missing objetive ".$this->{STEP1}->getMagnification()."x\" >".$this->{CFG}->val( 'FILES', 'outputFileImageJ' ));
	# 	print STDERR "ERROR: Missing objetive ".$this->{STEP1}->getMagnification()."x in file ".$this->{CFG}->val( 'MICRO', 'objetives' )."\n";
	# 	exit -1;
	# }
	 # print STDERR "-----------------------------------------------------------------\n";
	# print STDERR $this->{STEP1}->getMagnification()."\t".$this->{MosaicSingleImage}->{$this->{STEP1}->getMagnification()}->{w}."\n";
	my $width=$this->{CONVERSION}->microns2meters(-microns=>$this->{MosaicSingleImage}->{$this->{STEP1}->getMagnification()}->{w});
	# print STDERR "Mis Pixel: ".$args{-pixel}."\n";
	# print STDERR "MosaicSingleImage: ".$width."\n";
	# print STDERR "Dimension:".$this->{STEP1}->getDimension()."\n";
	# print STDERR "pixel: ".$args{-pixel}."*".$width."/".$this->{STEP1}->getDimension()."\n";
	# print STDERR ((($args{-pixel})*$width)/$this->{STEP1}->getDimension())."\n";
	my ($w,$h)=$this->{STEP1}->getDimension();
	# print STDERR "Dimension: $w\n";
	my $result=(($args{-pixel})*$width)/$w;
	# print STDERR "Result: $result\n";
	# print STDERR "-----------------------------------------------------------------\n";
	return $result;
	#return (($args{-pixel})*$width)/$this->{STEP1}->getDimension();
}
=head2 new

  Example    : template->meters2pixel();
  Description: tranforma pixel a metros usando una matriz de conversion sacada 
				La anchura se saca de un matriz de tranformacion con la manificacion del paso anterior
				y el numero de pixel
				 son los pixel de las fotos del paso de baja resolucion
  Params:	 : none
  Returntype : none
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub meters2pixel
{
	my ($this,%args)=@_;
	my $width=$this->{CONVERSION}->microns2meters(-microns=>$this->{MosaicSingleImage}->{$this->{STEP1}->getMagnification()}->{w});
	my ($w,$h)=$this->{STEP1}->getDimension();
	my $result=(($args{-meters})*$w)/$width;
	return $result;
}
=head2 new

  Example    : template->readFile();
  Description: lee el fichero de posiciones la x,y ,w y h de cada celula detectada en metros
  Params:	 : none
  Returntype : none
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub readFile
{
	my ($this,%args)=@_;
	my $file=$args{-file};
	open(DAT,$file);
	my $head=<DAT>;
	my @pos;
	my ($index,$x,$y,$width,$height);
	
	while(<DAT>)
	{
		chomp;
		($index,$x,$y,$width,$height)=split(/\s+/,$_);
		$x=$this->pixel2meters(-pixel=>$x);
		$y=$this->pixel2meters(-pixel=>$y);

		$width=$this->pixel2meters(-pixel=>$width);
		$height=$this->pixel2meters(-pixel=>$height);
		if($width==0)
		{
			$width=$this->pixel2meters(-pixel=>1);
		}
		if($height==0)
		{
			$height=$this->pixel2meters(-pixel=>1);
		}
		
		
		
		
		$pos[$index-1]={index=>$index,x=>$x,y=>$y,h=>$height,w=>$width,xo=>0,yo=>0};
		
		if($height>$this->{hWellMax})
		{
			$this->{hWellMax}=$height;
		}
		if($width>$this->{wWellMax})
		{
			$this->{wWellMax}=$width;
		}
		
	}
	# print STDERR "\thWellMax: ".$this->{hWellMax}."\twWellMax: ".$this->{wWellMax}."\n";
	my $log_rcls=LOGS::simple->new();
	$log_rcls->print(-msg=>"hWellMax: ".$this->{hWellMax}."\twWellMax: ".$this->{wWellMax});
	$log_rcls->close();
	
	# $this->{hWellMax}=$this->pixel2meters(-pixel=>$this->{hWellMax});
	# $this->{wWellMax}=$this->pixel2meters(-pixel=>$this->{wWellMax});
	close DAT;
	
	if($args{-sort} eq "true")
	{
		my $sortArrayDistances=LASAF::UTILS::distances->sort(-data=>\@pos);
		my @aux;
		for(my $i=0;$i<=$#pos;$i++)
		{
			push @aux,$pos[$sortArrayDistances->{CAMINO}->[$i]];
		}
			$this->{POS}=\@pos;
		return @aux;
		$sortArrayDistances->showCamino();
	}
	$this->{POS}=\@pos;
	return @pos;
}

=head2 new

  Example    : template->readFilePixels();
  Description: lee el fichero de posiciones la x,y ,w y h de cada celula detectada 
  Params:	 : none
  Returntype : none
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub readFileInPixels
{
	my ($this,%args)=@_;
	my $file=$args{-file};
	open(DAT,$file);
	my $head=<DAT>;
	my @pos;
	
	while(<DAT>)
	{
		chomp;
		my ($index,$x,$y,$width,$height)=split(/\s+/,$_);
		if($width==0)
		{
			$width=$this->pixel2meters(-pixel=>1);
		}
		if($height==0)
		{
			$height=$this->pixel2meters(-pixel=>1);
		}
		$pos[$index-1]={index=>$index,x=>$x,y=>$y,h=>$height,w=>$width};

		
	}
	close DAT;
	return @pos;
}
=head2 new

  Example    : template->new();
  Description: establece el numero total de campos numero de well*fields de cada well
  Params:	 : none
  Returntype : none
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub setTotalFields
{
	my ($this,%args)=@_;
	$this->{root}->getElementsByTagName("Properties")->item(0)->setAttribute("TotalCountOfFields",$args{-fields});
}
=head2 new

  Example    : template->new();
  Description: establece el numero total de campos numero de well*fields de cada well
  Params:	 : none
  Returntype : none
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub getTotalFields
{
	my ($this,%args)=@_;
	$this->{root}->getElementsByTagName("Properties")->item(0)->getAttribute("TotalCountOfFields");
}
=head2 new

  Example    : template->new();
  Description: establece el numero total de wells
  Params:	 : none
  Returntype : none
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub setTotalWells
{
	my ($this,%args)=@_;
	$this->{root}->getElementsByTagName("Properties")->item(0)->setAttribute("TotalCountOfWells",$args{-wells});
}
=head2 new

  Example    : template->new();
  Description: establece el numero total de wells
  Params:	 : none
  Returntype : none
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub getTotalWells
{
	my ($this)=@_;
	$this->{root}->getElementsByTagName("Properties")->item(0)->getAttribute("TotalCountOfWells");
}

=head2 new

  Example    : template->new();
  Description: establece el numero totla de trabajos 
  Params:	 : none
  Returntype : none
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub getTotalJobs
{
	my ($this,%args)=@_;
	$this->{root}->getElementsByTagName("Properties")->item(0)->getAttribute("TotalAssignedJobs");
}
=head2 new

  Example    : template->new();
  Description: establece el numero totla de trabajos 
  Params:	 : none
  Returntype : none
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub setTotalJobs
{
	my ($this,%args)=@_;
	$this->{root}->getElementsByTagName("Properties")->item(0)->setAttribute("TotalAssignedJobs",$args{-jobs});
}

=head2 new

  Example    : template->new();
  Description: establece el numero de fields en x e y de un well 
  Params:	 : none
  Returntype : none
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub setCountOfScanFields
{
	my ($this,%args)=@_;
	# <CountOfScanFieldsX>2</CountOfScanFieldsX>
    # <CountOfScanFieldsY>2</CountOfScanFieldsY>
	$this->{root}->getElementsByTagName("Properties")->item(0)->getElementsByTagName("CountOfScanFieldsX")->item(0)->getFirstChild->setNodeValue($args{-fieldsx});
	$this->{root}->getElementsByTagName("Properties")->item(0)->getElementsByTagName("CountOfScanFieldsY")->item(0)->getFirstChild->setNodeValue($args{-fieldsy});
}
=head2 new

  Example    : template->new();
  Description: establece el numero de wells en x e y de un template 
  Params:	 : none
  Returntype : none
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub setCountOfWells
{
	my ($this,%args)=@_;
	#     <CountOfWellsX>2</CountOfWellsX>
	#     <CountOfWellsY>2</CountOfWellsY>
	my $wellx=$args{-wells};
	my $welly=$this->{WELLY};
	$this->{root}->getElementsByTagName("Properties")->item(0)->getElementsByTagName("CountOfWellsX")->item(0)->getFirstChild->setNodeValue($wellx);
	$this->{root}->getElementsByTagName("Properties")->item(0)->getElementsByTagName("CountOfWellsY")->item(0)->getFirstChild->setNodeValue($welly);
}
=head2 new

  Example    : template->new();
  Description: establece la distancia entre los wells 
  Params:	 : none
  Returntype : none
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub setWellsDistance
{
	my ($this,%args)=@_;
	# <WellsDistanceX>2</WellsDistanceX>
	#     <WellsDistanceY>2</WellsDistanceY>
	my $wellx=$args{-wellsX};
	my $welly=$args{-wellsY};
	$this->{root}->getElementsByTagName("Properties")->item(0)->getElementsByTagName("WellsDistanceX")->item(0)->getFirstChild->setNodeValue($wellx);
	$this->{root}->getElementsByTagName("Properties")->item(0)->getElementsByTagName("WellsDistanceY")->item(0)->getFirstChild->setNodeValue($welly);
}


=head2 new

  Example    : template->setScanFieldDiameter();
  Description: establece la distancia entre los wells 
  Params:	 : none
  Returntype : none
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub setScanFieldDiameter
{
	my ($this,%args)=@_;
	my $diameter=$args{-diameter};
	$this->{root}->getElementsByTagName("Properties")->item(0)->getElementsByTagName("ScanFieldDiameter")->item(0)->getFirstChild->setNodeValue($diameter);
}

=head2 new

  Example    : template->new();
  Description: calcula el numero de wells en x e y
  Params:	 : none
  Returntype : none
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub TotalWellsToWellXY
{
	my ($this,%args)=@_;
	my $wellx=round(sqrt($args{-totalWells}));
	my $welly=round($args{-totalWells}/$wellx);
	
	$this->{WELLX}=$args{-totalWells};
	$this->{WELLY}=1;
	# print "WX: ".$wellx."\tWY: ".$welly."\n";
	
}
=head2 new

  Example    : template->new();
  Description: establece la altura de los wells 
  Params:	 : none
  Returntype : none
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub setHeightWell()
{
	my ($this,%args)=@_;
	$this->{root}->getElementsByTagName("Properties")->item(0)->getElementsByTagName("FixHeigthOfWell")->item(0)->getFirstChild->setNodeValue($args{-h});
}
=head2 new

  Example    : template->new();
  Description: establece la anchura de los wells 
  Params:	 : none
  Returntype : none
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub setWidthWell()
{
	my ($this,%args)=@_;
	$this->{root}->getElementsByTagName("Properties")->item(0)->getElementsByTagName("FixWidthOfWell")->item(0)->getFirstChild->setNodeValue($args{-w});
}
=head2 new

  Example    : template->new();
  Description: lee el zoom del fichero lrp
  Params:	 : none
  Returntype : none
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub getZoom
{
	my ($this,%args)=@_;
	
	if($this->{lrp_root}->getElementsByTagName("ATLConfocalSettingDefinition")->[1])
	{
		return $this->{lrp_root}->getElementsByTagName("ATLConfocalSettingDefinition")->[1]->getAttribute("Zoom");
	}
	else
	{
		return 1;
	}
}

=head2 new

  Example    : template->getBlockID();
  Description: lee el BlockId  el BlockName del fichero LRP
  Params:	 : none
  Returntype : none
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub getAllInfoObjectives
{
	my ($this,%args)=@_;
	my %InfoObjectives;

	my $LDM_Block_Sequence_Block=$this->{lrp_root}->getElementsByTagName("LDM_Block_Sequence_Block");
	
	for(my $iLDM_Block_Sequence_Block=0;$iLDM_Block_Sequence_Block<$LDM_Block_Sequence_Block->getLength();$iLDM_Block_Sequence_Block++)
	{	
		my $blockid=$LDM_Block_Sequence_Block->[$iLDM_Block_Sequence_Block]->getAttribute("BlockID");
		# print STDERR "BlockID: ".$blockid."\n";
		
		my $LDM_Block=$LDM_Block_Sequence_Block->[$iLDM_Block_Sequence_Block]->getElementsByTagName("LDM_Block");
		if(!$LDM_Block)
		{
			$LDM_Block=$LDM_Block_Sequence_Block->[$iLDM_Block_Sequence_Block]->getElementsByTagName("LDM_Block_Sequential");
		}
		for(my $iLDM_Block=0;$iLDM_Block<$LDM_Block->getLength();$iLDM_Block++)
		{
			my $block_name=$LDM_Block->[$iLDM_Block]->getAttribute('BlockName');
			# print STDERR "\tNAME: ".$block_name."\t";
			
			my $confocalSettings=$LDM_Block->[$iLDM_Block]->getElementsByTagName("ATLConfocalSettingDefinition");
			if($confocalSettings->getLength()<=0)
			{
				$confocalSettings=$LDM_Block->[$iLDM_Block]->getElementsByTagName("ATLCameraSettingDefinition");
			}
			my $magnification=$confocalSettings->[0]->getAttribute("Magnification");
			my $ObjectiveNumber=$confocalSettings->[0]->getAttribute("ObjectiveNumber");
			
			# print STDERR "Magnification: ".$magnification."\tObjective Number: $ObjectiveNumber\n";
			$InfoObjectives{$ObjectiveNumber}{$block_name}=$magnification;
		}	
	}
	return %InfoObjectives;
}

=head2 new

  Example    : template->getBlockID();
  Description: lee el BlockId  el BlockName del fichero LRP
  Params:	 : none
  Returntype : none
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub getBlockID
{
	my ($this,%args)=@_;
	my %jobs;
	my $size=$this->{lrp_root}->getElementsByTagName("LDM_Block_Sequence_Block")->getLength();
	for(my $nfield=0;$nfield<$size;$nfield++)
	{
		my $blockid=$this->{lrp_root}->getElementsByTagName("LDM_Block_Sequence_Block")->[$nfield]->getAttribute("BlockID");
		# my $name=$this->{lrp_root}->getElementsByTagName("LDM_Block_Sequence_Block")->[$nfield]->getElementsByTagName("LDM_Block")->[0]->getAttribute("BlockName");
		
		my $name;
		if($this->{lrp_root}->getElementsByTagName("LDM_Block_Sequence_Block")->[$nfield]->getElementsByTagName("LDM_Block")->[0])
		{
			$name=$this->{lrp_root}->getElementsByTagName("LDM_Block_Sequence_Block")->[$nfield]->getElementsByTagName("LDM_Block")->[0]->getAttribute("BlockName");
		}
		else
		{
			# trabajos batch
			if($this->{lrp_root}->getElementsByTagName("LDM_Block_Sequence_Block")->[$nfield]->getElementsByTagName("LDM_Block_Sequential")->[0])
			{
				$name=$this->{lrp_root}->getElementsByTagName("LDM_Block_Sequence_Block")->[$nfield]->getElementsByTagName("LDM_Block_Sequential")->[0]->getAttribute("BlockName");			
			}
			# patrones
			if($this->{lrp_root}->getElementsByTagName("LDM_Block_Sequence_Block")->[$nfield]->getElementsByTagName("LDM_Block")->[0])
			{
				$name=$this->{lrp_root}->getElementsByTagName("LDM_Block_Sequence_Block")->[$nfield]->getElementsByTagName("LDM_Block")->[0]->getAttribute("BlockName");			
			}
			
		}
		
		if($name =~ /AF Job/)
		{
			$jobs{"AF"}={ID=>$blockid,NAME=>$name};
		}
		else
		{
			$jobs{"JOB"}={ID=>$blockid,NAME=>$name};
		}
	}
	return %jobs;
}
=head2 new

  Example    : template->setZoom();
  Description: Esta funcion modfica el zoom dentro del fichero lrp
  Returntype : String
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
# sub setZoom
# {
# 	my ($this,%args)=@_;
# 	my $ATLConfocalSettingDefinition=$this->{lrp_root}->getElementsByTagName("ATLConfocalSettingDefinition");
# 	for(my $i=0;$i<$ATLConfocalSettingDefinition->getLength();$i++)
# 	{
# 		$ATLConfocalSettingDefinition->[$i]->setAttribute("Zoom",$args{-zoom});
# 		$ATLConfocalSettingDefinition->[$i]->setAttribute("OpticalZoom",$args{-zoom});
# 	}	
# }

=head2 new

  Example    : template->setDimension();
  Description: modifica la outDimension y inDimension dentro del fichero lrp
  Returntype : String
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
# sub setDimension
# {
# 	
# 	my ($this,%args)=@_;
# 	my ($inDimension,$outDimension)=split(/X|x/,$args{-dimension});
# 	my $ATLConfocalSettingDefinition=$this->{lrp_root}->getElementsByTagName("ATLConfocalSettingDefinition");
# 	my $LDM_Block=$this->{lrp_root}->getElementsByTagName("LDM_Block");
# 	
# 	for(my $i=0;$i<$ATLConfocalSettingDefinition->getLength();$i++)
# 	{
# 		my $nameJob;
# 		if($LDM_Block->[$i])
# 		{
# 			$nameJob=$LDM_Block->[$i]->getAttribute("BlockName");
# 		}
# 		else
# 		{
# 			$nameJob=$this->{lrp_root}->getElementsByTagName("LDM_Block_Sequential")->[0]->getAttribute("BlockName");
# 		}
# 		if($nameJob ne "AF Job")
# 		{
# 			$ATLConfocalSettingDefinition->[$i]->setAttribute("InDimension",$inDimension);
# 			$ATLConfocalSettingDefinition->[$i]->setAttribute("OutDimension",$outDimension);
# 		}
# 	}
# 	
# }

=head2 new

  Example    : template->getDimension();
  Description: modifica la outDimension y inDimension dentro del fichero lrp
  Returntype : String
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub getDimension
{
	
	my ($this)=@_;
	my $block_id_lrp=$this->getBlockIDFromJobName_lrp();
	my $sequence_block=$this->{lrp_root}->getElementsByTagName('LDM_Block_Sequence_Block');
	my $w;
	my $h;
	
	for(my $iseq=0;$iseq<$sequence_block->getLength();$iseq++)
	{
		my $id=$sequence_block->[$iseq]->getAttribute('BlockID');
		if($block_id_lrp==$id)
		{
			my $ATLConfocalSettingDefinition=$sequence_block->[$iseq]->getElementsByTagName("ATLConfocalSettingDefinition");
			my $confocal='true';
			if($ATLConfocalSettingDefinition->getLength()<=0)
			{
				$confocal='false';
				$ATLConfocalSettingDefinition=$sequence_block->[$iseq]->getElementsByTagName("ATLCameraSettingDefinition");
			}
			
			if($confocal eq 'true')
			{
				$w=$ATLConfocalSettingDefinition->[0]->getAttribute("InDimension");
				$h=$ATLConfocalSettingDefinition->[0]->getAttribute("OutDimension");
				return ($w,$h);
			}
			else
			{
				my $CameraFormat=$ATLConfocalSettingDefinition->[0]->getElementsByTagName('CameraFormat');
				$w=$CameraFormat->[0]->getAttribute('xDim');
				$h=$CameraFormat->[0]->getAttribute('yDim');				
			}
			return ($w,$h);
		}
	}
}


=head2 new

  Example    : template->setAFPattern();
  Description: establece la distancia entre un field y el siguiente a la derecha dentro de una misma well
  Params:	 : none
  Returntype : none
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub setAFPattern()
{
	my ($this,%args)=@_;
	$this->{root}->getElementsByTagName("Properties")->item(0)->getElementsByTagName("AutoFocusPattern")->item(0)->getFirstChild->setNodeValue($args{-type});
}

sub setZGalvo()
{
	my ($this,%args)=@_;
	my $AdditionalZPosition=$this->{lrp_root}->getElementsByTagName("AdditionalZPosition");
	
	for(my $i=0;$i<$AdditionalZPosition->getLength();$i++)
	{
		if($AdditionalZPosition->[$i]->getAttribute("ZMode") eq "1")
		{
			$AdditionalZPosition->[$i]->setAttribute("ZPosition",$args{-galvo});
		}
	}
}
sub setZWide()
{
	my ($this,%args)=@_;
	my $AdditionalZPosition=$this->{lrp_root}->getElementsByTagName("AdditionalZPosition");
	
	for(my $i=0;$i<$AdditionalZPosition->getLength();$i++)
	{
		if($AdditionalZPosition->[$i]->getAttribute("ZMode") eq "2")
		{
			$AdditionalZPosition->[$i]->setAttribute("ZPosition",$args{-wide});
		}
	}
}

# sub coor
# {
# 	my ($this,%args)=@_;
# 	
# 	my $width_with_stitching=$this->pixel2meters(-pixel=>$args{-width_with_stitching});
# 	my $height_with_stitching=$this->pixel2meters(-pixel=>$args{-height_with_stitching});
# 	
# 	# my $width_without_stitching=$this->pixel2meters(-pixel=>$args{-width_without_stitching});
# 	# my $height_without_stitching=$this->pixel2meters(-pixel=>$args{-height_without_stitching});
# 	my $width_without_stitching=$args{-width_without_stitching};
# 	my $height_without_stitching=$args{-height_without_stitching};
# 	print STDERR "******START CORRECTION POINTS****************************************************************\n";
# 	
# 	print STDERR "\nANGLES: ".$args{-angles}->[0]." r y ".$args{-angles}->[1]." r\n\n";
# 	
# 	print STDERR "---------------------------------------------------------------------------------------------\n";
# 	print STDERR "Size Image with stitching (".$args{-width_with_stitching}."x".$args{-height_with_stitching}."): ".$width_with_stitching."x".$height_with_stitching."\n";
# 	print STDERR "Size: (".$args{-width_without_stitching}."x".$args{-height_without_stitching}."): ".$width_without_stitching."x".$height_without_stitching."\n";
# 	print STDERR "---------------------------------------------------------------------------------------------\n";
# 	my $radio=sqrt(($width_without_stitching/2)**2+($height_without_stitching/2)**2);
# 	print STDERR "Radio: $radio\n";
# 	print STDERR "---------------------------------------------------------------------------------------------\n";
# 	
# 	my $Xcentro_stitching_image=$width_with_stitching/2;
# 	my $Ycentro_stitching_image=$height_with_stitching/2;
# 	
# 	# Calculamos los vectores DE y BD
# 	# DE=DF-EF
# 	my $EF;
# 	eval
# 	{
# 		$EF=sqrt($radio**2-$Xcentro_stitching_image**2); # EF=sqrt(r**2-CF**2)
# 	} or do
# 	{
# 		print STDERR "Error raiz negaticva el la correcion al calcular el segmetno EF\n";
# 		LASAF::TEMPLATE::template::CoorSQRTnegative->throw('CoorSQRTnegative');
# 		return;
# 	};
# 	
# 	my $DF=$Ycentro_stitching_image;
# 	my $DE=$DF-$EF; # DE=DF-EF
# 	
# 	my $BC;
# 	eval
# 	{
# 		$BC=sqrt($radio**2-$Ycentro_stitching_image**2);
# 	} or do
# 	{
# 		print STDERR "Error raiz negaticva el la correcion al calcular el segmetno BC\n";
# 		LASAF::TEMPLATE::template::CoorSQRTnegative->throw('CoorSQRTnegative');
# 		return ;
# 	};
# 	
# 	my $AC=$Xcentro_stitching_image;
# 	my $AB=$AC-$BC;
# 	
# 	my $AD=$width_with_stitching;
# 	my $BD=$AD-$AB;
# 
# 	print STDERR "---------------------------------------------------------------------------------------------\n";
# 	print STDERR "Yo calculo Segmento AB=$AB\n";
# 	print STDERR "Yo calculo Segmento DE=$DE\n";
# 	
# 	# $AB=$this->pixel2meters(-pixel=>19);
# 	# $DE=$this->pixel2meters(-pixel=>20);
# 	
# 	print STDERR "---------------------------------------------------------------------------------------------\n";
# 	print STDERR "Segmento AB=$AB\n";
# 	print STDERR "Segmento DE=$DE\n";
# 	
# 	print STDERR "Segmento BD=$BD\n";
# 	print STDERR "Segmento EF=$EF\n";
# 	print STDERR "---------------------------------------------------------------------------------------------\n";
# 	
# 	
# 	#calculamos alfa;
# 	my $alfa=atan($DE/$BD);
# 	print STDERR "El Angulo alpa es: $alfa\n";
# 	
# 	print STDERR "El Angulo alpa es: ". $args{-angles}->[0]."\n";
# 	
# 	
# 	# $alfa=0.00915993;
# 	my @pos=@{$this->{POS}};
# 	
# 	# $alfa=3.14159265358979+$alfa;
# 	for(my $i=0;$i<=$#pos;$i++)
# 	{
# 		$pos[$i]->{xo}=$pos[$i]->{x};
# 		$pos[$i]->{yo}=$pos[$i]->{y};
# 		
# 		my $x=$pos[$i]->{x};
# 		my $y=$pos[$i]->{y};
# 		
# 		my $BCp=$x-$AB;
# 		my $beta=atan($y/$BCp);
# 		
# 		# my $alfap=$beta-$alfa;
# 		my $hp=sqrt($y**2+$BCp**2);
# 		
# 		#punto corregido es
# 		
# 		my $ab=$hp*sin($beta-$alfa);
# 		my $Bb=$hp*cos($beta-$alfa);
# 		
# 		# $pos[$i]->{x}=$pos[$i]->{x}*cos($args{-angles}->[0]);
# 		# $pos[$i]->{y}=$pos[$i]->{y}*sin($args{-angles}->[0]);
# 		
# 		# print STDERR "==============================================\n";
# 		# print STDERR "$i\n";
# 		# print STDERR "Centro: X: ".($width_with_stitching/2)." Y: ".($height_with_stitching/2)."\n";
# 		# print STDERR "X: ".$x." Y: ".$y."\n";
# 		# print STDERR "X corregida: ".$Bb." Y Corregida: ".$ab."\n";
# 		# print STDERR "X Template corregida: ".($Bb+$args{-inix})." Y Corregida: ".($ab+$args{-iniy})."\n";
# 		# print STDERR "==============================================\n";
# 		$pos[$i]->{x}=$Bb;
# 		$pos[$i]->{y}=$ab;
# 	}
# 	$this->{POS}=\@pos;
# 	print STDERR "Despues: ".$this->{POS}->[0]->{x}.",".$this->{POS}->[0]->{y}."\n";
# 	print STDERR "******END CORRECTION POINTS******************************************************************\n";
# }
# /Users/acarro/Sites/Confocal/libexe/LeicaWorkFlow.pl  --conf /Users/acarro/Sites/Confocal/CONF/localhost.white.ini -template_step1 leica10x5 -name_micro white -macro_detection detect/CellDet-CM-MANUAL.ijm -macro_black blacks/TMASearchBlackRectangules.ijm -template_step2 leica5Z  -thresholdMin 0 -thresholdMax 100 -size 100 -maxsize Infinity -circularity 0.0  --create --imagej --dir experiment--2013_08_30_17_27-10x5  --coor
# 
# 

sub coor
{
	my ($this,%args)=@_;
	my $log_rcls=LOGS::simple->new();
	
	
	# print STDERR "******START CORRECTION POINTS****************************************************************\n";
	$log_rcls->print(-msg=>"******START CORRECTION POINTS****************************************************************");
	
	# print STDERR "\nANGLES: x=".$args{-angles}->[0]." r y=".$args{-angles}->[1]." r\n\n";
	$log_rcls->print(-msg=>"ANGLES: x=".$args{-angles}->[0]." r y=".$args{-angles}->[1]);
	$log_rcls->print(-msg=>"Pixels width: ". $args{-width}."\tHeght: ".$args{-height});
	# print STDERR "Pixels width: ". $args{-width}."\tHeght: ".$args{-height}."\n";
	
		my $width=$this->pixel2meters(-pixel=>$args{-width});
		my $height=$this->pixel2meters(-pixel=>$args{-height});
		
		my $alfa=($args{-angles}->[1]+$args{-angles}->[0])/2;
		$alfa=$args{-angles}->[1];
	$log_rcls->print(-msg=>"width: ". $width."\tHeght: ".$height);
	$log_rcls->print(-msg=>"El Angulo alpa es: ".$alfa);
	# print STDERR "width: ". $width."\tHeght: ".$height."\n";
	# print STDERR "El Angulo alpa es: ".$alfa."\n";

	my @pos=@{$this->{POS}};
	
	
	# my $xDistance=$this->getFieldDistanceX();
	# my $yDistance=$this->getFieldDistanceY();
	
	for(my $i=0;$i<=$#pos;$i++)
	{
		$pos[$i]->{xo}=$pos[$i]->{x};
		$pos[$i]->{yo}=$pos[$i]->{y};

		# $pos[$i]->{x}=$pos[$i]->{x}+$width/2;
		# $pos[$i]->{y}=$pos[$i]->{y}+$height/2;

		
		# my $coorX=$pos[$i]->{x}*cos($alfa)-$pos[$i]->{y}*sin($alfa);
		# my $coorY=$pos[$i]->{x}*sin($alfa)+$pos[$i]->{y}*cos($alfa);
		
		my $coorX=$pos[$i]->{x}*cos($alfa)-$pos[$i]->{y}*sin($alfa);
		my $coorY=$pos[$i]->{x}*sin($alfa)+$pos[$i]->{y}*cos($alfa);


		
		# $pos[$i]->{x}=$pos[$i]->{x}-abs($pos[$i]->{x}-$coorX);
		# $pos[$i]->{y}=$pos[$i]->{y}+abs($pos[$i]->{y}-$coorY);

		
		$pos[$i]->{x}=$coorX;
		$pos[$i]->{y}=$coorY;

		# $pos[$i]->{x}=$pos[$i]->{x}-$width/2;
		# $pos[$i]->{y}=$pos[$i]->{y}-$height/2;
		
		$log_rcls->print(-msg=>"-------------------------------------------------------------------------------------");
		$log_rcls->print(-msg=>"original: x: ".$this->meters2pixel(-meters=>$pos[$i]->{xo})."\ty: ".$this->meters2pixel(-meters=>$pos[$i]->{yo}));
		$log_rcls->print(-msg=>"correcion: x: ".$this->meters2pixel(-meters=>$coorX)."\ty: ".$this->meters2pixel(-meters=>$coorY));
		$log_rcls->print(-msg=>"calculado: x:".$this->meters2pixel(-meters=>$pos[$i]->{x})."\ty: ".$this->meters2pixel(-meters=>$pos[$i]->{y}));
		$log_rcls->print(-msg=>"-------------------------------------------------------------------------------------");

		# print  STDERR "-------------------------------------------------------------------------------------\n";
		# print  STDERR "original: x: ".$this->meters2pixel(-meters=>$pos[$i]->{xo})."\ty: ".$this->meters2pixel(-meters=>$pos[$i]->{yo})."\n";
		# print  STDERR "correcion: x: ".$this->meters2pixel(-meters=>$coorX)."\ty: ".$this->meters2pixel(-meters=>$coorY)."\n";
		# print  STDERR "calculado: x:".$this->meters2pixel(-meters=>$pos[$i]->{x})."\ty: ".$this->meters2pixel(-meters=>$pos[$i]->{y})."\n";
		# print  STDERR "-------------------------------------------------------------------------------------\n";
	}
	$this->{POS}=\@pos;
	$log_rcls->print(-msg=>"******END CORRECTION POINTS******************************************************************");
	# print STDERR "******END CORRECTION POINTS******************************************************************\n";
	$log_rcls->close();
}
=head2 new

  Example    : template->createTemplateFromFile();
  Description: genera un template (xml y lrp), apartir de un fichero de coordenadas
  Returntype : String
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub  createTemplateFromFile
{
	my ($this,%args)=@_;
	
	my $CONFIANZA;
	
	my $log_rcls=LOGS::simple->new();
	
	my @black=@{$args{-black}};
	
	
	
	# my @pos=$this->readFile(-file=>$args{-file},-sort=>$args{-sort});
	my @pos=@{$this->{POS}};
	my $TotalWells=scalar(@pos);
	
	$this->TotalWellsToWellXY(-totalWells=>$TotalWells);

	$this->setZGalvo(-galvo=>"0");
	$this->setZWide(-wide=>"0.004499998");
	

	my $ScanFieldArray=$this->{root}->getElementsByTagName("ScanFieldArray");
	my $ScanFieldData=$this->{root}->getElementsByTagName("ScanFieldData");
	my $node;
	for(my $inode=$this->{root}->getElementsByTagName("ScanFieldData")->getLength()-1;$inode>=0;$inode--)
	{
		my $ScanFieldData=$this->{root}->getElementsByTagName("ScanFieldData")->item($inode);
		$ScanFieldArray->item(0)->removeChild($ScanFieldData);
	}


# Siempre dejamos el zoom y la dimension que este en el step2 que hemos creado
	# $this->setZoom(-zoom=>$this->{ZOOM});
	# $this->setDimension(-dimension=>$this->{DIMENSION});
	
	my %jobs=$this->getBlockID();
	
	my $xDistance=$this->getFieldDistanceX();
	my $yDistance=$this->getFieldDistanceY();
	
	#my $xDistance=$this->{CONVERSION}->microns2meters(-microns=>$this->{MosaicSingleImage}->{$this->{MAGNIFICATION}});
	#my $yDistance=$this->{CONVERSION}->microns2meters(-microns=>$this->{MosaicSingleImage}->{$this->{MAGNIFICATION}});
	
	
	#Pedazo de codigo que se usa para calcular xDistance e yDistance cuando el zoom es distinto de uno
	# if($this->{ZOOM}!=1)
	# {
	# 	my $size_aux=$this->{MosaicSingleImage}->{$this->{MAGNIFICATION}}/$this->{ZOOM};
	# 	my ($entera,$decimales)=split(/\./,$size_aux);
	# 	$entera=round(($entera)*(1-$this->{OVERLAPX}))."\.".$decimales;
	# 	my $xDistance=$this->{CONVERSION}->microns2meters(-microns=>$entera);
	# 	my $yDistance=$this->{CONVERSION}->microns2meters(-microns=>$entera);
	# }
	# 
	$this->{ScanFieldStageDistanceX}=$xDistance;
	$this->{ScanFieldStageDistanceY}=$yDistance;
	
	# my @startPosition=$this->getStartPosition();
	
	$this->{TOTALFIELDX}=round(($this->{wWellMax}/$xDistance)+0.5);
	$this->{TOTALFIELDY}=round(($this->{hWellMax}/$yDistance)+0.5);
	
	
	my $TotalFields=$this->{TOTALFIELDX}*$this->{TOTALFIELDY};
	# print STDERR "\tTotalWells: $TotalWells\n";
	$log_rcls->print(-msg=>"TotalWells: $TotalWells");
	

	status_ini(-name_micro=>$this->{NAME_MICRO},-totalwells=>$TotalWells,-totalfields=>$this->{TOTALFIELDX}*$this->{TOTALFIELDY});
	
	# <Properties Version="Version: 1.0.3.153 -- Build 13.01.2011" TotalCountOfFields="16" TotalCountOfWells="4" TotalAssignedJobs="16" UniqueJobCounter="1">


	$this->setAFPattern(-type=>"IsIndividualAFPattern");
	$this->setScanFieldDiameter(-diameter=>(($TotalWells*$this->{TOTALFIELDX})-$this->{TOTALFIELDX}));
	$this->setTotalFields(-fields=>($TotalWells*$TotalFields));
	$this->setTotalWells(-wells=>$TotalWells);
	$this->setTotalJobs(-jobs=>($TotalWells*$TotalFields));
	$this->setCountOfScanFields(-fieldsx=>$this->{TOTALFIELDX},-fieldsy=>$this->{TOTALFIELDY});
	$this->setCountOfWells(-wells=>$TotalWells);
	$this->setWellsDistance(-wellsX=>$this->{TOTALFIELDX}-1,-wellsY=>$this->{TOTALFIELDY}-1);
	$this->setFieldDistanceX(-dx=>$this->{CONVERSION}->meters2microns(-meters=>$this->{ScanFieldStageDistanceX}));
	$this->setFieldDistanceY(-dy=>$this->{CONVERSION}->meters2microns(-meters=>$this->{ScanFieldStageDistanceY}));
	my $first=0;
	my %graph_black;
	
	my $imageUtils=Image::utils->new(-file=>$args{-control_image});
	$imageUtils->rotate();

	if($#black>0)
	{
		
		for(my $i=0;$i<=$#black;$i++)
		{
			my $box=$black[$i]->{x}.",".$black[$i]->{y}." ".($black[$i]->{x}+$black[$i]->{w}).",".($black[$i]->{y}+$black[$i]->{h});
			$imageUtils->blackbox(-box=>$box);
			$black[$i]->{E}=0;
			$black[$i]->{tx}=$this->pixel2meters(-pixel=>$black[$i]->{x})+$args{-inix}-$this->{CONVERSION}->microns2meters(-microns=>$args{-parcentricity_x});
			$black[$i]->{ty}=$this->pixel2meters(-pixel=>$black[$i]->{y})+$args{-iniy}-$this->{CONVERSION}->microns2meters(-microns=>$args{-parcentricity_y});
		}
		# $CONFIANZA=$this->searchEvaLue(-sort=>$args{-sort},-black=>$args{-black} ,-file=>$args{-file},-inix=>$args{-inix},-iniy=>$args{-iniy});
	}
	
	# print STDERR "\txDISTANCE: ".$xDistance.", yDISTANCE: ".$yDistance."\n";
	$log_rcls->print(-msg=>"xDISTANCE: ".$xDistance.", yDISTANCE: ".$yDistance);
	my $nfield=0;
	
	for(my $iwellx=1;$iwellx<=$this->{WELLX};$iwellx++)
	{

		my $x0=sprintf("%.14f",$pos[$iwellx-1]->{x});
		my $y0=sprintf("%.14f",$pos[$iwellx-1]->{y});

		my $x_sin_trans_coordernadas_por_rotacion=sprintf("%.14f",$pos[$iwellx-1]->{xo});
		my $y_sin_trans_coordernadas_por_rotacion=sprintf("%.14f",$pos[$iwellx-1]->{yo});
		my $dir=$pos[$iwellx-1]->{dir};
		
		my $h=sprintf("%.14f",$pos[$iwellx-1]->{h});
		my $w=sprintf("%.14f",$pos[$iwellx-1]->{w});
		
		my $tx0=$x0+$args{-inix}-$this->{CONVERSION}->microns2meters(-microns=>$args{-parcentricity_x});
		my $ty0=$y0+$args{-iniy}-$this->{CONVERSION}->microns2meters(-microns=>$args{-parcentricity_y});
		
			
		my ($tnewX,$tnewY)=($tx0,$ty0);
		if($iwellx == 1)
		{	
			$this->setStartPosition(-x=>$this->{CONVERSION}->meters2microns(-meters=>$args{-inix}), -y=>$this->{CONVERSION}->meters2microns(-meters=>$args{-iniy}));	
		}
		for(my $iwelly=1;$iwelly<=$this->{WELLY};$iwelly++)
		{
			# $this->newScanWellData(-first_node=>$first,-wx=>$iwellx,-wy=>$iwelly,-zoom=>$args{-zoom},-startImage=>\@startPosition);
			# print STDERR "\tWELL: ".$iwellx."\t".$iwelly."\t FIELDS: ".$this->{TOTALFIELDX}."x".$this->{TOTALFIELDY}."\n";
			$log_rcls->print(-msg=>"WELL: ".$iwellx."\t".$iwelly."\t FIELDS: ".$this->{TOTALFIELDX}."x".$this->{TOTALFIELDY});
			# print STAT "WELL:$iwellx,$iwelly\n"; 
			for(my $ifieldx=1;$ifieldx<=$this->{TOTALFIELDX};$ifieldx++)
			{
				for(my $ifieldy=1;$ifieldy<=$this->{TOTALFIELDY};$ifieldy++)
				{
					$nfield++;
					$tnewX=sprintf("%.14f",$tx0+(($ifieldx-1)*$xDistance));
					$tnewY=sprintf("%.14f",$ty0+(($ifieldy-1)*$yDistance));

					# $log_rcls->print(-msg=>"WELL X $iwellx WELL Y $iwelly FIELD X $ifieldx FIELD Y $ifieldy X: $tnewX Y: $tnewY");

					status_current(-name_micro=>$this->{NAME_MICRO},-stat=>($iwellx*$iwelly).",".$nfield);
					# sleep 2;
					# print STDERR ($iwellx*$iwelly).",".(($ifieldx*$ifieldy)+(($iwellx*$iwelly)-1))."\n";
					
					if($ifieldx==1 && $ifieldy==1)
					{
						$this->newScanWellData(-first_node=>$first,
												-wx=>$iwellx,-wy=>$iwelly,-zoom=>$this->{ZOOM},
												-startImageX=>$tnewX,-startImageY=>$tnewY,
												-endImageX=>($tnewX+$xDistance),-endImageY=>($tnewY+$yDistance));
					}
					# print $ifieldx."\t".$this->{LABELX}->[$ifieldx]."\t$ifieldy\t".$this->{LABELY}->[$ifieldy]."\n";
					my $enabled="true";
					$graph_black{$iwellx}{$ifieldy}{$ifieldx}="O";
					
					my $newX=sprintf("%.14f",$x0+(($ifieldx-1)*$xDistance));
					my $newY=sprintf("%.14f",$y0+(($ifieldy-1)*$yDistance));
					
####################################################################################################################					
# Pitamos sobre la imagen lo que hemos detectado
# con un cuadrado negro esta aplicado la correcion en el caso de que se lo hayamos puesto
					my $xbox=$this->meters2pixel(-meters=>$newX);
					my $ybox=$this->meters2pixel(-meters=>$newY);
					my $wbox=$this->meters2pixel(-meters=>$xDistance);
					my $hbox=$this->meters2pixel(-meters=>$yDistance);
					my $box=$xbox.",".$ybox." ".($xbox+$wbox).",".($ybox+$hbox);
					if($this->meters2pixel(-meters=>$h)==1 && $this->meters2pixel(-meters=>$w)==1)
					{
						$box=($xbox-($wbox/2)).",".($ybox-($hbox/2))." ".($xbox+($wbox/2)).",".($ybox+($hbox/2));
					}
					$imageUtils->empty_box(-box=>$box,-stroke=>'green');
####################################################################################################################					
#pintamos un cuadrado rojo lo que hemos detectado sin correcion en caso de haberla hecho			
					if($x_sin_trans_coordernadas_por_rotacion!=0 && $y_sin_trans_coordernadas_por_rotacion!=0)
					{
						my $newX=sprintf("%.14f",$x_sin_trans_coordernadas_por_rotacion+(($ifieldx-1)*$xDistance));
						my $newY=sprintf("%.14f",$y_sin_trans_coordernadas_por_rotacion+(($ifieldy-1)*$yDistance));
					
						my $xbox=$this->meters2pixel(-meters=>$newX);
						my $ybox=$this->meters2pixel(-meters=>$newY);
						my $wbox=$this->meters2pixel(-meters=>$xDistance);
						my $hbox=$this->meters2pixel(-meters=>$yDistance);
						my $box=$xbox.",".$ybox." ".($xbox+$wbox).",".($ybox+$hbox);
						if($this->meters2pixel(-meters=>$h)==1 && $this->meters2pixel(-meters=>$w)==1)
						{
							$box=($xbox-($wbox/2)).",".($ybox-($hbox/2))." ".($xbox+($wbox/2)).",".($ybox+($hbox/2));
						}
						$imageUtils->empty_box(-box=>$box,-stroke=>'red');
					}
####################################################################################################################					
					if($#black>0)
					{
						
						$enabled=$this->is_black(-list_blacks=>\@black,
													-current=>{'x'=>$newX,'y'=>$newY,'tx'=>$tnewX,'ty'=>$tnewY,'h'=>$yDistance,'w'=>$xDistance},
													-image=>$imageUtils);
						if($enabled eq 'false')
						{
							$graph_black{$iwellx}{$ifieldy}{$ifieldx}="*";
						}

					}
					$node=$ScanFieldData->item(0)->cloneNode(1);
					if(($tnewX > ($tx0+$w)) || ($tnewY > ($ty0+$h)))
					{
						$enabled="false";
						$graph_black{$iwellx}{$ifieldy}{$ifieldx}="X";
						my $xbox=$this->meters2pixel(-meters=>$newX);
						my $ybox=$this->meters2pixel(-meters=>$newY);
						my $wbox=$this->meters2pixel(-meters=>$xDistance);
						my $hbox=$this->meters2pixel(-meters=>$yDistance);
	
						my $box=$xbox.",".$ybox." ".($xbox+$wbox).",".($ybox+$hbox);
##########################################################################################################################################	
# Pitamos el cuadrado amarillo cuando se debilitan los campos porque no hay nada ya que tiene que tener todos el mismo numero de campos
						$imageUtils->fillbox(-box=>$box,-color=>"yellow");
##########################################################################################################################################						
					}
					$this->newScanFieldData(-ScanFieldArray=>$ScanFieldArray,
											-node=>$node,
											-enabled=>$enabled,
											-first_node=>$first,
											-jobID=>$jobs{JOB}->{ID} ,
											-name=>$jobs{JOB}->{NAME},
											-wx=>$iwellx,-wy=>$iwelly,
											-fx=>$ifieldx,-fy=>$ifieldy,
											-x=>$tnewX,-y=>$tnewY,
											-labelx=>$this->{LABELX}->[$iwellx],-labely=>$this->{LABELY}->[$iwelly]);
					$first=1;
				}
			}
		}
	}
	
	# if($#black>0)
	# {
	# 	my $linea="";
	# 	foreach my $well (sort {$a<=>$b} keys %graph_black)
	# 	{
	# 		print "--------------------------------------------------------\n";
	# 		print "GRAPH:".$well."\n";
	# 		print "--------------------------------------------------------\n";
	# 		foreach my $ifieldy (sort {$a<=>$b} keys %{$graph_black{$well}})
	# 		{
	# 			foreach my $ifieldx (sort {$a<=>$b} keys %{$graph_black{$well}{$ifieldy}})
	# 			{
	# 				$linea.=$graph_black{$well}{$ifieldy}{$ifieldx};
	# 			}
	# 			print $linea."\n";
	# 			$linea="";
	# 		}
	# 	
	# 	}
	# }
	
	my $file = basename($args{-output_template});
	# my $dir = dirname($args{-file});
	# my @name=split(/\./,$file);
	$this->{NAME_TEMPLATE}=$file;
	# $this->write(-nameTemplate=>$name[0],-dir=>$args{-path_ouput_dir});
	$this->write(-file=>$args{-output_template});
	$imageUtils->write(-file=>$args{-control_image});

	status_del_file(-name_micro=>$this->{NAME_MICRO});
	
	$log_rcls->close();
	return ($this->{TOTALFIELDX},$this->{TOTALFIELDY});
}
# =head2 new
# 
#   Example    : template->createTemplateFromFile();
#   Description: crea en el templete un nuevo well en la seccion ScanWellArray
#   Returntype : String
#   Exceptions : none
#   Caller     : web drawing code
#   Status     : Stable
# 
# =cut

sub is_black
{
	my ($this,%args)=@_;
	my @black=@{$args{-list_blacks}};
	my $current_point=$args{-current};
	# my @black_finded;
	
	my $xbox=$this->meters2pixel(-meters=>$current_point->{x});
	my $ybox=$this->meters2pixel(-meters=>$current_point->{y});
	my $wbox=$this->meters2pixel(-meters=>$current_point->{w});
	my $hbox=$this->meters2pixel(-meters=>$current_point->{h});
	
	my $box=$xbox.",".$ybox." ".($xbox+$wbox).",".($ybox+$hbox);
	
	$args{-image}->box(-box=>$box,-label=>"");
	my $log_rcls=LOGS::simple->new();
	$log_rcls->print(-msg=>"==================================================================");
	# print STDERR "==================================================================\n";
	for(my $i=0;$i<=$#black;$i++)
	{
		my $blackX=$black[$i]->{tx};
		my $blackY=$black[$i]->{ty};
		
		my $blackW=$black[$i]->{w};
		my $blackH=$black[$i]->{h};
		 
		my $difX=sprintf("%.8f",($current_point->{tx}-$blackX));
		my $difY=sprintf("%.8f",($current_point->{ty}-$blackY));
		# 
		if($current_point->{tx}>=($blackX)&&$current_point->{tx}<=($blackX+$blackW) || $difX==0)
		{
			if($current_point->{ty}>=($blackY)&&$current_point->{ty}<=($blackY+$blackH)|| $difY==0)
			{
				$log_rcls->print(-msg=>"Black X,Y:".$blackX.",".$blackY."\tW,H:".$blackW."=".($blackX+$blackW).",".$blackH."=".($blackY+$blackH));
				$log_rcls->print(-msg=>"Curre X,Y:".$current_point->{tx}.",".$current_point->{ty});
		
				my $areaBlack=sprintf("%.8f",$blackW*$blackH);
				
				my $dx_aux=$blackW-($current_point->{tx}-$blackX);
				my $dy_aux=$blackH-($current_point->{ty}-$blackY);
				
				
				my $areaRealBlack=sprintf("%.8f",($dx_aux*$dy_aux));
				my $d_area=sprintf("%.8f",($areaBlack-$areaRealBlack));
				
				$log_rcls->print(-msg=>"Area Black     :".$areaBlack);
				$log_rcls->print(-msg=>"Area Real BLack:".$dx_aux."*".$dy_aux."==".$areaRealBlack);
				$log_rcls->print(-msg=>"Area Dif       :".$d_area);
				
				if($d_area ==0 || $areaRealBlack ==0)
				{
					my $box=$black[$i]->{x}.",".$black[$i]->{y}." ".($black[$i]->{x}+$black[$i]->{w}).",".($black[$i]->{y}+$black[$i]->{h});
					$args{-image}->fillbox(-box=>$box,-color=>'green');
					if($black[$i]->{E}==0)
					{
						$black[$i]->{E}=1;
						return 'false';
					}
				}
				else
				{
					my $box=$black[$i]->{x}.",".$black[$i]->{y}." ".($black[$i]->{x}+$black[$i]->{w}).",".($black[$i]->{y}+$black[$i]->{h});
					$args{-image}->fillbox(-box=>$box,-color=>'red');
				}
			}
		}
	}
	# print STDERR "==================================================================\n";
	$log_rcls->print(-msg=>"==================================================================");
	return 'true';
}

# =head2 new
# 
#   Example    : template->createTemplateFromFile();
#   Description: crea en el templete un nuevo well en la seccion ScanWellArray
#   Returntype : String
#   Exceptions : none
#   Caller     : web drawing code
#   Status     : Stable
# 
# =cut
sub newScanWellData
{
	my ($this,%args)=@_;
	# <ScanWellData SlideNo="1" WellX="1" WellY="1" MosaicSingleImageHeight="0.000123015873015873" MosaicTileImageOverlapX="1.2E-05" MosaicTileImageOverlapY="1.2E-05" 
	# MosaicScanImageRotation="0" MosaicSingleImageWidth="0.000123015873015873" MosaicImageStartX="9.99999488E-05" MosaicImageStartY="1.00097605E-06" 
	# MosaicImageHeight="0.00022203174603174599" MosaicImageWidth="0.00022203174603174599" MosaicImageEndX="0.000211015821815873" MosaicImageEndY="0.000112016849065873" 
	# MosaicFlipImage="false" FieldXStartCoordinate="0" FieldYStartCoordinate="0" ScanFieldDiameter="0" WellXOffset="0" WellYOffset="0" XCountOfFields="2" YCountOfFields="2" 
	# Indicator="IsStandardScanWell" />
    my $ScanWellArray=$this->{root}->getElementsByTagName("ScanWellArray");
	my $ScanWellData=$this->{root}->getElementsByTagName("ScanWellData")->item(0);
	
	my $node;
	if($args{-first_node}==0)
	{
		$node=$ScanWellArray->item(0)->removeChild($ScanWellData);
	}
	else
	{
		$node=$ScanWellData->cloneNode(1);
	}
	
	my $zoom=$args{-zoom};
	# if(!exists($this->{MosaicSingleImage}->{$this->{MAGNIFICATION}}))
	# {
	# 	# system("echo \"Missing objetive ".$this->{MAGNIFICATION}."x\" >".$this->{ERRORFILE}->val( 'FILES', 'outputFileImageJ' ));
	# 	print STDERR "ERROR: Missing objetive ".$this->{MAGNIFICATION}."x in file ".$this->{CFG}->val( 'MICRO', 'objetives' )."\n";
	# 	exit -1;
	# }
	
	my $MosaicSingleImageWidth=$this->{CONVERSION}->microns2meters(-microns=>$this->{MosaicSingleImage}->{$this->{MAGNIFICATION}}->{w})/$zoom;
	my $MosaicSingleImageHeight=$this->{CONVERSION}->microns2meters(-microns=>$this->{MosaicSingleImage}->{$this->{MAGNIFICATION}}->{h})/$zoom;
	
	# my $MosaicSingleImageWidth=$this->{ScanFieldStageDistanceX};
	# my $MosaicSingleImageHeight=$this->{ScanFieldStageDistanceY};
	 
	my $overlapX=$this->{OVERLAPX};
	my $overlapY=$this->{OVERLAPY};
	
	# my $MosaicTileImageOverlapX=$MosaicSingleImageWidth*$overlapX;
	# my $MosaicTileImageOverlapY=$MosaicSingleImageHeight*$overlapY;
	
	my $MosaicTileImageOverlapX=round(($this->{MosaicSingleImage}->{$this->{MAGNIFICATION}}->{w}*$overlapX)/$zoom);
	my $MosaicTileImageOverlapY=round(($this->{MosaicSingleImage}->{$this->{MAGNIFICATION}}->{h}*$overlapY)/$zoom);
	
	$MosaicTileImageOverlapX=$this->{CONVERSION}->microns2meters(-microns=>$MosaicTileImageOverlapX);
	$MosaicTileImageOverlapY=$this->{CONVERSION}->microns2meters(-microns=>$MosaicTileImageOverlapY);
	
	my $MosaicImageWidth=($this->{TOTALFIELDX})*$this->{ScanFieldStageDistanceX};
	my $MosaicImageHeight=($this->{TOTALFIELDY})*$this->{ScanFieldStageDistanceY};
	
	$node->setAttribute ("SlideNo","0");
	$node->setAttribute ("WellX",$args{-wx});
	$node->setAttribute ("WellY",$args{-wy});

	$node->setAttribute ("MosaicImageHeight",$MosaicImageHeight);
	$node->setAttribute ("MosaicImageWidth",$MosaicImageWidth);

	$node->setAttribute ("MosaicSingleImageHeight",$MosaicSingleImageHeight);
	$node->setAttribute ("MosaicSingleImageWidth",$MosaicSingleImageWidth);
	
	$node->setAttribute ("MosaicTileImageOverlapX",$MosaicTileImageOverlapX);
	$node->setAttribute ("MosaicTileImageOverlapY",$MosaicTileImageOverlapY);
	# $node->setAttribute ("MosaicScanImageRotation","0");
	
	
	
	$node->setAttribute ("MosaicImageStartX",$args{-startImageX});
	$node->setAttribute ("MosaicImageStartY",$args{-startImageY});
	$node->setAttribute ("MosaicImageEndX",$args{-endImageX}+$this->{ScanFieldStageDistanceX});
	$node->setAttribute ("MosaicImageEndY",$args{-endImageY}+$this->{ScanFieldStageDistanceY});

	# $node->setAttribute ("MosaicFlipImage","false");
	# $node->setAttribute ("FieldXStartCoordinate","0");
	# $node->setAttribute ("FieldYStartCoordinate","0");
	if($args{-first_node}==0)
	{
		$node->setAttribute ("WellXOffset","0");
		$node->setAttribute ("WellYOffset","0");
	}
	else
	{
		$node->setAttribute ("WellXOffset","-2");
		$node->setAttribute ("WellYOffset","-2");
	}
	$node->setAttribute ("XCountOfFields",$this->{TOTALFIELDX});
	$node->setAttribute ("YCountOfFields",$this->{TOTALFIELDY});
	# $node->setAttribute ("Indicator","IsStandardScanWell");
	
	$ScanWellArray->[0]->appendChild($node);
}
=head2 new

  Example    : template->createTemplateFromFile();
  Description: crea en el templete un nuevo field en la seccion ScanFieldArray
  Returntype : String
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

# <ScanFieldData JobId="25" SlideNo="1" WellX="1" WellY="1" FieldX="1" FieldY="1" JobName="Job 16" Description="MatrixScreener" IsMosaicCalibrationField="false" 
# IsDriftCompensationField="false" IsIndividualAutofocusScanField="false" IsTrackingField="false" IsPumpScanField="false" PumpDelay="1000" PumpTime="1000" Selected="false"
 # Enabled="true" Indicator="IsStandardScanField" IsAutofocusScanField="false" AFScore="0" State="IsActive" AFJobId="0" AFSliceCount="0" DriftScanRange="0" DriftSliceCount="0" 
# AFScanRange="0" Shape="IsRectangle" JobAssigned="true" LabelX="A" LabelY="1">
#       <FieldXCoordinate>9.99999488E-05</FieldXCoordinate>
#       <FieldYCoordinate>1.00097605E-06</FieldYCoordinate>
#       <FieldZCoordinate>-2.5390857364926964E-05</FieldZCoordinate>
#       <FieldScanSlices>0</FieldScanSlices>
#       <FieldScanRange>0</FieldScanRange>
#       <FieldRotation>0</FieldRotation>
#     </ScanFieldData>
=cut
sub newScanFieldData
{
	my ($this,%args)=@_;

	my $node=$args{-node};
	my $ScanFieldArray=$args{-ScanFieldArray};
	


	# my $node=$ScanFieldArray->item(0)->removeChild($ScanFieldData);
	$node->setAttribute ("JobId",$args{-jobID});
	$node->setAttribute ("SlideNo","0");
	$node->setAttribute ("WellX",$args{-wx});
	$node->setAttribute ("WellY",$args{-wy});
	
	$node->setAttribute ("FieldX",$args{-fx});
	$node->setAttribute ("FieldY",$args{-fy});

	# if($args{-fx} % 2 ==0)
	# {
		$node->setAttribute("IsIndividualAutofocusScanField","true");
	# }
	# else
	# {
	# 	$node->setAttribute ("IsIndividualAutofocusScanField","false");
	# }
	
	$node->setAttribute ("JobName",$args{-name});
	# $node->setAttribute ("Description","MatrixScreener");
	# $node->setAttribute ("IsMosaicCalibrationField","false");
	# $node->setAttribute ("IsDriftCompensationField","false");
	# $node->setAttribute ("IsIndividualAutofocusScanField","false");
	# $node->setAttribute ("IsTrackingField","false");
	# $node->setAttribute ("IsPumpScanField","false");
	# $node->setAttribute ("PumpDelay","1000");
	# $node->setAttribute ("PumpTime","1000");
	# $node->setAttribute ("Selected","false");
	$node->setAttribute ("Enabled",$args{-enabled});
	# $node->setAttribute ("Indicator","IsStandardScanField");
	# $node->setAttribute ("IsAutofocusScanField","false");
	# $node->setAttribute ("AFScore","0");
	# $node->setAttribute ("State","IsActive");
	# $node->setAttribute ("AFJobId","0");
	# $node->setAttribute ("AFSliceCount","0");
	# $node->setAttribute ("DriftScanRange","0");
	# $node->setAttribute ("DriftSliceCount","0");
	# $node->setAttribute ("AFScanRange","0");
	# $node->setAttribute ("Shape","IsRectangle");
	$node->setAttribute ("JobAssigned","true");
	$node->setAttribute ("LabelX",$args{-labelx});
	$node->setAttribute ("LabelY",$args{-labely});

	$node->getElementsByTagName("FieldXCoordinate")->item(0)->getFirstChild->setNodeValue($args{-x});
	$node->getElementsByTagName("FieldYCoordinate")->item(0)->getFirstChild->setNodeValue($args{-y});
	#$node->getElementsByTagName("FieldZCoordinate")->item(0)->getFirstChild->setNodeValue(0);
	# print $node."\n";


	$ScanFieldArray->[0]->appendChild($node);

}
=head2 new

  Example    : template->createTemplateFromFile();
  Description: escribe el template tanto el xml como el lrp
  Returntype : String
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub write()
{
	my ($this,%args)=@_;
	# my $dir="./";
	# if(exists($args{-dir}))
	# {
	# 	$dir=$args{-dir}."/";
	# }
	my $dir=dirname($args{-file});
	my $file=basename($args{-file});
	
	
	
	if($file !~ /\{ScanningTemplate\}/)
	{
		$file="\{ScanningTemplate\}".$file;
	}


	# if(exists($args{-nameTemplate}))
	# {
		if($file =~ /(.*)\.xml$|\.lrp$/)
		{
			$file=$1;	
		}
		
		$this->{xml}->printToFile ($dir."/".$file."\.xml");
		open my $fh, ">:utf8", $dir."/".$file."\.xml" or die $!;
		$this->{xml}->print($fh);
		
		$this->{lrp}->printToFile ($dir."/".$file."\.lrp");
		open my $fh, ">:utf8", $dir."/".$file."\.lrp" or die $!;
		$this->{lrp}->print($fh);

	# }
	# else
	# {
	# 	print $this->{TEMPLATE}."\n";
	# 	$this->{xml}->printToFile ($this->{TEMPLATE});
	# }
  
}

sub searchEvaLue
{
	my ($this,%args)=@_;
	
	my @pos=$this->readFile(-file=>$args{-file},-sort=>$args{-sort});
	my $TotalWells=scalar(@pos);
	my @black=@{$args{-black}};
	
	my $xDistance=$this->getFieldDistanceX();
	my $yDistance=$this->getFieldDistanceY();
	
	my %wells;
	for(my $iwellx=1;$iwellx<=$this->{WELLX};$iwellx++)
	{
		my $x0=sprintf("%.14f",$pos[$iwellx-1]->{x});
		my $y0=sprintf("%.14f",$pos[$iwellx-1]->{y});
		$x0=$x0+$args{-inix};
		$y0=$y0+$args{-iniy};
		my ($newX,$newY)=($x0,$y0);
		for(my $iwelly=1;$iwelly<=$this->{WELLY};$iwelly++)
		{
			my @graph_black;
			for(my $ifieldx=1;$ifieldx<=$this->{TOTALFIELDX};$ifieldx++)
			{
				for(my $ifieldy=1;$ifieldy<=$this->{TOTALFIELDY};$ifieldy++)
				{
					$newX=sprintf("%.14f",$x0+(($ifieldx-1)*$xDistance));
					$newY=sprintf("%.14f",$y0+(($ifieldy-1)*$yDistance));
					for(my $i=0;$i<=$#black;$i++)
					{
						my $blackX=$black[$i]->{x};
						my $blackY=$black[$i]->{y};
						$blackX=($blackX-$newX)**2;
						$blackY=($blackY-$newY)**2;
						my $module=sqrt($blackX+$blackY);
						push @graph_black,$module;
					}
				}
			}
			$wells{$iwellx}=\@graph_black;
		}
	}
	
	
	my $menor=1;
	foreach my $well (sort {$a<=>$b} keys %wells)
	{
		my @aux=sort { $a <=> $b } @{$wells{$well}};
		if($aux[$#black]<$menor)
		{
			$menor=$aux[$#black];
		}
	}
return $menor;	 
}













1;
