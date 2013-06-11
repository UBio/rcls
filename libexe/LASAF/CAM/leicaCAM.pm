#
#  leicaCAM
#
#  Created by acarro on 2011-03-28.
#  Copyright (c) 2011 CNIO. All rights reserved.



package LASAF::CAM::leicaCAM;
$VERSION='1.0';

use strict;
use IO::Socket::INET;
use IO::Select;
use IO::Socket 'sockatmark';
use LASAF::UTILS::conversion;
$| = 1;
=head2 new

  Example    : leicaCAM->new();
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
	$this->{HOST}=$args{-host};
	$this->{IMAGES}=[];
	$this->{SYS}=0;
	$this->{UNITS}="";
	$this->{XPOS}="";
	$this->{YPOS}="";
	$this->{ZPOS}="";
	$this->{iniX}=0;
	$this->{iniY}=0;
	$this->{STATE}="NEW";
	$this->{CONVERSION}=LASAF::UTILS::conversion->new();
	
	if(!exists($args{-host}))
	{
		die "usage: new(-host=>HOST[,-port=>8895])\n";
	}
	if(exists($args{-port}))
	{
		$this->{PORT}=$args{-port};
	}
	else
	{
		$this->{PORT}=8895;
	}
	$this->{SOCKET}="";
	
	$this->{CLIENT}="CONFOCAL";
	
	if(exists($args{-client}))
	{
		$this->{CLIENT}=$args{-client};
	}
	bless($this);
	
	$this->{ISLOAD}="false";
	$this->{ISCLOSED}="false";
	$this->{ISFINISHAUTOFOCUS}="false";
	$this->{ISFINISHSTARTSCAN}="false";
	
	print STDERR "HOST: ".$this->{HOST}."\n";
	$this->{SOCKET} = new IO::Socket::INET->new(
	PeerHost => $this->{HOST},
	PeerPort => $this->{PORT},
	Proto => 'tcp'
	);
	if(!$this->{SOCKET})
	{
		print STDERR $this->TimeStamp()."\tERROR in Socket Creation : $!\n";
		exit 2;
	}


	
	
	
	$this->read();
	
	print STDERR $this->TimeStamp()."\tCONNECTED\n";
	$this->getsys();
	#inicializamos valores 

	
	return $this;
	
	
}
=head2 new

  Example    : leicaCAM->getsys();
  Description: This method returns a string that is considered to be
               the 'display' identifier.
  Returntype : String
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut

sub getsys
{
	my ($this)=@_;
	my $CMD="/cli:".$this->{CLIENT}." /app:matrix /cmd:getinfo /dev:stage";
	print STDERR $this->TimeStamp()."\tSEND TO ".$this->{HOST}.":".$this->{PORT}." CMD: ".$CMD."\n";
	my $mierda=$this->{SOCKET}->send($CMD);
	$this->{STATE}="GETSYS";
	my $socket=$this->{SOCKET};
	my $iResult=0;

# print "--------\n";
# 	my $data=<$socket>;
# 	print STDERR $data."\n";
# print "--------\n";

	$this->read();	
}
=head2 new

  Example    : leicaCAM->reconnect();
  Description: This method returns a string that is considered to be
               the 'display' identifier.
  Returntype : String
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub reconnect()
{
	my ($this)=@_;
	
	print STDERR $this->TimeStamp()."\tSEND TO ".$this->{HOST}.":".$this->{PORT}." RECONNECT\n";
	$this->close();
	
	$this->{SOCKET} = new IO::Socket::INET->new(
	PeerHost => $this->{HOST},
	PeerPort => $this->{PORT},
	Blocking =>0,
	Proto => 'tcp'
	) or die "ERROR in Socket Creation : $!\n";
	$this->{SOCKET}->autoflush(1);
	
	$this->read();
}

=head2 new

  Example    : leicaCAM->TimeStamp();
  Description: This method returns a string that is considered to be
               the 'display' identifier.
  Returntype : String
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut

sub TimeStamp()
{
	my ($this)=@_;
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
	return sprintf ("%4d-%02d-%02d %02d:%02d:%02d",$year+1900,$mon+1,$mday,$hour,$min,$sec);
}
=head2 new

  Example    : leicaCAM->getInfo();
  Description: This method returns a string that is considered to be
               the 'display' identifier.
  Returntype : String
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut

