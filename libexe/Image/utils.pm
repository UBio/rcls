#
#  Image::utils
#
#  Created by acarro on 2011-03-29.
#  Copyright (c) 2011 CNIO. All rights reserved.



package Image::utils;
$VERSION='1.0';

use strict;
use Config::IniFiles;
use File::Basename;
use Image::Magick;
use Math::Trig ':pi';
use Math::Trig;
sub new
{
	my ($class,%args)=@_;
	my $this={};
	my $cfg_confocal = Config::IniFiles->new( -file => $ENV{CONFOCAL_INI});
	$this->{convert}=$cfg_confocal->val( 'IMAGEMAGIC', 'convert' );
	$this->{image}=	Image::Magick->new();
	
	$this->{file}=$args{-file};
	$this->{base_dir_temp}="/tmp";
	$this->{tmp}->{tmpA}=$this->{base_dir_temp}."/autotrim_$$.mpc";
	$this->{tmp}->{tmpB}=$this->{base_dir_temp}."/autotrim_$$.cache";
	$this->{tmp}->{tmp00}=$this->{base_dir_temp}."/autotrim_00_$$.png";
	$this->{tmp}->{tmp0}=$this->{base_dir_temp}."/autotrim_0_$$.png";
	$this->{tmp}->{tmp1}=$this->{base_dir_temp}."/autotrim_1_$$.png";
	$this->{tmp}->{tmp2}=$this->{base_dir_temp}."/autotrim_2_$$.png";
	$this->{tmp}->{tmp3}=$this->{base_dir_temp}."/autotrim_3_$$.png";
	$this->{tmp}->{rotate}=$this->{base_dir_temp}."/rotate.tif";

		
	if($args{-file})
	{
		$this->{image}->Read($args{-file});
	}
	bless($this);
	return $this;
}

sub createBlackImage
{
	my ($this,%args)=@_;
	$this->{image}->Set(size=>$args{-w}.'x'.$args{-h});
	$this->{image}->ReadImage("xc:black");
}
sub resize
{
	my ($this,%args)=@_;
	my $width=$this->{image}->Get("width");
	my $height=$this->{image}->Get("height");
	my $ratio=$width/$height;
	my $newWidth=$args{-width};
	
	$this->{image}->Resize(width=>$newWidth,height=>($newWidth/$ratio));
}

sub convert
{
	my ($this,%args)=@_;
	$this->{image}->Read($args{-file});
	my $width=$this->{image}->Get("width");
	my $height=$this->{image}->Get("height");
	my $ratio=$width/$height;
	my $newWidth=600;
	$height=($newWidth/$ratio);
	# $this->{image}->Resize(width=>$newWidth,height=>($newWidth/$ratio));
	my ($file,$dir,$extaux) = fileparse($args{-file}, qr/\.[^.]*/);
	
	
	if(!$args{-channels} || $args{-channels} eq 'ONE')
	{
		print STDERR $this->{convert}.' '.$args{-file} .' -resize '.$newWidth.'x'.$height.'  '.$dir.'/'.$file.'.'.$args{-to}."\n";
		system($this->{convert}.' '.$args{-file} .' -resize '.$newWidth.'x'.$height.'  '.$dir.'/'.$file.'.'.$args{-to});
	}
	else
	{
		print STDERR $this->{convert}.' '.$args{-file} .' -resize '.$newWidth.'x'.$height.' -channel '.$args{-channels}.' -combine '.$dir.'/'.$file.'.'.$args{-to}."\n";
		system($this->{convert}.' '.$args{-file} .' -resize '.$newWidth.'x'.$height.' -channel '.$args{-channels}.' -combine '.$dir.'/'.$file.'.'.$args{-to});		
	}
	# $this->write(-format=>$args{-to},-file=>$args{-file});
}

sub getWidth
{
	my ($this,%args)=@_;
	return $this->{image}->Get("width");
}
sub getHeight
{
	my ($this,%args)=@_;
	return $this->{image}->Get("height");	
}

