// <div id="SelectMicro">
// 	<div class="hd"><div class="expand"></div></div>
// 	<div class="bd">
// 	</div>
// 	<div class="ft">
// 	</div>
// </div>

itemWindow=function(idWindow,container,manager,options)
{
	this.window;
	this.head;
	this.headElement;
	this.expandBottom;
	this.body;
	this.footer;
	this.windowPanel;
	this.container=container;
	
	this.options=options;
	
	this.create_window(idWindow,container,manager);	
	
}

itemWindow.prototype.show=function()
{
	this.windowPanel.show();
}
itemWindow.prototype.hide=function()
{
	this.windowPanel.hide();
}
itemWindow.prototype.destroy=function()
{
	this.windowPanel.destroy();
}

itemWindow.prototype.expanded=function(event,me)
{
	if(me.options.isExpanded)
	{
		me.options.isExpanded=false;
		me.body.style.display="none";
		me.expandBottom.style.background="url(IMG/expande.png) no-repeat";
		// me.container.style.height="65px";
	}
	else
	{
		
		me.body.style.display="block";
		me.expandBottom.style.background="url(IMG/collapse.png) no-repeat";
		// me.container.style.height="310px";
		me.options.isExpanded=true;
	}
}
itemWindow.prototype.focus=function()
{
	this.windowPanel.focus();
}
itemWindow.prototype.getFooter=function()
{
	return this.footer;
}
itemWindow.prototype.getBody=function()
{
	return this.body;
}
itemWindow.prototype.getHead=function()
{
	return this.headElement;
}

itemWindow.prototype.create_window=function(id,container,manager)
{
	// var options={
	// 					expand:false,
	// 					width:"400px",
	// 					isExpanded:false,
	// 					close:false,
	// 					modal:true,
	// 					center:true,
	// 					visible:false
	// 				};
	//
	this.window=document.createElement('div');
	this.window.setAttribute('id',id);
	this.head=document.createElement('div');
	this.head.className='hd';
	this.headElement=document.createElement('div');
	this.head.appendChild(this.headElement);

	if(this.options.expand)
	{
		this.expandBottom=document.createElement('div');
		this.expandBottom.className="expand";
		this.head.appendChild(this.expandBottom);
		YAHOO.util.Event.addListener(this.expandBottom,"click",this.expanded,this);
		
	}
	this.body=document.createElement('div');
	this.body.className='bd';
	
	this.footer=document.createElement('div');
	this.footer.className='ft';
	
	this.window.appendChild(this.head);
	this.window.appendChild(this.body);
	this.window.appendChild(this.footer);

	document.body.appendChild(this.window);
	
	

	this.windowPanel = new YAHOO.widget.Panel(id, 
							{ width : this.options.width,
							  fixedcenter : this.options.center,
							  visible : this.options.visible,
							  draggable: false,
							  constraintoviewport: false,
							  zindex:4,
							  close:this.options.close,
							  modal:this.options.modal
							});
							
	this.windowPanel.render(container);
	if(this.options.visible)
	{
		this.windowPanel.show();
	}
	if(manager)
	{
		manager.register(this.windowPanel);
	}
	if(this.options.expand && !this.options.isExpanded)
	{
		this.options.isExpanded=false;
		this.body.style.display="none";
		this.expandBottom.style.background="url(IMG/expande.png) no-repeat";
	}
	
	

}