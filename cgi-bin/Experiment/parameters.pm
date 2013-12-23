#
#  template
#
#  Created by acarro on 2011-03-28.
#  Copyright (c) 2011 CNIO. All rights reserved.



package parameters;
$VERSION='1.0';

use strict;
use XML::DOM;
use File::Basename;

=head2 new

  Example    : template->new();
  Description: Es el constructor de la clase, abre los fichero xml y lrp para su posterior manejo.
  Params:	 : zoom, dimension, template
  Returntype : objeto de la clase template
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut

sub new
{
	my ($class,%args)=@_;
	my $this={};
	$this->{doc} = XML::DOM::Document->new();
	$this->{root}=$this->{doc}->createElement('mscr');

	$this->{microscope}=$this->{doc}->createElement('microscope');
	$this->{root}->appendChild($this->{microscope});
	
	$this->{low}=$this->{doc}->createElement('low');
	$this->{root}->appendChild($this->{low});
	
	
	$this->{detection}=$this->{doc}->createElement('detection');
	$this->{rm_blacks}=$this->{doc}->createElement('remove_blacks');
	$this->{detection}->appendChild($this->{rm_blacks});
	
	
	$this->{advanced_options}=$this->{doc}->createElement('advanced_options');
	$this->{threshold}=$this->{doc}->createElement('threshold');
	$this->{size}=$this->{doc}->createElement('size');
	$this->{circularity}=$this->{doc}->createElement('circularity');
	$this->{advanced_options}->appendChild($this->{threshold});
	$this->{advanced_options}->appendChild($this->{size});
	$this->{advanced_options}->appendChild($this->{circularity});
	
	$this->{detection}->appendChild($this->{advanced_options});
	$this->{root}->appendChild($this->{detection});
	
	
	$this->{high}=$this->{doc}->createElement('high');
	$this->{root}->appendChild($this->{high});
	
	$this->{stitching}=$this->{doc}->createElement('stitching');
	$this->{root}->appendChild($this->{stitching});
	
	# print STDERR $this->{root}->toString();
	
	bless($this);

	return $this;
}

=head2 new

  Example    : template->new();
  Description: Comprueba el valor de la etiqueta <EnableCAM>true</EnableCAM>
  Params:	 : none
  Returntype : true o false
  Exceptions : none
  Caller     : web drawing code
  Status     : Stable

=cut
sub set_microscope
{
	my ($this,%args)=@_;
	$this->{microscope}->setAttribute('name',$args{-name});
	$this->{microscope}->setAttribute('experiment',$args{-experiment});
}

sub set_low
{
	my ($this,%args)=@_;
	$this->{low}->setAttribute('template',$args{-template});
}

sub set_detection
{
	my ($this,%args)=@_;
	$this->{detection}->setAttribute('routine_name',$args{-routine_name});
	$this->{detection}->setAttribute('template',$args{-template});
	$this->{detection}->setAttribute('correction',$args{-correction});

	$this->{rm_blacks}->setAttribute('value',$args{-rm_blacks});
	$this->{rm_blacks}->setAttribute('template',$args{-rm_blacks_template});
	
	$this->{threshold}->setAttribute('min',$args{-threshold_min});
	$this->{threshold}->setAttribute('max',$args{-threshold_max});
	$this->{size}->setAttribute('min',$args{-size_min});
	$this->{size}->setAttribute('max',$args{-size_max});
	$this->{circularity}->setAttribute('circularity',$args{-circularity});
	
}
sub set_high
{
	my ($this,%args)=@_;
	$this->{high}->setAttribute('all',$args{-all});
}
sub set_stitching
{
	my ($this,%args)=@_;
	$this->{stitching}->setAttribute('code_color',$args{-code_color});
	$this->{stitching}->setAttribute('routine_name',$args{-routine_name});
}
sub print_stderr
{
	my ($this)=@_;
	print STDERR $this->{root}->toString();
}
sub print
{
	my ($this)=@_;
	print '<?xml version="1.0" encoding="UTF-8" ?>'."\n";
	print $this->{root}->toString();
}

