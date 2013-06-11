DialogMacro=function(options)
{
	this.name='DialogMacro';
	
	this.FINISH_UPLOAD=0;
	this.DELETE_MACRO=1;
	this.MOVE_MACRO=2;
	
	var ManagerDialog = new ManageDialogMacro(options);
	
	this.FinishUploadMacroEvent=new YAHOO.util.CustomEvent("onFinishUploadMacro",null);
	this.MoveMacroEvent=new YAHOO.util.CustomEvent("onMoveMacro",null);
	this.DeleteMacroEvent=new YAHOO.util.CustomEvent("onDeleteMacro",null);
	
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
	
	this.createList=function(title,container,items)
	{
		return new combo(title,container,items);
	}
	this.fire=function(type)
	{
		if(type == 'Finish_Upload')
		{
			this.FinishUploadMacroEvent.fire();
		}
		if(type == this.DELETE_MACRO)
		{
			this.DeleteMacroEvent.fire();
		}
		if(type =='onMoveMacro')
		{
			this.MoveMacroEvent.fire();
		}
	}
	this.refresh=function()
	{
		
	}
}



