DialogApp=function(options)
{
	this.name='DialogApp';
	
	var ManagerDialog = new ManageDialogApp(options);
	
	this.show_progress_bar=function()
	{
		ManagerDialog.progressbar.show();
	}
	this.hide_progress_bar=function()
	{
		ManagerDialog.progressbar.hide();
	}	
	this.setTitleDialogApp=function(element)
	{
		ManagerDialog.setHead(element);
	}
	
	this.setContentDialogApp=function(element)
	{
		ManagerDialog.setBody(element);
	}
	
	this.setButtonsDialogApp=function(buttons)
	{
		ManagerDialog.setFooter(buttons);
	}
	
	this.cancel=function()
	{
		ManagerDialog.hide();
	}
	this.hide=function()
	{
		ManagerDialog.hide();
	}
	this.show=function()
	{
		ManagerDialog.show();
	}
	

	this.fire=function(type)
	{

	}
	this.refresh=function()
	{
		
	}
}
