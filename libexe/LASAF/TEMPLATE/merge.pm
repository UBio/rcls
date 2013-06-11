package LASAF::TEMPLATE::merge;
$VERSION='1.0';

use strict;
use LASAF::TEMPLATE::template;

sub new
{
	my ($class,%args)=@_;
	
	my $this={};
	$this->{FILES}=();
	my %error_Struct;
	$error_Struct{'code'}=0;
	$error_Struct{'msg'}="CORRECT";

	$this->{ERROR}=\%error_Struct;
	$this->{TOTALWELLS}=0;
	$this->{TOTALFIELDS}=0;
	$this->{output}=$args{-output};
	$this->{root}="";
	my @files;
	

	
	bless($this);
	$this->{root}=$args{-templatesdir};
	for(my $i=1;$i<scalar(@{$args{-files}});$i++)
	{
		my $file_template=$args{-templatesdir}.'/{ScanningTemplate}'.$args{-files}->[$i].'.xml';
		if(-e $file_template)
		{
			push @files,  LASAF::TEMPLATE::template->new(-template=>$file_template);
		}
		else
		{
			$this->{ERROR}->{'code'}=-1;
			$this->{ERROR}->{'msg'}="File not exists: $file_template";
			return %{$this->{ERROR}};
		}
		
	}
	$this->{FILES}=\@files;
	if($this->check()==-1)
	{
		return %{$this->{ERROR}};
	}
	else
	{
		$this->merge();
	}
	return $this;
}

sub check
{
	my ($this)=@_;
	print STDERR "Check Scanning templates for merge files ..... ";
	my $cols=$this->{FILES}->[0]->getCols();
	my $rows=$this->{FILES}->[0]->getRows();
	$this->{TOTALWELLS}=$this->{FILES}->[0]->getTotalWells();
	$this->{TOTALFIELDS}=$this->{FILES}->[0]->getTotalFields();
	$this->{TOTALASIGNEDJOB}=$this->{FILES}->[0]->getTotalJobs();
	for(my $i=1;$i<scalar(@{$this->{FILES}});$i++)
	{
		$this->{TOTALWELLS}+=$this->{FILES}->[$i]->getTotalWells();
		$this->{TOTALFIELDS}+=$this->{FILES}->[$i]->getTotalFields();
		$this->{TOTALASIGNEDJOB}+=$this->{FILES}->[$i]->getTotalJobs();
		
		if($cols!=$this->{FILES}->[$i]->getCols() || $rows != $this->{FILES}->[$i]->getRows())
		{
			print "ERROR\n";
			$this->{ERROR}->{'code'}=-1;
			$this->{ERROR}->{'msg'}="Well Size Incorrect";
			return -1;
		}
	}
	print "OK\n";
	return 0;
}


sub merge()
{
	my ($this)=@_;
	$this->{FILES}->[0]->setTotalWells(-wells=>$this->{TOTALWELLS});
	$this->{FILES}->[0]->setTotalFields(-fields=>$this->{TOTALFIELDS});
	$this->{FILES}->[0]->setTotalJobs(-jobs=>$this->{TOTALASIGNEDJOB});
	$this->{FILES}->[0]->setWellsDistance(-wellsX=>$this->{FILES}->[0]->getCols()-1,-wellsY=>$this->{FILES}->[0]->getRows()-1);
	$this->{FILES}->[0]->setCountOfWells(-wells=>$this->{TOTALWELLS});
	
	my $ScanWellArray=$this->{FILES}->[0]->getScanWellArray();
	my $ScanFieldArray=$this->{FILES}->[0]->getScanFieldArray();
	my $owner=$this->{FILES}->[0]->getOwner();
	
	my $lastElement=$this->{FILES}->[0]->getLengthWellData();
	my $lastWellX=$this->{FILES}->[0]->getScanWellXData(-item=>$lastElement-1);
	my $nextWellX=$lastWellX;
	my $label=1;
	my $jobid=$this->{FILES}->[0]->getScanFieldData(-item=>0)->getAttribute('JobId');
	
	
	for(my $i=1;$i<scalar(@{$this->{FILES}});$i++)
	{
		my $len=$this->{FILES}->[$i]->getLengthFieldData();
		my $currentWell=0;
		for(my $iFieldData=0;$iFieldData<$len;$iFieldData++)
		{
			my $ScanFieldData=$this->{FILES}->[1]->getScanFieldData(-item=>$iFieldData);
			if($ScanFieldData)
			{
				my $nodeField=$ScanFieldData->cloneNode(1);
				$nodeField->setOwnerDocument($owner);
				if($nodeField->getAttribute('FieldX')==1 and $nodeField->getAttribute('FieldY')==1)
				{
					$nextWellX++;
					my $ScanWellData=$this->{FILES}->[1]->getScanWellData(-item=>$currentWell);
					my $node=$ScanWellData->cloneNode(1);
					$node->setOwnerDocument($owner);
					$node->setAttribute ("WellX",$nextWellX);
					$ScanWellArray->[0]->appendChild($node);
					$currentWell++;
				}
				$nodeField->setAttribute("JobId",$jobid);
				$nodeField->setAttribute("WellX",$nextWellX);
				$ScanFieldArray->[0]->appendChild($nodeField);
			}
		}
	}
	# 
	
	$this->{FILES}->[0]->write(-file=>$this->{root}.'/'.$this->{output}.".$$");
}



























1;