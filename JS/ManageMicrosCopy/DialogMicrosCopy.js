DialogMicrosCopy=function(options)
{
	this.name='DialogMicrosCopy';
	
	var ManagerDialog = new ManageDialogMicrosCopy(options);
	
	this.show_progress_bar=function()
	{
		ManagerDialog.progressbar.show();
	}
	this.hide_progress_bar=function()
	{
		ManagerDialog.progressbar.hide();
	}	
	this.setTitleDialogMacro=function(element)
	{
		ManagerDialog.setHead(element);
	}
	
	this.setContentDialogMacro=function(element)
	{
		ManagerDialog.setBody(element);
	}
	
	this.setButtonsDialogMacro=function(buttons)
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
