load_conf=function()
{
	this.num_error=0;
	this.dirImages=new Array();
	this.micros=new Array();
	this.allmicros=new Array();
	this.templates=new Array();
	this.macro_blacks=new Array();
	this.macro_stitching=new Array();
	this.all_macros=new Array();
	this.typesMacros=new Array();
	this.num_error=this.load();
	this.progressbar=new progressBar();
	
}



load_conf.prototype.error=function()
{
	return this.num_error;
}
load_conf.prototype.load=function()
{
	var http_request = new XMLHttpRequest();
	var sURL = "cgi-bin/INITIALIZE/load.cgi";
    http_request.open("GET", sURL, false);
    http_request.send(null);


	if(http_request.status==200)
	{
		var response=eval(http_request.responseText);
		this.responseMicros=response[0].micros;
		this.responseMacros=response[0].macros;
		this.insertMacrosToSelectObject();
		
		var result=this.handleSuccess(this.responseMicros);		
	}
	else
	{
		new dialog_alert("Notice",http_request.responseText,"notice");
		if(http_request.status==423)
		{
			return -3; // Error 423 no existe ningun microscopio configurado
		}
		return -1;
	}
	
	// if(response == -1)
	// {
	// 	// this.dialog.show();
	// 	return -1;
	// }
	// if(response[0].ERROR)
	// {
	// 	new dialog_alert("Notice",response[0].MSG,"notice");									
	// 	
	// 	return response[0].ERROR;
	// 	
	// }
	// else
	// {
	// 
	// }
	return 0;
}


load_conf.prototype.insertMacrosToSelectObject=function()
{

	var iAllMacros=0;
	var iTypeMacro=0;
	for (var i in this.responseMacros) 
	{
		
		this.typesMacros[iTypeMacro]=i;
		iTypeMacro++;
		
		for(var imacro=0;imacro<this.responseMacros[i].length;imacro++)
		{
			this.all_macros[iAllMacros]=i+"/"+this.responseMacros[i][imacro];
			iAllMacros++;
		}
		
		if(i == 'blacks')
		{
			this.macro_blacks=this.responseMacros[i];
		}
		if(i == 'detect')
		{
			this.macro_detect=this.responseMacros[i];
		}
		if(i == 'stitching')
		{
			this.macro_stitching=this.responseMacros[i];
		}
		
	}
	
}

load_conf.prototype.reload=function()
{	
	this.load();	
}
load_conf.prototype.getMicros=function()
{
	return this.micros;
}
load_conf.prototype.getAllMicros=function()
{
	return this.allmicros;
}
load_conf.prototype.getTemplates=function()
{
	return this.templates;
}
load_conf.prototype.getTypesMacro=function()
{
	return this.typesMacros;
}

load_conf.prototype.getMacros=function(typeMacro)
{
	if(typeMacro=='Blacks')
	{
		return this.macro_blacks;
	}
	if(typeMacro=='Detect')
	{
		return this.macro_detect;
	}
	
	if(typeMacro=='Stitching')
	{
		return this.macro_stitching;
	}
	if(typeMacro=='All')
	{
		return this.all_macros;
	}
}
load_conf.prototype.handleSuccess = function(response)
{

	var entro=false;
	var indexMicro=0;
	

	for(var i=0;i<response.length;i++)
	{
		this.allmicros[i]=response[i].name;
		
		if(response[i].templates && response[i].templates.length >0 && response[i].dirimages && response[i].dirimages.length>0)
		{
			this.micros[indexMicro]=response[i].name;
			indexMicro++;
						
			if(response[0].name == response[i].name)
			{
				this.templates=response[i].templates;
				
				for(var iStepName=0;iStepName<response[i].dirimages.length;iStepName++)
				{
					this.dirImages[iStepName]=response[i].dirimages[iStepName];
				}
			}
		}
		else
		{
			new dialog_alert(response[i].name,response[i].warnnings,"notice");		
		}
	}
	if(!entro)
	{
		return -1;
	}
	
}
load_conf.prototype.getDirImages=function()
{
	return this.dirImages;
}
load_conf.prototype.changeTemplates=function(newmicro)
{
	
	if(this.responseMicros == undefined)
	{
		// this.dialog.show();
		return -1;
	}
	for(var i=0;i<this.responseMicros.length;i++)
	{
		if(newmicro == this.responseMicros[i].name)
		{			
			this.templates=this.responseMicros[i].templates;
		}
	}
}
load_conf.prototype.changeDirImages=function(newmicro)
{
	if(this.responseMicros == undefined)
	{
		// this.dialog.show();
		return -1;
	}
	this.dirImages=[];
	for(var i=0;i<this.responseMicros.length;i++)
	{
		if(newmicro == this.responseMicros[i].name)
		{
			for(var iStepName=0;iStepName<this.responseMicros[i].dirimages.length;iStepName++)
			{
				this.dirImages[iStepName]=this.responseMicros[i].dirimages[iStepName];
			}
		}
	}

}



