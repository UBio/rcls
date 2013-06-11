#!/usr/bin/env perl
$|=1;
use strict;


use CGI ;
my $cgi=new CGI;
my $seg=$cgi->param("seg");


print "Content-type: text/txt \n\n";
sleep($seg);