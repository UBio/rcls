package UPLOAD::upload;
$VERSION='1.0';

use CGI ;
use strict;
use File::Basename;
sub new
{
	my ( $class, %args ) = @_;
	my $UPLOAD={};

	bless($UPLOAD);
	

	
	return $class->upload(-file=>$args{-file},-to=>$args{-to});
}


sub upload
{
	my ($this,%args)=@_;
	my $cgi = new CGI;
	# my $input=$args{'-file'};
	my $input=$cgi->param($args{'-file'});
	$CGI::POST_MAX = 1024 * 5000;
	my $safe_filename_characters = "a-zA-Z0-9_.-";
	my $upload_dir = "/tmp";
	if(exists($args{-to}))
	{
		$upload_dir=$args{-to};
	}
	
	
	print STDERR "Hola:".$input."\n";
	if ( !$input )
	{
		print $cgi->header();
		print STDERR "There was a problem uploading your file.";
		# my $error="[{'error':'-1','desc':'There was a problem uploading your file'}]";
		# return $error;
		exit;
	}
	
	my ( $name, $path, $extension ) = fileparse ( $input, '\..*' );
	$input = $name . $extension;
	$input =~ tr/ /_/;
	$input =~ s/[^$safe_filename_characters]//g;

	if ( $input =~ /^([$safe_filename_characters]+)$/ )
	{
		$input = $1;
	}
	else
	{
		print  STDERR "Filename contains invalid characters";
		# my $error="[{'error':'-1','desc':'Filename contains invalid characters'}]";
		# return $error;
		exit;
	}
	
	my $upload_filehandle = $cgi->upload($args{'-file'});
	print STDERR  $upload_filehandle."\n";
	# $name=~s/\-/_/g;
	# $name=~s/\+/_/g;
	# $name=~s/\s+//g;
	# $name=~s/\n//g;
	my $output = $name.$extension;

	open ( UPLOADFILE, ">$upload_dir/$output" ) or die "ERROR: can not upload file $upload_dir/$input";
	binmode UPLOADFILE;
	
	while ( <$upload_filehandle> )
	{
		print UPLOADFILE;
	}
	close UPLOADFILE; 

	return "$upload_dir/$output";
}


1;