ManageDialogMicrosCopy=function(options)
{
	this.dialog=null;
	this.progressbar=new progressBar();
	
	this.idDialog=this.getId();
	this.options=options;
	
	
	this.dialog=this.createDialog(options);


	
}

ManageDialogMicrosCopy.prototype.createDialog=function(options)
{
	return new itemWindow(this.idDialog,options.container,options.manager,options);
}

ManageDialogMicrosCopy.prototype.getId=function()
{
	return "Dialig"+Math.floor((Math.random()*100000000)+1); 
}

ManageDialogMicrosCopy.prototype.show=function()
{
	this.dialog.show();
}

ManageDialogMicrosCopy.prototype.hide=function()
{
	this.dialog.hide();
}


ManageDialogMicrosCopy.prototype.setHead=function(element)
{
	this.dialog.getHead().appendChild(element);
}

ManageDialogMicrosCopy.prototype.setBody=function(element)
{
	this.dialog.getBody().appendChild(element);
}

ManageDialogMicrosCopy.prototype.setFooter=function(element)
{
	this.dialog.getFooter().appendChild(element);
}

