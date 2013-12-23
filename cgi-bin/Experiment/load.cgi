#!/usr/bin/env perl
$|=1;
use strict;
use Config::IniFiles;
use UPLOAD::upload;
use CGI ;
my $cgi=new CGI;



my $TMP='/tmp/';
UPLOAD::upload->new(-file=>'loadExperiment',-to=>$TMP);


print "Content-type: text/xml \n\n";

open(XML,$TMP.$cgi->param('loadExperiment'));

while(<XML>)
{
   print STDERR $_;
   print $_;
}
close XML;


