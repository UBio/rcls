#
#  Virtual Display
#
#  Created by acarro on 2011-03-29.
#  Copyright (c) 2011 CNIO. All rights reserved.



package LOGS::simple;
$VERSION='1.0';

use strict;
use Config::IniFiles;
use File::Basename;
use POSIX qw(strftime);
# use DateTime;
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
	# $this->{date}=DateTime->new();
	my $fh;
	open $fh, ">>".$cfg_confocal->val( 'FILES', 'tmp' )."/".$cfg_confocal->val( 'DEBUG', 'errorlog' );
		
	$this->{log}=$fh;
	
	bless($this);
	return $this;
}
sub print
{
	my ($this,%args)=@_;
	my $fh=$this->{log};
	my $now_string=strftime("%a %b %e %H:%M:%S %Y", localtime);
	print $fh $now_string."\t".$args{-msg}."\n";
	
}
sub close
{
	my ($this)=@_;
	my $fh=$this->{log};
	close $fh;
}

1;