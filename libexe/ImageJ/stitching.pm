#
#  stitching
#
#  Created by acarro on 2011-03-29.
#  Copyright (c) 2011 CNIO. All rights reserved.



package ImageJ::stitching;
$VERSION='1.0';

use strict;
use Config::IniFiles;
use File::Basename;
use Image::utils;
#use Image::Magick;

=head2 new

  Example    : ImageJ->new();
  Description: This method returns a string that is considered to be
               the 'display' identifier.
  Returntype : String
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut

sub new
{
	my ($class,%args)=@_;
	my $this={};

	$this->{L}="";
	$this->{S}="";
	$this->{U}="";
	$this->{V}="";
	$this->{J}="";
	$this->{E}="";
	$this->{O}="";
	$this->{X}="";
	$this->{Y}="";
	$this->{T}="";
	$this->{ZMAX}=0;
	$this->{CHANNELS}=0;
	$this->{dirImages}=$args{-dirImages};
	$this->{ROOT}="";
	$this->{dimension}=$args{-dimension};
	$this->{name}=$args{-name};
	$this->{codecolor}=$args{-codecolor};
	my $cfg_confocal = Config::IniFiles->new( -file => $ENV{CONFOCAL_INI});
	my $dirMacros=$cfg_confocal->val( 'MACROS', 'dir' );
	$this->{convert}=$cfg_confocal->val( 'IMAGEMAGIC', 'convert' );
	# $this->{ImageBlacksFiles}=$cfg_confocal->val( 'FILES', 'ImageBlacksFiles' );
	
	$this->{MACRO}=$args{-macrostitching};
	$this->{TMP}=$cfg_confocal->val( 'FILES', 'tmp' )."/stitching\.".$this->{name};

	
	# system("mkdir -p ".$this->{TMP});
	$this->{preScript}=$cfg_confocal->val( 'JAVAVM', 'preScript' );
	$this->{postScript}=$cfg_confocal->val( 'JAVAVM', 'postScript' );
	
	my $java=$cfg_confocal->val( 'JAVAVM', 'java' );
	my $jar=$cfg_confocal->val( 'JAVAVM', 'jar' );
	my $opt=$cfg_confocal->val( 'JAVAVM', 'opt' );
	$this->{CMD}="$java $opt $jar -batch ";
	
	bless($this);

	
	my @experimentDir=split(/\n/,`ls $this->{dirImages}`);
	
	my $tmpauxFile=$this->{TMP};
	foreach my $slide (@experimentDir)
	{
		if (-d $this->{dirImages}."/".$slide && $slide =~/^Slide/i)
		{
			my @slideDir=split(/\n/,`ls $this->{dirImages}/$slide`);
			foreach my $chamber (@slideDir)
			{
				my $dirChamber=$this->{dirImages}."/".$slide."/".$chamber;
				if(-d $dirChamber)
				{
					if($chamber =~ /chamber--U(\d*)--V(.*)/i)
					{
						$this->{TMP}.="U$1_V$2";
						system("mkdir -p ".$this->{TMP});
						my ($grid)=$this->getGrid(-dir=>$dirChamber);
						print STDERR "\t".$chamber."\t".$grid->[0]."\t".$grid->[1]."\t".$grid->[2]."\t".$grid->[3]."\n";
						$this->copyFilesToTmpDir(-grid_x=>$grid->[2],-grid_y=>$grid->[3],-dir=>$this->{dirImages}."/".$slide."/".$chamber, -chamber=>$1,-dimension=>$args{-dimension});
						$this->runStiching(-grid=>$grid,-tiffOutput=>$this->{dirImages}."/".$slide."_".$chamber.".tif",-chamber=>$1);
						system("rm -rf ".$this->{TMP});
					}
					$this->{TMP}=$tmpauxFile;
				}
			}
		}
	}
	system("rm -rf ".$this->{TMP});
	return $this;
}
sub createFillImage
{
	my ($this,%args)=@_;
	if($this->{dimension} =~/(\d+)x(\d+)/)
	{
		# print STDERR $this->{convert}." -size ".$this->{dimension}." xc:#ffffff -stroke black -fill white  -draw \"rectangle 0,0,$1,$2\" -depth 8 -alpha off ".$args{-output}."\n";
		system($this->{convert}." -size ".$this->{dimension}." xc:#ffffff -stroke black -fill white  -draw \"rectangle 0,0,$1,$2\" -depth 1 -alpha off -colorspace GRAY ".$args{-output});	
	}
}
sub getGrid
{
	my ($this,%args)=@_;
	my @fields=split(/\n/,`ls $args{-dir}`);
	my $x=0;
	my $y=0;
	my $inix=50;
	my $iniy=50;
	foreach my $dirField(@fields)
	{
		my $existsImage=`ls $args{-dir}/$dirField/*.tif`;
		if($existsImage ne "")
		{
			if($dirField =~ /(Field)--X(.*)--Y(.*)/i)
			{
				$this->{ROOT}=$1;
				if($2>$x)
				{
					$x=$2;
				}
				if($3>$y)
				{
					$y=$3;
				}
		
				if($2<$inix)
				{
					$inix=$2;
				
				}
				if($dirField =~ /Field--X$inix--Y(.*)/i)
				{
					if($1<$iniy)
					{
						$iniy=$1;
					}
				}
			}
		}
	}

	return [$inix,$iniy,$x,$y];
}
sub runStiching
{
	my ($this,%args)=@_;
	my $grid=$args{-grid};
	my $DIR=$this->{TMP};
	my $tiffOutput=$args{-tiffOutput};
	my $chamber=$args{-chamber};

	my $macroTmp="/tmp/macroStiching.ijm";
	print $this->{MACRO}."\n\n\n";
	open(MAC,$this->{MACRO}) || die "No encuentro la macro: ".$this->{MACRO}."\n";
	print STDERR "\tStiching OutFile: ".$tiffOutput."\n";
	open(MACTMP,">$macroTmp");
	# inixgrid=#INIXGRID#;
	# iniygrid=#INIYGRID#;
	# size_xgrid=#SIZEXGRID#;
	# size_ygrid=#SIZEYGRID#;
	# nChannels=#NCHANNELS#
	# nZ=#NZ#
	while(<MAC>)
	{
		my $lineaMAcro=$_;
		$lineaMAcro=~s/#DIR#/$DIR/g;
		$lineaMAcro=~s/#INIXGRID#/$grid->[0]/g;
		$lineaMAcro=~s/#INIYGRID#/$grid->[1]/g;
		$lineaMAcro=~s/#SIZEXGRID#/$grid->[2]/g;
		$lineaMAcro=~s/#SIZEYGRID#/$grid->[3]/g;
		$lineaMAcro=~s/#NCHANNELS#/$this->{CHANNELS}/g;
		$lineaMAcro=~s/#NZ#/$this->{ZMAX}/g;
		$lineaMAcro=~s/#tiffOutput#/$tiffOutput/g;
		print MACTMP $lineaMAcro;
	}
	close MAC;
	close MACTMP;
	
	my $CMD=$this->{preScript}.";".$this->{CMD}." ".$macroTmp.">".$this->{TMP}."/../stitching.log;".$this->{postScript};
	my $error=system($CMD);
	$this->getError(-logfile=>$this->{TMP}."/../stitching.log");
	print STDERR $CMD."\n";
 	print STDERR "\tStitchin Error: ".$error."\n";
	# unlink $macroTmp; 
}

