loading=function(container)
{
	var optionWindow={
						expand:false,
						width:"750px",
						isExpanded:false,
						close:false,
						modal:true,
						center:false,
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
	var divIMG=document.createElement('div');
	divIMG.className='logo';
	div.appendChild(divIMG);
	this.panel.getBody().appendChild(div);
	
	
}


