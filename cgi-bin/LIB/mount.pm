package LIB::mount;
$VERSION='1.0';

@ISA=qw(Exporter);
@EXPORT=qw(mountall mount check_mount new_mount umount);
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
			if(check_mount(-name=>$1) eq 'OK')
			{
				my $mounts=$dirmounts.'/'.$filename;
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
sub new_mount
{
	my (%args) = @_;
	my $ip=$args{-ip};
	my $cfg_confocal = Config::IniFiles->new( -file => $ENV{CONFOCAL_INI});	
	my $UID=$cfg_confocal->val('USER','uid');
	
	my $shared_images=$args{-dir_shared_images};
	my $shared_templates=$args{-dir_shared_templates};
	my $user=$args{-user};
	my $passwors=$args{-password};
	my $name_micro=$args{-name_micro};
	my $dir_bin_mounts=$args{-dir_bin_mounts};
	my $win_shared_images=$args{-win_shared_images};
	my $win_shared_templates=$args{-win_shared_templates};

						
	if(-e $shared_images || -e $shared_templates)
	{
		if(-e  $shared_images)
		{
			# print_http_response(431,$HTTP_ERROR_431);
            return -1;
		}
		if(-e $shared_templates)
		{
			# print_http_response(431,$HTTP_ERROR_432);
			return -2;
		}
	}

	system("mkdir -p $shared_images");
	system("mkdir -p $shared_templates");
	
	open(MNT,">".$dir_bin_mounts."/mount\.".$name_micro);
	print MNT "#!/bin/bash\n";
	# print MNT "echo 'Mounting Images: $name'\n";
	print MNT 'mount -t cifs //'.$ip.'/'.$win_shared_images.' '. $shared_images.' -o user='.$user.",uid=".$UID.",password='".$passwors."' -rw\n";
	# print MNT "echo 'Mounting Templates: $name'\n";
	print MNT 'mount -t cifs //'.$ip.'/'.$win_shared_templates.' '. $shared_templates.' -o user='.$user.",uid=".$UID.",password='".$passwors."' -rw\n";
	close MNT;
	
	open(MNT,">".$dir_bin_mounts."/umount\.".$name_micro);
	print MNT "#!/bin/bash\n";
	# print MNT "echo 'uMounting Images: $name'\n";
	print MNT "umount ". $shared_images."\n";
	# print MNT "echo 'uMounting Templates: $name'\n";
	print MNT "umount ".$shared_templates."\n";
	close MNT;
	
	system("chmod +x $dir_bin_mounts/*");
	
	return 0;
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


sub umount
{
	my (%args) = @_;
	my $name=$args{-name};
	my $cfg_confocal = Config::IniFiles->new( -file => $ENV{CONFOCAL_INI});	
	my $mounts=$cfg_confocal->val('SHARE','bin');
	
	my $mounts=$mounts."/umount\.$name";
	
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