sub getError
{
	my ($this,%args)=@_;
	my $msg=`tail -1 $args{-logfile}`;
	
	if($msg =~ /Finished Stitching/)
	{
		return 0;
	}
	else
	{
		print STDERR "ERROR: ".`tail -10 $args{-logfile}`
	}
}

sub copyFilesToTmpDir
{
	my ($this,%args)=@_;
	my $grid_x=$args{-grid_x};
	my $grid_y=$args{-grid_y};
	my $DIR=$args{-dir};
	my $chamber=$args{-chamber};

	$this->{CHANNELS}=0;
	$this->{ZMAX}=0;

	my $root="field";
	
	for(my $ix=0;$ix<=$grid_x;$ix++)
	{
		for(my $iy=0;$iy<=$grid_y;$iy++)
		{
			my $x="0"x(2-length($ix)).$ix;
			my $y="0"x(2-length($iy)).$iy;
			my $DIRTIFF=$DIR."/".$this->{ROOT}."--X".$x."--Y".$y;
			
			if(-e $DIRTIFF)
			{
				my $aux=`ls $DIRTIFF/*.tif`;
				my @images=split(/\s+/,$aux);
				foreach my $image(@images)
				{
					
					$image=basename($image);
					if($image =~ /image--L(\d*)--S(\d*)--U(\d*)--V(\d*)--J(\d*)--E(\d*)--O(\d*)--X(\d*)--Y(\d*)--T(\d*)--Z(\d*)--C(\d*).ome.tif/)
					{
						$this->{L}=$1;
						$this->{S}=$2;
						$this->{U}=$3;
						$this->{V}=$4;
						$this->{J}=$5;
						$this->{E}=$6;
						$this->{O}=$7;
						# $this->{X}.=",".$8;
						# $this->{Y}.=",".$9;
						$this->{T}=$10;
						
						if($11>$this->{ZMAX})
						{
							$this->{ZMAX}=$11;
						}
						if($12>$this->{CHANNELS})
						{
							$this->{CHANNELS}=$12;
						}
					}
				}
			}
		}
	}
	$this->{CHANNELS}++;
	$this->{ZMAX}++;
	# print STDERR "L: ".$this->{L}."\n";
	# print STDERR "S: ".$this->{S}."\n";
	# print STDERR "U: ".$this->{U}."\n";
	# print STDERR "V: ".$this->{V}."\n";
	print STDERR "\tJ: ".$this->{J}."\n";
	# print STDERR "E: ".$this->{E}."\n";
	# print STDERR "O: ".$this->{O}."\n";
	# print STDERR "X: ".$this->{X}."\n";
	# print STDERR "Y: ".$this->{Y}."\n";
	# print STDERR "T: ".$this->{T}."\n";
	print STDERR "\tZMAX: ".$this->{ZMAX}."\n";
	print STDERR "\tCHANNELS: ".$this->{CHANNELS}."\n";
	
	for(my $ix=0;$ix<=$grid_x;$ix++)
	{
		for(my $iy=0;$iy<=$grid_y;$iy++)
		{
			my $x="0"x(2-length($ix)).$ix;
			my $y="0"x(2-length($iy)).$iy;
			my $DIRTIFF=$DIR."/".$this->{ROOT}."--X".$x."--Y".$y;

			if(-e $DIRTIFF)
			{
				if($this->{CHANNELS} >1) #si el numero de canales es mayor que uno primero los unimos para luego hacer el stitching
				{
					my $file=$this->mip_and_merge_channels(-dir=>$DIRTIFF,-x=>$x,-y=>$y,-chamber=>$chamber);
				
					if($file eq '')
					{
						$this->createFillImage(-output=>$this->{TMP}."/Field-X".$x."-Y".$y.'.tif');
						# my $error=system("ln -s ".$this->{ImageBlacksFiles}."/".$this->{dimension}."\.tif ".$this->{TMP}."/Field-X".$x."-Y".$y.'.tif');
					}
				}
				else #en el caso de que el numero de canales sea uno creamos un link simbolico a la imagen para hacer el stitching
				{
					# my $error=system("ln -s ".$DIRTIFF."/image--L0000--S00--U".$chamber."--V00--J".$this->{J}."--E00--O00--X".$x."--Y".$y."--T0000--Z*--C*.ome.tif ".$this->{TMP}."/Field-X".$x."-Y".$y.'.tif');
					my $image_file=$DIRTIFF."/image--L0000--S00--U".$chamber."--V00--J".$this->{J}."--E00--O00--X".$x."--Y".$y."--T0000--Z00--C00.ome.tif";
					system($this->{convert}." $image_file -rotate 90  ".$this->{TMP}."/Field-X".$x."-Y".$y.'.tif');
					
				}
			}
			else
			{
				$this->createFillImage(-output=>$this->{TMP}."/Field-X".$x."-Y".$y.'.tif');
				# my $error=system("ln -s ".$this->{ImageBlacksFiles}."/".$this->{dimension}."\.tif ".$this->{TMP}."/Field-X".$x."-Y".$y.'.tif');				
			}

		}
	}
}

