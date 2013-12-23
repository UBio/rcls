#!/usr/bin/env perl
$|=1;
use strict;
use Config::IniFiles;

use CGI ;
my $cgi=new CGI;
my $micro=$cgi->param("micro");
my $init=$cgi->param("init");


print "Content-type: text/txt \n\n";


my $cfg_confocal = Config::IniFiles->new( -file => $ENV{CONFOCAL_INI});
my $tmp=$cfg_confocal->val( 'FILES', 'tmp' );
my $file_status=$tmp.'/status_'.$micro;

if($init==1)
{
  while(!-e $file_status)
  {  
  }
  
  while(1)
  {

	  
	  open(DAT,$file_status);
	  my $init=<DAT>;
	  my $totalwells;
	  my $totalfields;
	  if($init =~ /TOTALWELLS:(\d+) TOTALFIELDS:(\d+)/)
	  {
	    $totalwells=$1;
	    $totalfields=$2*$1;
		close DAT;
  	  	print "[{'wells':$totalwells,'fields':$totalfields}]";
  	  	exit 0;
	  }
	  close DAT;
	  if(!-e $file_status || $init=~'end')
	  {
		  print 'end';
		  exit 0;
	  }
  }
}
else
{
  if(-e $file_status)
  {
    # my $last_line=`tail -1 $file_status`;
    open(DAT,$file_status);
    my $last_line=<DAT>;
	chomp $last_line;
	
	# print STDERR "READ:".$last_line."\n";
    if($last_line =~ /STAT:(\d+),(\d+)/)
    {
		# print STDERR "Line: ".$last_line."\n";
        print "[{'well':$1,'field':$2}]";
    }
	else
	{
		if($last_line=~ /^next/)
		{
			print 'next';
		}
		else
		{
			print 'noack';
		}
	}
  }
  else
  {
    print 'end';
  }
}