sub getInfo()
{
	my ($this)=@_;

	# print $client_socket."\n";
	my $CMD="/cli:".$this->{CLIENT}." /app:matrix /cmd:getinfo /dev:stage";
	print STDERR $this->TimeStamp()."\tSEND TO ".$this->{HOST}.":".$this->{PORT}." CMD: ".$CMD."\n";
	$this->{SOCKET}->send($CMD);
	
	$this->{STATE}="GETINFO";	
	$this->read();
}
=head2 new

  Example    : leicaCAM->setIniXY();
  Description: This method returns a string that is considered to be
               the 'display' identifier.
  Returntype : String
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub setIniXY()
{
	my ($this)=@_;
	$this->getInfo();
	$this->{iniX}=$this->{CONVERSION}->meters2microns(-meters=>$this->{XPOS});
	$this->{iniY}=$this->{CONVERSION}->meters2microns(-meters=>$this->{YPOS});
	print STDERR $this->TimeStamp()."\tINIT POSITION x:".$this->{iniX}." y:".$this->{iniY}."\n";
	
}
sub change_job()
{
	my ($this,%args)=@_;
	# /cli:embl /app:matrix /cmd:adjust /tar:pinhole /exp:job1 /value:1
	my $CMD="/cli:".$this->{CLIENT}." /app:matrix /cmd:adjust /tar:pinhole /exp:".$args{-job}." /value:1";
	print STDERR $this->TimeStamp()."\tSEND TO ".$this->{HOST}.":".$this->{PORT}." CMD: ".$CMD."\n";

	$this->{SOCKET}->send($CMD);
	$this->{STATE}="CHANGEJOB";
	$this->{ISCHANGEJOB}="false";
	
	print STDERR $this->TimeStamp()."\tNEW JOB: ".$args{-job};
	while($this->{ISCHANGEJOB} ne 'true')
	{
		print STDERR ".";
		$this->read();
	}
	
	print STDERR "\n";
	
	print STDERR $this->TimeStamp()."\tFINISHED: ".$args{-job}." ...\n";
	
}

=head2 new

  Example    : leicaCAM->close();
  Description: This method returns a string that is considered to be
               the 'display' identifier.
  Returntype : String
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub load_template
{
	my ($this,%args)=@_;

	if(!exists($args{-template}))
	{
		die "usage: load_template(-template=>TEMPLATE])\n";
	}
	my $CMD="/cli:".$this->{CLIENT}." /app:matrix /sys:".$this->{SYS}." /cmd:load /fil:{ScanningTemplate}".$args{-template}.".xml";
	print STDERR $this->TimeStamp()."\tSEND TO ".$this->{HOST}.":".$this->{PORT}." CMD: ".$CMD."\n";

	$this->{SOCKET}->send($CMD);
	$this->{STATE}="LOAD";
	
	print STDERR $this->TimeStamp()."\tLOADING ";
	while($this->{ISLOAD} ne 'true')
	{
		print STDERR ".";
		$this->read();
	}
	
	print STDERR "\n";
	
	print STDERR $this->TimeStamp()."\tREAD: ".$this->{HOST}.":".$this->{PORT}."\tLOADED TEMPLATE: ".$args{-template}." ...\n";

}