sub mip_and_merge_channels
{
	my ($this,%args)=@_;
	
	my %color;
	
	$color{BGR}=['0,1','0,2','1,2'];
	$color{BRG}=['0,1','1,2','0,2'];
	$color{RGB}=['1,2','0,2','0,1'];
	$color{RBG}=['1,2','0,1','0,2'];
	$color{GBR}=['0,2','0,1','1,2'];
	$color{GRB}=['0,2','1,2','0,1'];
	$color{BR}=['0,1','1,2'];
	$color{RB}=['1,2','0,1'];
	$color{GB}=['0,2','0,1'];
	$color{BG}=['0,1','0,2'];
	$color{RG}=['1,2','0,2'];
	$color{GR}=['0,2','1,2'];
	$color{ONE}=['0'];
	

	my @delete_channels=@{$color{$this->{codecolor}}};
	my $background="";
	my $deleteChannels="";
	if($this->{CHANNELS}<=2)
	{
		$background='-background black';
	}
	
	
	my $chamber=$args{-chamber};
	my $totalImagesChannel="";
	my $image_file=$args{-dir}."/image--L0000--S00--U".$chamber."--V00--J".$this->{J}."--E00--O00--X".$args{-x}."--Y".$args{-y}."--T0000--Z00--C00.ome.tif";
	if(!-e $image_file)
	{
		return ;
	}
	# open(OUT,">/tmp/stitching.script");
	for(my $iChannel=0;$iChannel<$this->{CHANNELS};$iChannel++)
	{
		if($iChannel<=$#delete_channels)
		{
			$deleteChannels="-delete ".$delete_channels[$iChannel];
		}
		my $c="0"x(2-length($iChannel)).$iChannel;
		my $image_file=$args{-dir}."/image--L0000--S00--U".$chamber."--V00--J".$this->{J}."--E00--O00--X".$args{-x}."--Y".$args{-y}."--T0000--Z00--C$c.ome.tif";
		for(my $iZ=1;$iZ<$this->{ZMAX};$iZ++)
		{
			my $z="0"x(2-length($iZ)).$iZ;
			my $image_file2=$args{-dir}."/image--L0000--S00--U".$chamber."--V00--J".$this->{J}."--E00--O00--X".$args{-x}."--Y".$args{-y}."--T0000--Z$z--C$c.ome.tif";
			# print OUT $this->{convert}." $image_file $image_file2  -compose lighten -depth 8 -composite /tmp/".$this->{name}."_max_convert_mpi$iZ.tif\n";
			system($this->{convert}." $image_file $image_file2  -compose lighten -depth 8 -composite /tmp/".$this->{name}."_max_convert_mpi$iZ.tif");
			$image_file="/tmp/".$this->{name}."_max_convert_mpi$iZ.tif";			
		}
		# print OUT $this->{convert}." $image_file -separate -delete $delete_channels[$iChannel] /tmp/".$this->{name}."_canal$iChannel\.tif\n";
		system($this->{convert}." $image_file -separate -delete $delete_channels[$iChannel] /tmp/".$this->{name}."_canal$iChannel\.tif");
		$deleteChannels="";
		$totalImagesChannel.=" /tmp/".$this->{name}."_canal$iChannel\.tif";
	}
	my $image_result="Field-X".$args{-x}."-Y".$args{-y}.'.tif';
	# print OUT $this->{convert}." $totalImagesChannel   -depth 8 -rotate 90 $background -combine ".$this->{TMP}."/$image_result\n";
	system($this->{convert}." $totalImagesChannel -depth 8  -rotate 90 $background -combine ".$this->{TMP}."/$image_result");
	system("rm -rf $totalImagesChannel"); 
	# close OUT;
	return $image_result;
}

1;