sub rotate
{
	my ($this,%args)=@_;
	$this->{image}->Rotate(degrees=>90.0);
}
sub box
{
	my ($this,%args)=@_;
	my ($x0,$y0);
	if($args{-box} =~ /(.*),(.*)\s(.*),(.*)/)
	{
		$x0=$1;
		$y0=$2;
	}
	$this->{image}->Annotate(font=>"Arial.tff",pointsize=>25,text=>$args{-label},fill=>"rgb(255, 255, 255)",x=>$x0+5,y=>$y0+25,antialias=>"true");
	$this->{image}->Draw(fill=>"rgba(255, 255, 255, 0.0)",primitive=>"Rectangle",points=>$args{-box},stroke=>"white");
}

sub binary
{
	my ($this,%args)=@_;
	$this->{image}->Negate(channel=>"RGB");
	$this->{image}->Quantize(colorspace=>'Gray');
	$this->{image}->ContrastStretch(levels=>"2%x40%");
}

sub getColor
{
	my ($this,%args)=@_;
	my $coors=$args{-coors};
	my $cmd=$this->{convert}." ".$this->{tmp}->{tmpA}.' -format "%[pixel:u.p{'.$coors.'}]" info:';
	my $color=`$cmd`;
	$color=~s/\n//gi;
	return $color;
}


