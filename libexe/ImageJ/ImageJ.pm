#
#  ImageJ
#
#  Created by acarro on 2011-03-29.
#  Copyright (c) 2011 CNIO. All rights reserved.



package ImageJ::ImageJ;
$VERSION='1.0';

use strict;
use Config::IniFiles;
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
	
	my $cfg_confocal = Config::IniFiles->new( -file => $ENV{CONFOCAL_INI});
	
	my $java=$cfg_confocal->val( 'JAVAVM', 'java' );
	my $jar=$cfg_confocal->val( 'JAVAVM', 'jar' );
	my $opt=$cfg_confocal->val( 'JAVAVM', 'opt' );
	$this->{TMP}=$cfg_confocal->val( 'FILES', 'tmp' );
	if(!exists($args{-macro}))
	{
		die "usage: new(-macro=>macro,-image=>IMAGE,-output=>OUTPUT])\n";
	}
	if(!exists($args{-image}))
	{
		die "usage: new(-macro=>macro,-image=>IMAGE,-output=>OUTPUT])\n";
	}
	if(!exists($args{-output}))
	{
		die "usage: new(-macro=>macro,-image=>IMAGE,-output=>OUTPUT])\n";
	}
	$this->{preScript}=$cfg_confocal->val( 'JAVAVM', 'preScript' );
	$this->{postScript}=$cfg_confocal->val( 'JAVAVM', 'postScript' );
	$this->{MACRO}=$args{-macro};
	$this->{IMAGE}=$args{-image};
	$this->{OUTPUT}=$args{-output};
	$this->{ROTATE}=0;
	$this->{CMD}="$java $opt $jar -batch ";
	print STDERR "post:".$this->{preScript}."\n";
	print  STDERR "pre:".$this->{postScript}."\n";
	if(-e $this->{OUTPUT})
	{
		unlink $this->{OUTPUT};
	}
	
	bless($this);
		
	return $this;
}
=head2 new

  Example    : ImageJ->new();
  Description: This method returns a string that is considered to be
               the 'display' identifier.
  Returntype : String
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut

sub run
{
	my ($this)=@_;
	
	my $CMD=$this->{preScript}.";".$this->{CMD}.$this->{MACRO}."  ".$this->{IMAGE}.">".$this->{OUTPUT}.";".$this->{postScript};
	print STDERR "1:".$CMD."\n";
	system($CMD);
}


sub runPipe
{
	my ($this,%args)=@_;
	my $MACROTMP=$this->{TMP}."/macro.txt";
	open(MAC,">".$MACROTMP)||die "$!";
	open(MACRO,$this->{MACRO})||die "$! ".$this->{MACRO};
	my $Rotate=0;
	while(<MACRO>)
	{
		chomp;
		my $lineaMAcro=$_;
		if($lineaMAcro =~ /Rotate 90 Degrees Right/g && $lineaMAcro !~ /^\/\//)
		{
			$Rotate="90R";
		}
		$lineaMAcro=~s/#file#/$this->{IMAGE}/g;

		$lineaMAcro=~s/#heightRectangle#/$args{-height}/g;
		$lineaMAcro=~s/#widthRectangle#/$args{-width}/g;
		
		$lineaMAcro=~s/#widthImage#/$args{-pos}->{w}/g;
		$lineaMAcro=~s/#heightImage#/$args{-pos}->{h}/g;

		$lineaMAcro=~s/#initImageX#/$args{-pos}->{x}/g;
		$lineaMAcro=~s/#initImageY#/$args{-pos}->{y}/g;

		$lineaMAcro=~s/#thresholdMin#/$args{-thresholdMin}/g;
		$lineaMAcro=~s/#thresholdMax#/$args{-thresholdMax}/g;

		$lineaMAcro=~s/#size#/$args{-size}/g;
		$lineaMAcro=~s/#maxsize#/$args{-maxsize}/g;
		$lineaMAcro=~s/#circularity#/$args{-circularity}/g;


		print MAC $lineaMAcro."\n";
	# print MAC 'run("Analyze Particles...", "size='.$args{-size}.'-Infinity pixel circularity='.$args{-circularity}.'-1.00 show=Outlines display clear include add");'."\n";
	}
	close MAC;
	close MACRO;
	my $CMD= $this->{preScript}.";".$this->{CMD}. $MACROTMP.$args{-type}.$this->{OUTPUT}.";".$this->{postScript};
	print STDERR "2:".$CMD."\n";
	system($CMD);
	
	my %error=$this->error();
	if($error{'code'}==0)
	{
		# unlink $MACROTMP;
		print STDERR "Rotate:".$Rotate."\n";
		$this->{ROTATE}=$Rotate;
		return  %error;
	}
	return %error;
}
sub error
{
	my ($this)=@_;
	
	open(OUT,$this->{OUTPUT});
	my $head=<OUT>;
	chomp $head;
	my %error_Struct;
	$error_Struct{'code'}=0;
	$error_Struct{'msg'}="CORRECT";
	my $nlines=0;
	my ($trash,$bx,$by,$w,$h)=split(/\s+/,$head);
	if($head eq "")
	{
		$error_Struct{'code'}=-3;
		my $aux="cat ".$this->{OUTPUT};
		$error_Struct{'msg'}=`$aux`;
		if($error_Struct{'msg'} =~ /DISPLAY/g)
		{
			$error_Struct{'msg'}="java.lang.InternalError: Can't connect to X11 window server";
		}
		
	}
	else
	{
		if(($bx eq "XM" && $by eq "YM") || ($bx eq "BX" && $by eq "BY" && $w eq "Width" &&  $h eq "Height") || ($trash =~ /\d+/) && ($bx =~ /\d+/) )
		{
			my ($index,$bx,$by,$w,$h);
		
			while(<OUT>)
			{
				$nlines++;
			}
			if($nlines>0)
			{
				return %error_Struct;
			}
			else
			{
				$error_Struct{'code'}=-1;
				$error_Struct{'msg'}="Not found nothing";
			}
		}
		else
		{
			
			$error_Struct{'code'}=-2;
			my $CMD="cat ".$this->{OUTPUT}; 
			$error_Struct{'msg'}=`$CMD`;
			if($error_Struct{'msg'} =~ /DISPLAY/g)
			{
				$error_Struct{'msg'}="java.lang.InternalError: Can't connect to X11 window server";
			}

		}
	}
	close OUT;
	return %error_Struct;
}

1;
