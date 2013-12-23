ManageDialogApp=function(options)
{
	this.dialog=null;
	this.idDialog=this.getId();
	this.options=options;
	
	
	this.dialog=this.createDialog(options);


	
}

ManageDialogApp.prototype.createDialog=function(options)
{
	return new itemWindow(this.idDialog,options.container,options.manager,options);
}

ManageDialogApp.prototype.getId=function()
{
	return "Dialig"+Math.floor((Math.random()*100000000)+1); 
}

ManageDialogApp.prototype.show=function()
{
	this.dialog.show();
}

ManageDialogApp.prototype.hide=function()
{
	this.dialog.hide();
}


ManageDialogApp.prototype.setHead=function(element)
{
	this.dialog.getHead().appendChild(element);
}

ManageDialogApp.prototype.setBody=function(element)
{
	this.dialog.getBody().appendChild(element);
}

ManageDialogApp.prototype.setFooter=function(element)
{
	this.dialog.getFooter().appendChild(element);
}






