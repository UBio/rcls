package LIB::http_response_error;
$VERSION='1.0';

@ISA=qw(Exporter);
@EXPORT=qw(print_http_response 
			$HTTP_ERROR_409 
			$HTTP_ERROR_410 
			$HTTP_ERROR_411 
			$HTTP_ERROR_412 
			$HTTP_ERROR_413 
			$HTTP_ERROR_414 
			$HTTP_ERROR_415 
			$HTTP_ERROR_416 
			$HTTP_ERROR_417 
			$HTTP_ERROR_418
			$HTTP_ERROR_419
			$HTTP_ERROR_420
			$HTTP_ERROR_421
			$HTTP_ERROR_422
			$HTTP_ERROR_423
			$HTTP_ERROR_424
			$HTTP_ERROR_425
			$HTTP_ERROR_426
			$HTTP_ERROR_427
			$HTTP_ERROR_428
			$HTTP_ERROR_429
			$HTTP_ERROR_430
			$HTTP_ERROR_431
			$HTTP_ERROR_432
			$HTTP_ERROR_433
			$HTTP_ERROR_434
			$HTTP_ERROR_435
			$HTTP_ERROR_436
			$HTTP_ERROR_437
			$HTTP_ERROR_438
			$HTTP_ERROR_439
			$HTTP_ERROR_440
			$HTTP_ERROR_441
			$HTTP_ERROR_442);
use strict;
use HTTP::Status qw(is_success status_message);

our $HTTP_ERROR_409="is locked";
our $HTTP_ERROR_410="This Image Dont have black fields";
our $HTTP_ERROR_411="This Image dont have tissues or cell";
our $HTTP_ERROR_412="unknown error";
our $HTTP_ERROR_413="Missing grid File, please you must indicated gridx and gridy values";
our $HTTP_ERROR_414="Macro’s name already in use please change it";
our $HTTP_ERROR_415="ERROR in Socket Creation : Connection refused";
our $HTTP_ERROR_416="ImageJ";
our $HTTP_ERROR_417="Sorry, Macro protected, Permission denied";
our $HTTP_ERROR_418="Sorry, this objetive already exists";
our $HTTP_ERROR_419="Sorry, this micro already exists";
our $HTTP_ERROR_420="Error in name format image: ".'image--L0000--S00--U(\d+)--V(\d+)--J\d\d--X00--Y00--T0000(--Z00)?--C00.ome.tif';

our $HTTP_ERROR_421="ERROR mount shared points";
our $HTTP_ERROR_422="The application is not configured";
our $HTTP_ERROR_423="The application  not have any microscope configured";
our $HTTP_ERROR_424="The volumenes are not mounted, please reload this page, if the problem will continue, you send a incidence to bioinformatics";
our $HTTP_ERROR_425="The Environmet var CONFOCAL_INI is not Defined in Apache Server";
our $HTTP_ERROR_426="Invalid license number";
our $HTTP_ERROR_427="Missing license number";
our $HTTP_ERROR_428="Invalid mac address";
our $HTTP_ERROR_429="Not connect with license server";
our $HTTP_ERROR_430="Not insert new micro, error mount directory";
our $HTTP_ERROR_431="Image Local Directory exists";
our $HTTP_ERROR_432="Template Local Directory exists";
our $HTTP_ERROR_433="Parcentricity exists, please remove before to insert";
our $HTTP_ERROR_434="Format error: id,magnification,x,y (ej:11506511,10,73375,41556)";
our $HTTP_ERROR_435="Parcentricity not exists";
our $HTTP_ERROR_436="Check config file: Section MACRO, dir macro not exists";
our $HTTP_ERROR_437="Check config file: Section MACRO, directory macros is empty";
our $HTTP_ERROR_438="Check config file: Section MACRO, not found macros";
our $HTTP_ERROR_439="Check config file: Section template, dir template not exists";
our $HTTP_ERROR_440="Check config file: Section template, dir template enpty";
our $HTTP_ERROR_441="Check config file: Section template, dir images not exists";
our $HTTP_ERROR_442="Check config file: Section template, dir images empty";

sub print_http_response($;$$)
{
	my ($http_error_num,$content,$moreinfo) = @_;
	
	my($http_response)=new CGI();
	# my $http_error_num=500;
	my($status_line)=$http_error_num." ".status_message($http_error_num);

	print $http_response->header(-status=>$status_line,-type =>'text/html');
	print $content."<p>".$moreinfo."</p>";
	print STDERR $content."".$moreinfo;
 
};
1;

