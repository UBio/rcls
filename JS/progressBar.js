progressBar=function(manager)
{
	var id="waitMicro"+Math.floor(Math.random()*1000000+1);
	this.wait = new YAHOO.widget.Panel(id,  
				{ width:"240px", 
				  fixedcenter:true, 
				  close:false, 
				  draggable:false, 
				  modal:true,
				  visible:false
				} 
			);

	

	this.wait.setHeader("Running, please wait...");

	this.wait.setBody('<img src="IMG/progress.gif" />');
	this.wait.render(document.body);
	
}

progressBar.prototype.show=function(step)
{
	if(step)
	{
		this.wait.setHeader("Running: "+step+", please wait...");
	}
	this.wait.show();
}
progressBar.prototype.hide=function()
{
	this.wait.hide();
}