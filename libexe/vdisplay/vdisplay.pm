#
#  Virtual Display
#
#  Created by acarro on 2011-03-29.
#  Copyright (c) 2011 CNIO. All rights reserved.



package vdisplay::vdisplay;
$VERSION='1.0';

use strict;
use Config::IniFiles;
use File::Basename;

=head2 new

  Example    : ImageJ->new();
  Description: This method returns a string that is considered to be
               the 'display' identifier.
  Returntype : String
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut

sub start
{
	my ($class,%args)=@_;
	my $this={};
	
	my $cfg_confocal = Config::IniFiles->new( -file => $ENV{CONFOCAL_INI});
	
	
 	my($exec, $path, $suffix) = fileparse($cfg_confocal->val( 'DISPLAY', 'xvfb' ));
 	$this->{exec}=$exec;
	$this->{path_exec}=$path;
	bless($this);
	
	$this->{lastIdDislay}=$this->getLastDisplayId();
	$this->{idDisplay}=$this->{lastIdDislay}+1;
	
	my $cmd=$this->{path_exec}."".$this->{exec}." :".$this->{idDisplay}."&>/dev/null&";
	system($cmd);
	$this->{pid}=$this->getPid();
	
	
		
	return $this;
}
sub stop
{
	my ($this)=@_;
	my $kill="kill -9 ".$this->{pid};
	`$kill`;
}
sub getDisplay
{
	my ($this)=@_;
	return $this->{idDisplay};
}
sub getPid
{
	my ($this)=@_;
	my $search="ps aux | grep Xvfb | grep -v 'grep' | grep ':".$this->{idDisplay}."'";
	my $ps=`$search`;
	chomp $ps;
	my @values=split(/\s+/,$ps);
	my $pid=$values[1];
	return $pid;
	
}
sub getLastDisplayId
{
	my $ps=`ps aux | grep Xvfb | grep -v 'grep'`;
	my @all_ps=split("\n",$ps);
	my $iddisplay=0;
	for(my $line=0;$line<=$#all_ps;$line++)
	{
		my @values=split(/\s+/,$all_ps[$line]);
		my $id=$values[$#values];
		if($id=~/\:(\d*)/)
		{
			if($1>$iddisplay)
			{
				$iddisplay=$1;
			}
		}
	}
	if($iddisplay==0){$iddisplay=15;};
	return $iddisplay;
	
}

1;