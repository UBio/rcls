#
#  Image::utils
#
#  Created by acarro on 2011-03-29.
#  Copyright (c) 2011 CNIO. All rights reserved.



package LICENSE::check;
$VERSION='1.0';

use strict;
use Config::IniFiles;
use File::Basename;
use LWP::UserAgent;
use HTML::Parse;
use LOGS::simple;
# -1 Missing license number
# -2 Invalid license number
# -3 Invalid mac address
# -4 Not connect with license server
sub new
{
	my ($class,%args)=@_;
	my $this={};
	bless($this);
	my $cfg_confocal;
	my $log_rcls=LOGS::simple->new();
	
	
	if(-e $ENV{CONFOCAL_INI})
	{
		$cfg_confocal = Config::IniFiles->new( -file => $ENV{CONFOCAL_INI});
	}
	if($cfg_confocal)
	{
		$this->{ERROR}="OK";
		$this->{NUMBER_LICENSE}="";

	
		my @license=$cfg_confocal->Parameters('LICENSE');
		if($#license<0)
		{
			# print STDERR "Missing license number\n";
			$log_rcls->print(-msg=>"Missing license number");
			$this->{ERROR}=-1;
		}
		else
		{
			$this->{NUMBER_LICENSE}=$cfg_confocal->val( 'LICENSE', 'license');
		
			if($this->{NUMBER_LICENSE} eq '')
			{
				# print STDERR "Invalid license number\n";
				$log_rcls->print(-msg=>"Invalid license number");
				$this->{ERROR}=-2;
			}
			$this->{MAC_ADDRESS}=$this->get_mac_address();
			if($this->{MAC_ADDRESS} eq '')
			{
				# print STDERR "Invalid mac address\n";
				$log_rcls->print(-msg=>"Invalid mac address");
				$this->{ERROR}=-3;
			}
			# print STDERR "MAC: ".$this->{MAC_ADDRESS}." LICENSE:".$this->{NUMBER_LICENSE}."\n";
			$log_rcls->print(-msg=>"MAC: ".$this->{MAC_ADDRESS}." LICENSE:".$this->{NUMBER_LICENSE});
		}
	
		if($this->{ERROR} eq 'OK')
		{
			my $check_result=$this->check();

			if($check_result ne 'OK')
			{
				$log_rcls->print(-msg=>"Licencia: ".$this->{NUMBER_LICENSE}." no valid");
				# print STDERR "Licencia: ".$this->{NUMBER_LICENSE}." no valid\n";
				$this->{ERROR}=-2;
			}
		}
	}
	$log_rcls->close();
	return $this;
}
sub check
{
	my ($this)=@_;
	use FindBin qw($Bin);
	my $mac=substr($this->{MAC_ADDRESS},-8);
	my $CMD=$Bin."/LICENSE/bin/decrypt '".$this->{NUMBER_LICENSE}."' ".$mac;
	my $log_rcls=LOGS::simple->new();
	$log_rcls->print(-msg=>$CMD);
	$log_rcls->close();
	# print  STDERR $CMD."\n";
	my $response=`$CMD`;
	my $licenseStatus='NO_OK';
	if($response==1)
	{
		$licenseStatus='OK';
	}
	
	

	return $licenseStatus;

}
sub get_mac_address
{
	my ($this)=@_;
	my $mac;
	my $ifconfig=`/sbin/ifconfig`;
	if($ifconfig =~ /(\w\w:\w\w:\w\w:\w\w:\w\w:\w\w)/)
	{
		$mac=$1;
	}
	if($ifconfig =~ /ether\s+(\w\w:\w\w:\w\w:\w\w:\w\w:\w\w)/)
	{
	 	$mac=$1;
	 }
	 if($ifconfig =~ /HWaddr\s+(\w\w:\w\w:\w\w:\w\w:\w\w:\w\w)/)
	 {
	 	$mac=$1;
	 }
	$mac=~s/\://g;
	return $mac;
}
1;
