=head2 new

  Example    : leicaCAM->read();
  Description: This method returns a string that is considered to be
               the 'display' identifier.
  Returntype : String
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub read()
{
	my ($this)=@_;
	my $socket=$this->{SOCKET};
	my $iResult=0;
	# print STDERR $this->TimeStamp()."\tSTART ".$this->{STATE}."...\n";
	# my $data="";
	# # while (!$this->{SOCKET}->accept())
	# # {
	# # 	print "wait\n";
	# # }
	# # print " Data received from socket : \t$data\n";
	# # return;
	# my $start=0;
	# my $messageUnKnow=1;
	# my $count=0;
	
	my $select=new IO::Select();
	$select->add($socket);
	my $data;
	
	while($select->can_read(3))
	{		
		$socket->recv($data,1024);
		chomp $data;
		if($data =~ /^\/relpath:(.*)/)
		{
			# $messageUnKnow=0;
			$this->{IMAGES}->[$iResult]=$1;
			$iResult++;
		}
		else
		{
			print STDERR "\n".$this->TimeStamp()."\tRECV: $data\n";
		}
	}
	
	if($data =~ /Welcome client : (\d*)/)
	{
		print STDERR $this->TimeStamp()."\tPARSER:".$this->{HOST}.":".$this->{PORT}." Connected: $1\n";
	}
	
	if(($this->{STATE} eq "GETINFO" || $this->{STATE} eq "GETSYS") && $data =~ /\/app:matrix \/sys:(\d) \/dev:stage \/info_for:(.*) \/unit:(.*) \/xpos:(.*) \/ypos:(.*) \/zpos:(.*)/)
	{
		print STDERR $this->TimeStamp()."\tPARSER: ".$this->{HOST}.":".$this->{PORT}." units:$3\tx:$4\ty:$5\tz:$6 \n";
		if($this->{STATE} eq "GETSYS")
		{
			$this->{SYS}=$1;
		}
		if($this->{STATE} eq "GETINFO")
		{
			$this->{UNITS}=$3;
			$this->{XPOS}=$4;
			$this->{YPOS}=$5;
			$this->{ZPOS}=$6;
		}
	}
	if($this->{STATE} eq "LOAD" && $data =~ /\/cli:(.*) \/app:matrix \/sys:(\d) \/cmd:load \/fil:(.*)/)
	{
		if($1 eq $this->{CLIENT} && $2 == $this->{SYS})
		{
			$this->{ISLOAD}='true';
			print STDERR $this->TimeStamp()."\tLOAD: $3 \n";	
		}
	}
	if($this->{STATE} eq "STARTAUTOFOCUS" && $data =~ /\/app:matrix \/sys:(\d) \/inf:scanfinished/)
	{
		$this->{ISFINISHAUTOFOCUS}='true';
		print STDERR $this->TimeStamp()."\tFINISHED AUTOFOCUS\n";
	}
	if($this->{STATE} eq "STARTSCAN" && $data =~ /\/app:matrix \/sys:(\d) \/inf:scanfinished/)
	{
		$this->{ISFINISHSTARTSCAN}='true';
		print STDERR $this->TimeStamp()."\tFINISHED STARTSCAN\n";
	}
	
	# "/cli:".$this->{CLIENT}." /app:matrix /cmd:adjust /tar:pinhole /exp:".$args{-job}." /value:1";
	if($this->{STATE} eq "CHANGEJOB" && $data =~ /\/cli:(.*) \/app:matrix \/cmd:adjust \/tar:pinhole \/exp:(.*) \/value:(.*)/)
	{
		$this->{ISCHANGEJOB}='true';
		print STDERR $this->TimeStamp()."\tNEW JOB: $2\n";
	}

	
	# print STDERR $this->TimeStamp()."\tREAD FROM ".$this->{HOST}.":".$this->{PORT}." FINISH READ\n";	
}
=head2 new

  Example    : leicaCAM->start();
  Description: This method returns a string that is considered to be
               the 'display' identifier.
  Returntype : String
  Return	 : 
				When start:
				/app:matrix /sys:1 /inf:scanstart
				When finish:
				/app:matrix /sys:1 /inf:scanfinished
				When write one image:
				/relpath:<pathToImage>
				
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub start
{
	my ($this)=@_;
	my $CMD="/cli:".$this->{CLIENT}." /app:matrix /cmd:startscan";
	print STDERR $this->TimeStamp()."\tSEND TO ".$this->{HOST}.":".$this->{PORT}." CMD: ".$CMD."\n";
	my $result=$this->{SOCKET}->send($CMD);

	$this->{STATE}="STARTSCAN"; 
	
	print STDERR $this->TimeStamp()."\tSTART STARTSCAN ";
	while($this->{ISFINISHSTARTSCAN} ne 'true')
	{
		print STDERR ".";
		$this->read();
	}
	
	print STDERR "\n";
	
	$this->read();
}


=head2 new

  Example    : leicaCAM->stop();
  Description: This method returns a string that is considered to be
               the 'display' identifier.
  Returntype : String
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub stop
{
	my ($this)=@_;
	my $CMD="/cli:".$this->{CLIENT}." /app:matrix /cmd:stopscan";
	print STDERR $this->TimeStamp()."\tSEND TO ".$this->{HOST}.":".$this->{PORT}." CMD: ".$CMD."\n";
	my $result=$this->{SOCKET}->send($CMD);
}
=head2 new

  Example    : leicaCAM->pause();
  Description: This method returns a string that is considered to be
               the 'display' identifier.
  Returntype : String
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub pause
{
	my ($this)=@_;
	my $CMD="/cli:".$this->{CLIENT}." /app:matrix /cmd:pausescan";
	print STDERR $this->TimeStamp()."\tSEND TO ".$this->{HOST}.":".$this->{PORT}." CMD: ".$CMD."\n";
	my $result=$this->{SOCKET}->send($CMD);
}

