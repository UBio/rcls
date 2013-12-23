package CORE::status;
$VERSION='1.0';
require Exporter;
@ISA=qw(Exporter);
@EXPORT=qw(status_end status_next status_del_file status_ini status_current);
use strict;

sub status_end
{
	my %args=@_;
	my $cfg_confocal = Config::IniFiles->new( -file => $ENV{CONFOCAL_INI});
	
	my $tmp_file_status=$cfg_confocal->val('FILES','tmp')."/status_".$args{-name_micro} || die $!;
	open(STAT,'>'.$tmp_file_status);
	print STAT "end\n";
	close STAT;
	sleep 2;
}
sub status_next
{
	my %args=@_;
	my $cfg_confocal = Config::IniFiles->new( -file => $ENV{CONFOCAL_INI});
	
	my $tmp_file_status=$cfg_confocal->val('FILES','tmp')."/status_".$args{-name_micro};
	open(STAT,'>'.$tmp_file_status);
	print STAT "next\n";
	close STAT;
	sleep 2;
}
sub status_del_file
{
	my $cfg_confocal = Config::IniFiles->new( -file => $ENV{CONFOCAL_INI});
	my %args=@_;
	my $tmp_file_status=$cfg_confocal->val('FILES','tmp')."/status_".$args{-name_micro};
	unlink $tmp_file_status;
}
sub status_ini
{
	my $cfg_confocal = Config::IniFiles->new( -file => $ENV{CONFOCAL_INI});
	my %args=@_;
	my $tmp_file_status=$cfg_confocal->val('FILES','tmp')."/status_".$args{-name_micro};
	open(STAT,'>'.$tmp_file_status);
	print STAT "TOTALWELLS:".$args{-totalwells}." TOTALFIELDS:".$args{-totalfields}."\n";
	close STAT;
	sleep 2;
}
sub status_current
{
	my $cfg_confocal = Config::IniFiles->new( -file => $ENV{CONFOCAL_INI});
	my %args=@_;
	my $tmp_file_status=$cfg_confocal->val('FILES','tmp')."/status_".$args{-name_micro};
	open(STAT,'>>'.$tmp_file_status);
	print STAT $args{-stat}."\n";
	close STAT;
}