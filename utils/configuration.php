<html>
<head>
</head>
<body>
<?php
	$perl5lib=apache_getenv("PERL5LIB");
	print "PERL5LIB: ".$perl5lib."<br>";
	$modulesperl = shell_exec('export PERL5LIB=$PERL5LIB:'.$perl5lib.'&& ./CheckModulesPerl ../.');
	echo "<pre>$modulesperl</pre>";
	
	$xvfbpath=shell_exec('which Xvfb');
	$javapath=shell_exec('which java');
	$convertpath=shell_exec('which convert');
	
	echo "Xvfb: ".$xvfbpath."<br>";
	echo "JAVA: ".$javapath."<br>";
	echo "convert: ".$convertpath."<br>";
	
	
?>
</body>
</html>