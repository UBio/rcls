#
#  distances
#
#  Created by acarro on 2011-04-26.
#  Copyright (c) 2011 CNIO. All rights reserved.



package LASAF::UTILS::distances;
$VERSION='1.0';
use strict;
=head2 new

  Example    : conversion->new();
  Description: This method returns a string that is considered to be
               the 'display' identifier.
  Returntype : String
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut

sub sort{
	my ($class,%args)=@_;

	my $this={};
	$this->{DATA}=$args{-data};
	bless($this);
	
	$this->distances();
	# $this->show();
	$this->sDistances();
	$this->showCamino();
	return $this;
}

sub distances
{
	my ($this)=@_;
	my @data=@{$this->{DATA}};
	my @distancias;
	
	for(my $i=0;$i<=$#data;$i++)
	{
		my @aux;
		for(my $j=0;$j<=$#data;$j++)
		{
			my $distancia=0;
			if($i!=$j)
			{
				my ($x1,$y1)=($data[$i]->{x},$data[$i]->{y});
				my ($x2,$y2)=($data[$j]->{x},$data[$j]->{y});
				$distancia=sqrt(($x2-$x1)**2+($y2-$y1)**2);
			}
			$aux[$j]=$distancia;
		}
	 	$distancias[$i]=\@aux;
	}
	
	$this->{DISTANCES}=\@distancias;
}
sub show()
{
	my ($this)=@_;
	my @distancias=@{$this->{DISTANCES}};

	for(my $i=0;$i<=$#distancias;$i++)
	{
		my @aux=@{$distancias[$i]};
		for(my $j=0;$j<=$#distancias;$j++)
		{
			print $aux[$j]."\t";
		}
		print "\n";
	}
}

sub sDistances()
{
	my ($this)=@_;
	my @distancias=@{$this->{DISTANCES}};
	my $distancia=99;
	my $next=0;
	my $last=0;
	my %visitados;
	my $ivistados=1;
	my @camino;
	# for(my $i=0;$i<=$#distancias;$i++)
	push @camino,0;
	$visitados{$next}=1;
	while($ivistados!=scalar(@distancias))
	{	
		my @aux=@{$distancias[$next]};
		$distancia=99;
		my $j;
		for($j=0;$j<=$#distancias;$j++)
		{	
			if(!exists($visitados{$j}) && $aux[$j]>0 && $aux[$j]<=$distancia)
			{
				
				$distancia=$aux[$j];
				$next=$j;
			}
		}
		$visitados{$next}=1;
		$ivistados++;
		# print $last."\t".$next."\t".$distancia."\n";
		$last=$next;
		push @camino,$last;
	}
	$this->{CAMINO}=\@camino;
}
sub showCamino
{
	my ($this)=@_;
	my @camino=@{$this->{CAMINO}};
	for(my $i=0;$i<=$#camino;$i++)
	{
		print $camino[$i]."\t";
	}
	print "\n";
}
1;

=head1 NAME

::conversion;

=head1 SYNOPSIS


=head1 DESCRIPTION

A representation of a mature miRNA.

=head1 contact

Questions may be sent to the Ubio help desk at
<bioinfo_support@cnio.es>.