=head2 new

  Example    : leicaCAM->start_cam();
  Description: This method returns a string that is considered to be
               the 'display' identifier.
  Returntype : String
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub start_cam
{
	my ($this)=@_;
	my $CMD="/cli:".$this->{CLIENT}." /app:matrix  /cmd:startcamscan /runtime:600 /repeattime:60";
	print STDERR $this->TimeStamp()."\tSEND TO ".$this->{HOST}.":".$this->{PORT}." CMD: ".$CMD."\n";
	my $result=$this->{SOCKET}->send($CMD);
}

=head2 new

  Example    : leicaCAM->stop_cam();
  Description: This method returns a string that is considered to be
               the 'display' identifier.
  Returntype : String
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut

sub stop_cam
{
	my ($this)=@_;
	my $CMD="/cli:".$this->{CLIENT}." /app:matrix  /cmd:stopcamscan";
	print STDERR $this->TimeStamp()."\tSEND TO ".$this->{HOST}.":".$this->{PORT}." CMD: ".$CMD."\n";
	my $result=$this->{SOCKET}->send($CMD);
}


=head2 new

  Example    : leicaCAM->setXY();
  Description: This method returns a string that is considered to be
               the 'display' identifier.
  Returntype : String
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub setXY
{
	my ($this,%args)=@_;

	if(!exists($args{-x}))
	{
		die "usage: setXY(-x=>X,-y=>Y[,-units=>meter|microns])\n";
	}
	if(!exists($args{-y}))
	{
		die "usage: setXY(-x=>X,-y=>Y[,-units=>meter|microns])\n";
	}
	my $units="meter";
	if($args{-units})
	{
		$units=$args{-units};
	}
	my $CMD="/cli:".$this->{CLIENT}." /app:matrix /sys:".$this->{SYS}." /cmd:setposition /typ:absolute /dev:stage /unit:".$units." /xpos:".$args{-x}." /ypos:".$args{-y};
	print STDERR $this->TimeStamp()."\tSEND TO ".$this->{HOST}.":".$this->{PORT}." CMD: ".$CMD."\n";
	$this->{SOCKET}->send($CMD);
	$this->{STATE}="SETXY";
	$this->read();



	
	
}
=head2 new

  Example    : leicaCAM->saveXY();
  Description: This method returns a string that is considered to be
               the 'display' identifier.
  Returntype : String
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub saveXY()
{
	my ($this)=@_;
	my $CMD="/cli:".$this->{CLIENT}." /app:matrix /sys:".$this->{SYS}." /cmd:savecurrentposition /dev:stage";
	print STDERR $this->TimeStamp()."\tSEND TO ".$this->{HOST}.":".$this->{PORT}." CMD: ".$CMD."\n";
	$this->{STATE}="SAVEXY";
	$this->{SOCKET}->send($CMD);
	$this->read();
}

=head2 new

  Example    : leicaCAM->setZ();
  Description: This method returns a string that is considered to be
               the 'display' identifier.
  Returntype : String
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub setZ
{
	my ($this,%args)=@_;

	if(!exists($args{-z}))
	{
		die "usage: setZ(-z=>Z[,-units=>meter|microns])\n";
	}
	my $units="meter";
	if($args{-units})
	{
		$units=$args{-units};
	}
	my $CMD="/cli:".$this->{CLIENT}." /app:matrix /sys:".$this->{SYS}." /cmd:setposition /typ:absolute /dev:zdrive /unit:".$units." /zpos:".$args{-z};
	print STDERR $this->TimeStamp()."\tSEND TO ".$this->{HOST}.":".$this->{PORT}." CMD: ".$CMD."\n";
	$this->{SOCKET}->send($CMD);
	my $socket=$this->{SOCKET};
	my $data=<$socket>;
	$data=<$socket>;
	print " Data received from socket : \t$data\n";
}
=head2 new

  Example    : leicaCAM->delete();
  Description: This method returns a string that is considered to be
               the 'display' identifier.
  Returntype : String
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub delete()
{
	my ($this)=@_;
	my $CMD="/cli:".$this->{CLIENT}." /app:matrix  /cmd:deletelist";
	print STDERR $this->TimeStamp()."\tSEND TO ".$this->{HOST}.":".$this->{PORT}." CMD: ".$CMD."\n";
	my $result=$this->{SOCKET}->send($CMD);
}

