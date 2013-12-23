$VERSION='1.0';

@ISA=qw(Exporter);
@EXPORT=qw(read_dir_macros read_dir_templates read_dir_images);
use strict;
use LIB::http_response_error;

sub read_dir_images
{
	my (%args) = @_;
	my %result;	
	my $MatrixScreenerImages=$args{-dir};
	my $list_images='';
	if(!opendir(DIR,$MatrixScreenerImages))
	{
		print STDERR 'Function: read_dir_images: '. $MatrixScreenerImages.': '.$!."\n";
		# our $HTTP_ERROR_441="Check config file: Section template, dir images not exists";
		
		# print_http_response(441,$HTTP_ERROR_441);	
		# exit -1;
		$result{error}=$HTTP_ERROR_441;
		$result{list}='';	
		return %result;
	};
	
	while( (my $filename = readdir(DIR)))
	{
		if($filename !~ /^\./)
		{
			$list_images.="'".$filename."',";
		}
	}
	if($list_images eq '')
	{
		print STDERR "Function: read_dir_images: dir images empty\n";
		$result{error}=$HTTP_ERROR_442;
		$result{list}='';
		return %result;
		
		# our $HTTP_ERROR_442="Check config file: Section template, dir images empty";
		# print_http_response(442,$HTTP_ERROR_442);	
		# exit -1;
	}
	
	$list_images=~s/,$//g;
	closedir(DIR);
	
	$result{error}='';
	$result{list}=$list_images;
	
	return %result;
}

sub read_dir_templates
{
	my (%args) = @_;
	my $templatesdir=$args{-dir};
	my $list_template='';
	my %result;
	
	opendir(DIR,$templatesdir) || do {
		print STDERR 'Function: read_dir_templates: '. $templatesdir.': '.$!."\n";
		# our $HTTP_ERROR_439="Check config file: Section template, dir template not exists";
		# print_http_response(439,$HTTP_ERROR_439);	
		# exit -1;
		$result{error}=$HTTP_ERROR_439;
		$result{list}='';
		return %result;
	};
	

	while( (my $filename = readdir(DIR)))
	{
		if($filename =~ /\{ScanningTemplate\}(.*)\.xml/)
		{
	    	$list_template.="'".$1."',";
		}
	}
	
	if($list_template eq '')
	{
		print STDERR "Function: read_dir_templates: dir template empty\n";
		$result{error}=$HTTP_ERROR_440;
		$result{list}='';
		return %result;
		# our $HTTP_ERROR_440="Check config file: Section template, dir template enpty";
		# print_http_response(440,$HTTP_ERROR_440);	
		# exit -1;
	}
	$list_template=~s/,$//g;
	closedir(DIR);
	$result{error}='';
	$result{list}=$list_template;
	
	return %result;
}

sub read_dir_macros
{
	my (%args) = @_;
	my $dirMacros=$args{-dir};
	my $allMacros='';
	
	# opendir(DIR,$dirMacros)||die $dirMacros.':'.$!;
	opendir(DIR,$dirMacros)|| eval
	{
		print STDERR 'Function: read_dir_macros: '. $dirMacros.': '.$!."\n";
		# our $HTTP_ERROR_436="Check config file: Section MACRO, dir macro not exists";
		print_http_response(436,$HTTP_ERROR_436);	
		exit -1;
	};
	
	my $count_macro_find=0;
	while( (my $tiposMacro = readdir(DIR)))
	{
		if($tiposMacro !~ /^\./)
		{
			my $file_macro_aux='[';
	    	opendir(DIRM,$dirMacros."/".$tiposMacro);			
			while( (my $macrofile = readdir(DIRM)))
			{
				if($macrofile !~ /^\./)
				{
					if($file_macro_aux eq '[')
					{
						$file_macro_aux.="'".$macrofile."'";
					}
					else
					{
						$file_macro_aux.=",'".$macrofile."'";
					}
					$count_macro_find++;
				}
			}
			close DIRM;
			
			$file_macro_aux.=']';
			$file_macro_aux="'".$tiposMacro."':".$file_macro_aux;
			if($allMacros eq '')
			{
				$allMacros=$file_macro_aux;
			}
			else
			{
				$allMacros.=",".$file_macro_aux;
			}
		}
	}
	if($allMacros eq '')
	{
		print STDERR "Function: read_dir_macros: directory macros is empty\n";
		# our $HTTP_ERROR_437="Check config file: Section MACRO, directory macros is empty";
		print_http_response(437,$HTTP_ERROR_437);	
		exit -1;
	}
	if($count_macro_find ==0)
	{
		print STDERR "Function: read_dir_macros: not found macros\n";
		# our $HTTP_ERROR_438="Check config file: Section MACRO, not found macros";
		print_http_response(438,$HTTP_ERROR_437);	
		exit -1;
	}
	$allMacros="{".$allMacros."}";
	close DIR;
	return $allMacros;
}
