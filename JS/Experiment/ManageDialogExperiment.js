ManageDialogExperiment=function(options)
{
	this.dialog=null;
	this.progressbar=new progressBar();
	
	this.idDialog=this.getId();
	this.options=options;
	
	
	this.dialog=this.createDialog(options);


	
}

ManageDialogExperiment.prototype.createDialog=function(options)
{
	return new itemWindow(this.idDialog,options.container,options.manager,options);
}

ManageDialogExperiment.prototype.getId=function()
{
	return "Dialig"+Math.floor((Math.random()*100000000)+1); 
}

ManageDialogExperiment.prototype.show=function()
{
	this.dialog.show();
}

ManageDialogExperiment.prototype.hide=function()
{
	this.dialog.hide();
}


ManageDialogExperiment.prototype.setHead=function(element)
{
	this.dialog.getHead().appendChild(element);
}

ManageDialogExperiment.prototype.setBody=function(element)
{
	this.dialog.getBody().appendChild(element);
}

ManageDialogExperiment.prototype.setFooter=function(element)
{
	this.dialog.getFooter().appendChild(element);
}