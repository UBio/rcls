#!/usr/bin/env perl

use strict;
use Getopt::Long;
use File::Basename;
use FindBin qw($Bin);
use LWP::Simple;
use lib "$Bin/../cgi-bin";
use INITIALIZE::LICENSE::check;

my $help;
# my $tmpFile;

GetOptions(
    "help"=>\$help
);

sub help
{
	my $usage=qq{
		ConfApp.pl;
	};
	print $usage."\n";
}

# if(!$tmpFile)
# {
# 	system('mkdir -p '.$tmpFile);
# }

# if(!-e $tmpFile)
# {
# 	print "FAIL!!!!!!! no existe el directorio temporal\n";
# 	exit -1;
# }
$ENV{PERL5LIB}.=":$Bin/../libexe:$Bin/../cgi-bin:$Bin/../cgi-bin/INITIALIZE";
print 'PERL5LIB='.$ENV{PERL5LIB}."\n";
my $confocal_root=`cd .. && pwd`;
$confocal_root=dirname($Bin);
print 'CONFOCAL ROOT='.$confocal_root."\n";
chomp $confocal_root;
my $modulesperl=`./CheckModulesPerl ../.`;
print $modulesperl."\n";


#open STDERR, '/dev/null';
my $license = LICENSE::check->new(-install=>1);
my $mac=$license->get_mac_address();
$mac=substr($mac,-8);
my $url="http://ubio.bioinfo.cnio.es/extras/licenses/getlicense.cgi?server=confocal&mac=".$mac;
#close STDERR;
my $license_number = get $url;
if($license_number ne '')
{
	my $status_msg="License: ";
	print $status_msg." " x (50-length($status_msg)).$license_number."\n";
}
else
{
	my $error=qq{
		Can not connect with the server
		
		Please, you write this url:
			$url
		in a browser and paste the results in the next line.
		
		Thank you!!!!!
		
		
};
print $error;
print "Insert License Number: ";
chomp ($license_number = <>);

}
my $requisitos=0;
# if($modulesperl =~ /Not Found/i)
# {
# 	print "Fail!!!!! Check PERL5LIB\n";
# 	$requisitos=1;
# }
my $pathXvfb=`which Xvfb`;
my $pathJava=`which java`;
my $pathConvert=`which convert`;
my $GCC=`which gcc`;
my $GXX=`which g++-4.4`;

my $arch=`uname`;
$arch=~s/\n//g;
my $decrypt_dir='cd '.$Bin.'/../cgi-bin/INITIALIZE/LICENSE/bin/';
my $status_msg="Compile decrypt: ";
print $status_msg." " x (50-length($status_msg));

if($arch eq 'Linux')
{
	$GXX=~s/\n//g;
	if($GXX ne '')
	{
		my $CMD=$GXX.' -lcrypt decrypt.cpp -o decrypt';
		my $res=`$decrypt_dir ; $CMD`;
		print "Finished\n";
	}
	else
	{
		print "ERROR: install g++-4.4\n";
	}
}
else
{
	if($arch eq 'Darwin')
	{
		$GCC=~s/\n//g;
		if($GCC ne '')
		{
			my $CMD=$GCC.'  decrypt.cpp -o decrypt';
			my $res=`$decrypt_dir ; $CMD`;
			print "Finished\n";
		}
		else
		{
			print "ERROR: install gcc\n";
		}
	}
	else
	{
		print "ERROR: unknow arch\n";
	}
}

my @programs=('Xvfb','java','convert');


for(my $i=0;$i<=$#programs;$i++)
{
	my $path=`which $programs[$i]`;
	chomp $path;
	my $status_msg="Check: ".$programs[$i];
	print $status_msg." " x (50-length($status_msg));
	if($path ne  '')
	{
		print "Found in: ".$path."\n";
	}
	else
	{
		$requisitos=1;
		print "Not Found\n";
	}
}

if($requisitos==1)
{
	print "Fail!!!!! Check Requisitos\n";
}
else
{
	print "Generando confocal.ini\n";
	my $template='../CONF/confocal.ini.template';
	if(-e $template)
	{
		open(TMP,$template);
		open(INI,">../CONF/confocal.ini");
		while(<TMP>)
		{
			my $linea=$_;
			if($linea =~ /\{CONFOCALROOT\}/)
			{
				$linea=~s/\{CONFOCALROOT\}/$confocal_root/g;
			}
			if($linea =~ /\{CONVERTPATH\}/)
			{
				$pathConvert=~s/\n//g;	
				$linea=~s/\{CONVERTPATH\}/$pathConvert/g;
			}
			if($linea =~ /\{JAVAPATH\}/)
			{
				$pathJava=~s/\n//g;	
				$linea=~s/\{JAVAPATH\}/$pathJava/g;
			}
			if($linea =~ /\{XVFBPATH\}/)
			{
				$pathXvfb=~s/\n//g;
				$linea=~s/\{XVFBPATH\}/$pathXvfb/g;
			}
			if($linea =~ /\{LICENSENUMBER\}/)
			{
				$linea=~s/\{LICENSENUMBER\}/$license_number/g;
			}
			print INI $linea;
		}
		close TMP;
		close INI;
		system("chmod 777 ../CONF");
		system("chmod 777 ../CONF/confocal.ini");
		system('mkdir -p ../shared/bin');
		system('mkdir -p ../shared/mnt');
		system("chmod -R 777 ../shared");
		system('mkdir -p ../tmp/LOGS');
		system("chmod -R 777 ../tmp");
		
		
	}
	else
	{
		print "Not Found: $template\n";
	}
}





