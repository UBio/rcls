ManageDialogMacro=function(options)
{
	this.dialog=null;
	this.idDialog=this.getId();
	this.options=options;
	
	
	this.dialog=this.createDialog(options);


	
}

ManageDialogMacro.prototype.createDialog=function(options)
{
	return new itemWindow(this.idDialog,options.container,options.manager,options);
}

ManageDialogMacro.prototype.getId=function()
{
	return "Dialig"+Math.floor((Math.random()*100000000)+1); 
}

ManageDialogMacro.prototype.show=function()
{
	this.dialog.show();
}

ManageDialogMacro.prototype.hide=function()
{
	this.dialog.hide();
}


ManageDialogMacro.prototype.setHead=function(element)
{
	this.dialog.getHead().appendChild(element);
}

ManageDialogMacro.prototype.setBody=function(element)
{
	this.dialog.getBody().appendChild(element);
}

ManageDialogMacro.prototype.setFooter=function(element)
{
	this.dialog.getFooter().appendChild(element);
}