=head2 new

  Example    : leicaCAM->add();
  Description: This method returns a string that is considered to be
               the 'display' identifier.
  Returntype : String
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub add()
{
	my ($this,%args)=@_;
	if(!exists($args{-job}) && !exists($args{-slide}) && !exists($args{-x}) && !exists($args{-y}))
	{
		die "usage: add(-job=>JOB,-slide=>SLIDE, -x=>X ,-y=>Y)\n";
	}
	my $CMD="/cli:".$this->{CLIENT}." /app:matrix  /cmd:add /tar:camlist /exp:".$args{-job}." /ext:".$args{-type}." /slide:".$args{-slide}." /wellx:0 /welly:0 /fieldx:".$args{-x}." /fieldy:".$args{-y};
	print STDERR $this->TimeStamp()."\tSEND TO ".$this->{HOST}.":".$this->{PORT}." CMD: ".$CMD."\n";
	$this->{SOCKET}->send($CMD);
}

=head2 new

  Example    : leicaCAM->autofocus();
  Description: This method returns a string that is considered to be
               the 'display' identifier.
  Returntype : String
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub autofocus()
{
	my ($this)=@_;
	my $CMD="/cli:".$this->{CLIENT}." /app:matrix  /cmd:autofocusscan";
	print STDERR $this->TimeStamp()."\tSEND TO ".$this->{HOST}.":".$this->{PORT}." CMD: ".$CMD."\n";
	$this->{SOCKET}->send($CMD);
	$this->{STATE}="STARTAUTOFOCUS"; 
	
	print STDERR $this->TimeStamp()."\tSTART AUTOFOCUS ";
	while($this->{ISFINISHAUTOFOCUS} ne 'true')
	{
		print STDERR ".";
		$this->read();
	}
	
	print STDERR "\n";
	
	# $this->read();
	# my $socket=$this->{SOCKET};
	# my $data=<$socket>;
	# $data=<$socket>;
	# print " Data received from socket : \t$data\n";
}

=head2 new

  Example    : leicaCAM->scanWidthAF();
  Description: This method returns a string that is considered to be
               the 'display' identifier.
  Returntype : String
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub scanWidthAF()
{
	my ($this)=@_;
	$this->autofocus();
	$this->start();
}

 
=head2 new

  Example    : leicaCAM->multiScanFromFile();
  Description: This method returns a string that is considered to be
               the 'display' identifier.
  Returntype : String
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut

sub multiScanFromFile()
{
	my ($this,%args)=@_;
	if(!exists($args{-file}))
	{
		die "usage: multiScanFromFile(-file=>PATH_TO_FILE)\n";
	}
	
	open(IN,$args{-file}) || die $this->exit();
	while(<IN>)
	{
		chomp;
		if($_ !~ /BX\tBY\tWidth\tHeight/)
		{
			my @linea=split(/\s+/,$_);
			$linea[1]=$this->{iniX}+$this->{CONVERSION}->meters2microns(-meters=>$this->inch2Meters(-inch=>$linea[1]));
			$linea[2]=$this->{iniY}+$this->{CONVERSION}->meters2microns(-meters=>$this->inch2Meters(-inch=>$linea[2]));

			print STDERR $this->TimeStamp()."\tNEW POSITION x:".$linea[1]."\ty:".$linea[2]."\n";

			my $resul=$this->setXY(-x=>$linea[1],-y=>$linea[2],-units=>"microns");
			# sleep(5);
			if($resul != -1)
			{
				$this->autofocus();
				# $this->start();
			}
			print STDERR "========================================================\n";
		}
	}
	close(IN);
}



=head2 new

  Example    : leicaCAM->AFscanFromTemplate();
  Description: This method returns a string that is considered to be
               the 'display' identifier.
  Returntype : String
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub AFscanFromTemplate()
{
	my ($this,%args)=@_;
	$this->load_template(-template=>$args{-template});
	$this->autofocus();
	$this->start();
}


=head2 new

  Example    : leicaCAM->exit();
  Description: This method returns a string that is considered to be
               the 'display' identifier.
  Returntype : String
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub exit()
{
	my ($this)=@_;
	$this->close();
	print $!."\n";
	exit;
}

=head2 new

  Example    : leicaCAM->close();
  Description: This method returns a string that is considered to be
               the 'display' identifier.
  Returntype : String
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub close()
{
	my ($this)=@_;
	
	$this->{SOCKET}->close();
	$this->{ISCLOSED}="true";
	print STDERR "CLOSE SOCKET\n";
	$this->{SOCKET}="";
}

=head2 new

  Example    : leicaCAM->isclosed();
  Description: This method returns a string that is considered to be
               the 'display' identifier.
  Returntype : String
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut

sub isclosed()
{
	my ($this)=@_;
	return $this->{ISCLOSED};
}
1;




