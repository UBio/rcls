combo=function(label,container,MenuItems)
{
	this.oSplitButton=null;
	this.label=label;
	this.container=container;
	
	var me=this;
	
	this.onMenuItemClick = function (p_sType, p_aArgs, p_oItem) {

		var sText = p_oItem.cfg.getProperty("text");
		var value = p_oItem.value;
		me.oSplitButton.set('label',sText);
		me.oSplitButton.set('value',value);
	};
	

	this.menu=new Array();
	if(MenuItems)
	{
		this.menu=this.CreateListItems(MenuItems);	
	}
	else
	{
		var item={text:'',value:''};
		item.text='Empty';
		item.value=undefined;
		this.menu[0]=item;
	}



	this.oSplitButton = new YAHOO.widget.Button({type: "split",  
													label: this.label, 
													container: this.container,
													menu:this.menu,
													lazyloadmenu:false
											});
										
	// this.oSplitButton.addListener('focus',function(){alert(this.get('name'));});
}
combo.prototype.addListener=function(event,fn,args)
{
	this.oSplitButton.addListener(event,fn,args);
}
combo.prototype.getValue=function()
{
	return this.oSplitButton.get('value');
}

combo.prototype.setValue=function(routine)
{
	var menu_ref=this.oSplitButton.getMenu();
	var items=menu_ref.getItems();
	for(var i=0;i<items.length;i++)
	{
		if(items[i].value == routine)
		{
			this.oSplitButton.set('value',routine);
			this.oSplitButton.set('label',routine);	
			return true;
		}
	}
	return false;
}


combo.prototype.erase=function()
{
	var menu_ref=this.oSplitButton.getMenu();
	var elem=menu_ref.getItems();
	
	for(iMenuItem=elem.length-1;iMenuItem>=0;iMenuItem--)
	{
		menu_ref.removeItem(elem[iMenuItem]);
	}
}


combo.prototype.setMenu=function(menuItems)
{
	
	var menu_ref=this.oSplitButton.getMenu();
	this.erase();
	
 	if(menuItems)
	{
		this.menu=this.CreateListItems(menuItems);
		menu_ref.addItems(this.menu);
	}
	menu_ref.render();
}

combo.prototype.refresh=function(menu)
{
	
	this.setMenu(menu);	
	this.oSplitButton.set('value',undefined);
	this.oSplitButton.set('label',this.label);
}


combo.prototype.CreateListItems=function(listMacros)
{
	var listMacrosItems=new Array();
	for(var i=0;i<listMacros.length;i++)
	{
		var item={text:'',value:'',onclick:{fn:this.onMenuItemClick}};
		if(listMacros[i].text)
		{
			item.text=listMacros[i].text;
		}
		else
		{
			item.text=listMacros[i];
		}
		if(listMacros[i].value)
		{
			item.value=listMacros[i].value;
		}
		else
		{
			item.value=listMacros[i];
		}
		listMacrosItems[i]=item;
	}
	return listMacrosItems;
}


combo.prototype.disabled=function(menu)
{
	this.oSplitButton.set('disabled',true);
}
combo.prototype.enabled=function(menu)
{
	this.oSplitButton.set('disabled',false);
}



