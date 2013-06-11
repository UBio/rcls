#
#  conversion
#
#  Created by acarro on 2011-04-26.
#  Copyright (c) 2011 CNIO. All rights reserved.



package LASAF::UTILS::conversion;
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

sub new{
	my ($class,%args)=@_;

	my $this={};

	bless($this);
	return $this;
}

=head2 new

  Example    : conversion->inch2Meters();
  Description: This method returns a string that is considered to be
               the 'display' identifier.
  Returntype : String
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub inch2Meters()
{
	# 1 Inch = 0.0254 Meters 
	my ($this,%args)=@_;
	if(!exists($args{-inch}))
	{
		return 0.0254;
	}
	my $res=0.0254*$args{-inch};
	# print $args{-inch}." are ".$res."\n";
	return 0.0254*$args{-inch};
}

=head2 new

  Example    : conversion->meters2microns();
  Description: This method returns a string that is considered to be
               the 'display' identifier.
  Returntype : String
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub meters2microns()
{
	# 1 Meter = 1000000 Microns 
	my ($this,%args)=@_;
	if(!exists($args{-meters}))
	{
		return 1000000;
	}
	my $res=1000000*$args{-meters};
	# print $args{-meters}." are ".$res."\n";
	return $res;
}
=head2 new

  Example    : conversion->microns2meters();
  Description: This method returns a string that is considered to be
               the 'display' identifier.
  Returntype : String
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub microns2meters()
{
	# 1 Meter = 1000000 Microns 
	my ($this,%args)=@_;
	if(!exists($args{-microns}))
	{
		return 0.000001;
	}
	my $res=$args{-microns}/1000000;
	# print $args{-meters}." are ".$res."\n";
	return $res;
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