sub paddedBinary
{
	my ($this,%args)=@_;
	my $pad=$args{-pad};
	my $color=quotemeta($args{-color});
	my $width=$args{-width};
	my $height=$args{-height};
	my $coors=$args{-coors};
	my $fuzzval=1;
	my $cmd1=$this->{convert}." ".$this->{tmp}->{tmpA}." -bordercolor $color -border ".$pad.'x'.$pad.' '.$this->{tmp}->{tmpA};
	my $cmd2=$this->{convert}." ".$this->{tmp}->{tmpA}." -fuzz $fuzzval".'% -fill none -draw "matte '.$coors.' floodfill" -fill white +opaque none '.$this->{tmp}->{tmp0};
 	my $cmd3=$this->{convert}." ".'\( -size '.$width.'x'.$height.' xc:black \) '.$this->{tmp}->{tmp0}.' -composite '.$this->{tmp}->{tmp1};
	system($cmd1);
	# print $cmd1."\n";
	system($cmd2);
	# print $cmd2."\n";
	system($cmd3);
	# print $cmd3."\n";
	
}
sub getTransition()
{
	my ($this,%args)=@_;
	my $img1D=$args{-img1D};
	my $dim=$args{-dim};
	my $dir=$args{-dir};
	
	my $cmd=$this->{convert}." $img1D -compress None -depth 8 txt:-";
	my $rowcol=`$cmd`;
	# rowcol=`convert $img1D -compress None -depth 8 txt:-`
	# my $cmd1='echo "'.$rowcol.'" | sed -n '."'s/^[0-9]*,[0-9]*: [(].*[)]  #...... \(.*\)\$/\1/p'";
	# print $cmd1;
	my $vals;
	
	my $i=0;
	if($dim eq 'dec')
	{
		$i=$dim;
	}
	while($rowcol =~ /(.*)(\s+)#......(\s+)(\w+)/gi)
	{
		if($4 eq 'white')
		{
			last;
		}
		if($i<$dim && $dir eq 'inc')
		{
			$i++;
		}
		if($i>0 && $dir eq 'dec')
		{
			$i--;
		}
	}
	return $i
}
sub delete_file_tmp
{
	my $this;
	foreach my $tmp_file (keys %{$this->{tmp}})
	{
		unlink $this->{tmp}->{$tmp_file};
	}
}
sub get_angles
{
	my ($this,%args)=@_;
	
	my $angleX=$this->auto_get_angle();
	my $angleY=$this->auto_get_angle90();
	return ($angleX,$angleY);
}
sub auto_get_angle90
{
	my ($this,%args)=@_;
	my $cmd=$this->{convert}.' '.$this->{file}.'  -rotate 90.0 '.$this->{tmp}->{rotate};
	system($cmd);
	$this->{file}=$this->{tmp}->{rotate};
	return $this->auto_get_angle();
}


sub auto_get_angle
{
	my ($this,%args)=@_;
	my $coors="0,0";

	# my $cmd=$this->{convert}.' -rotate "90.0<"  '.$this->{file}.' '.$this->{tmp}->{rotate};
	# print $cmd."\n";
	# system($cmd);
	# $this->{file}=$this->{tmp}->{rotate};
	
	# print STDERR "Step1\n";	
	my $cmd=$this->{convert}.' -quiet -regard-warnings  '.$this->{file}.' +repage '.$this->{tmp}->{tmpA};
	system($cmd);
	# print $cmd."\n";
	# start with image already cropped to outside bounds of rotated image
	
	my $width=$this->getWidth();
	my $height=$this->getHeight();
	my $widthmp=$width-2;
	my $heightmp=$height-2;
	
	# my $widthm1=$width-1;
	# my $heightm1=$height-1;
	# my $midwidth=$width / 2;
	# my $midheight=$height / 2;
	
	

	# print "Step2\n";
	my $color=$this->getColor(-coors=>$coors);
	$this->paddedBinary(-pad=>1,-color=>$color,-width=>$width,-height=>$height,-coors=>$coors);
		
	# # trim off pad (repage to clear page offsets)
	# print "Step3\n";
	
	my $cmd=$this->{convert}.' '.$this->{tmp}->{tmp1}."[$widthmp".'x'.$heightmp.'+1+1] +repage '.$this->{tmp}->{tmp1};
	system($cmd);
	# convert $tmp1[${widthmp}x${heightmp}+1+1] +repage $tmp1
	# 
	# # get rotation angle
	# # get coord of 1st white pixel in left column
	# getTransition $tmp1[1x${height}+0+0] $height "inc"
	# print "Step4\n";
	
	my $p1x=1;
	my $p1y=$this->getTransition(-img1D=>$this->{tmp}->{tmp1}."[1x$height+0+0]",-dim=>$height,-dir=>'inc');
	# p1x=1
	# p1y=$location
	# 
	# # get coord of 1st white pixel in top row
	# getTransition $tmp1[${width}x1+0+0] $width "inc"
	# p2x=$location
	# p2y=1
	my $p2y=1;
	my $p2x=$this->getTransition(-img1D=>$this->{tmp}->{tmp1}."[".$width."x1+0+0]",-dim=>$width,-dir=>'inc');
	
	# # compute slope and angle (reverse sign of dely as y increases downward)
	# delx=`expr $p2x - $p1x`
	# dely=`expr $p1y - $p2y`
	my $delx=$p2x-$p1x;
	my $dely=$p1y-$p2y;
	my $rotang=2;

	if($delx!=0)
	{
		# my $angle=(180/pi)*atan($dely/$delx);
		my $angle=atan($dely/$delx);
		if($angle>(pi/4))
		{
			$rotang=(pi/2)-$angle;
		}
		else
		{
			$rotang=$angle;
		}

	}
	# $rotang=($rotang*pi)/180;
	$this->delete_file_tmp();
	return $rotang;
}
sub write
{
	my ($this,%args)=@_;
	my $format="tiff";
	my $ext="tif";
	if(lc($args{-format} eq 'png'))
	{
		$format="png";
		$ext="png";
	}
	if(lc($args{-format} eq 'jpg'))
	{
		$format="jpg";
		$ext="jpg";
	}
	if(lc($args{-format} eq 'svg'))
	{
		$format="svg";
		$ext="svg";
	}
	my ($file,$dir,$extaux) = fileparse($args{-file}, qr/\.[^.]*/);
	my $x=$this->{image}->write($format.":".$dir."/".$file.'.'.$ext);
	if($x ne '')
	{
		print STDERR $x."\n";
	}
}
1;