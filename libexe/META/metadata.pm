package META::metadata;
$VERSION='1.0';

use Config::IniFiles;
use strict;

sub new
{
	my ($class,%args)=@_;
	my $this={};
	$this->{FILE}=$args{-file};
	$this->{cfg}=Config::IniFiles->new();
	bless($this);
	return $this;
}

sub step1
{
	my ($this,%args)=@_;
	$this->{cfg}->AddSection("STEP1");
	$this->{cfg}->newval ("STEP1", "template", $args{-template});	
}
sub imagej
{
	my ($this,%args)=@_;
	$this->{cfg}->AddSection("IMAGEJ");
	$this->{cfg}->newval ("IMAGEJ", "search", $args{-search});
	$this->{cfg}->newval ("IMAGEJ", "blacks", $args{-blacks});	
}


sub write
{
	my ($this)=@_;
	$this->{cfg}->WriteConfig ($this->{FILE});
}


1;