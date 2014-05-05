loading=function(container)
{
	var optionWindow={
						expand:false,
						width:"750px",
						isExpanded:false,
						close:false,
						modal:true,
						center:true,
						visible:true
					};

	this.panel=new itemWindow('Loading',container,null,optionWindow);
	this.create_window();
}


loading.prototype.hide=function()
{
	this.panel.destroy();
}


loading.prototype.create_window=function()
{
	var label=document.createElement('label');
	label.innerHTML="Loading Application";

	this.panel.getHead().appendChild(label);

	var div=document.createElement('div');
	div.className='title';
	var label=document.createElement('label');
	label.innerHTML="iMSRC";
	
	div.appendChild(label);
	this.panel.getBody().appendChild(div);
	
	
	
}


