package LIB::mount;
$VERSION='1.0';

@ISA=qw(Exporter);
@EXPORT=qw(mountall mount check_mount);
use strict;
use HTTP::Status qw(is_success status_message);
use File::Basename;

sub mountall
{
	my $cfg_confocal = Config::IniFiles->new( -file => $ENV{CONFOCAL_INI});	
	my $dirmounts=$cfg_confocal->val('SHARE','bin');
	
	opendir(DIR,$dirmounts) || die $!."\n" ;
	while( (my $filename = readdir(DIR)))
	{
		if($filename =~ /^mount\.(.*)/)
		{
			if(check_mount(-name=>$1) ne 'OK')
			{
				my $mounts=$dirmounts.$filename;
				my $CMDmount="ssh -t -o StrictHostKeyChecking=no confocal\@localhost 'sudo $mounts'";
				print STDERR $CMDmount;
				my $ERROR=`$CMDmount`;
				$ERROR=~s/Connection to localhost closed//gi;
				if($ERROR ne '')
				{
					return $ERROR;
				}
			}
		}
	}
	close DIR;
	return 'OK';
}

sub mount
{
	my (%args) = @_;
	my $name=$args{-name};
	my $cfg_confocal = Config::IniFiles->new( -file => $ENV{CONFOCAL_INI});	
	my $mounts=$cfg_confocal->val('SHARE','bin');
	
	my $mounts=$mounts."/mount\.$name";
	
	my $CMDmount="ssh -t  -o StrictHostKeyChecking=no confocal\@localhost 'sudo $mounts'";
	print STDERR $CMDmount;
	my $ERROR=`$CMDmount`;
	$ERROR=~s/Connection to localhost closed//gi;
	if($ERROR ne '')
	{
		return $ERROR;
	}
	return 'OK';
}

sub check_mount
{
	my (%args) = @_;
	my $name=$args{-name};
	my $cfg_confocal = Config::IniFiles->new( -file => $ENV{CONFOCAL_INI});	
	my $mounts=$cfg_confocal->val('SHARE','bin');
	
	my $mounts=$mounts."/mount\.$name";
	
	my $current_mount=`mount`;
	open(IN,$mounts) || die "No puedo abrir el fichero $mounts";
	my $ERROR='OK';
	while(<IN>)
	{
		chomp;
		if($_ =~ /^mount/)
		{
			my @mount=split(/\s+/,$_);
			if($current_mount =~ /$mount[3]/g)
			{
				print STDERR "Warnning: this point is mounted yet: ".$mount[3]."\n";
			}
			
			if($current_mount =~ /$mount[4]/g)
			{
				print STDERR "ERROR: this dir have one mounted point: ".$mount[4]."\n";
				return 'NOT OK';
			}
		}
	}
	close IN;
	return $ERROR;
}







1;
