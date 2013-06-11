MoveMacro=function(manager,MyMicro)
{
	this.MyMicro=MyMicro;
	this.cancel_btn;
	this.delete_btn;
	
	this.options={
						expand:false,
						width:"300px",
						isExpanded:false,
						close:true,
						modal:true,
						center:true,
						visible:false,
						container:document.body,
						manager:manager
					};
					
	DialogMacro.call(this,this.options);
	
	var _setTitleDialogMacro=this.setTitleDialogMacro;
	var _setContentdialogMacro=this.setContentDialogMacro;
	var _setButtonsDialogMacro=this.setButtonsDialogMacro;
	
	this.setTitleDialogMacro=function()
	{
		var label=document.createElement('label');
		label.innerHTML="Move Macro";
		_setTitleDialogMacro(label);
	}
	
	this.setContentDialogMacro=function()
	{	
		_setContentdialogMacro(this.getContent(MyMicro.conf.getMacros('All'),MyMicro.conf.getTypesMacro()));
	}
	
	this.setButtonsDialogMacro=function()
	{
		_setButtonsDialogMacro(this.getButtons());
		// // 
		new YAHOO.widget.Button(this.cancel_btn).on('click',this.cancel);
		// // //  
		new YAHOO.widget.Button(this.delete_btn).on('click',this.move,this);
	}
	
	this.refresh=function()
	{
		this.MyMicro.refresh("DeleteMacro",this.MyMicro);
		this.ListMacrosFrom.refresh(this.MyMicro.conf.getMacros('All'));
		this.ListMacrosTo.refresh(this.MyMicro.conf.getTypesMacro());
		this.fire(this.MOVE_MACRO);
	}
	
	this.setTitleDialogMacro();
	this.setContentDialogMacro();
	this.setButtonsDialogMacro();
}


MoveMacro.prototype.getContent=function(listMacros,listTypesMacros)
{
	var div=document.createElement('div');
	var p=document.createElement('p');
	

	
	div.appendChild(p);
	this.ListMacrosFrom=this.createList('Select Macro',p,listMacros);
	
	var p=document.createElement('p');

	div.appendChild(p);
	
	this.ListMacrosTo=this.createList('Move To',p,listTypesMacros);
	
	return div;
}

MoveMacro.prototype.getButtons=function()
{
	var p=document.createElement('p');
	// p.className="buttonsView";
	this.delete_btn=document.createElement('input');
	this.delete_btn.setAttribute('type','button');
	this.delete_btn.setAttribute('value','Move');
	p.appendChild(this.delete_btn);
	
	this.cancel_btn=document.createElement('input');
	this.cancel_btn.setAttribute('type','button');
	this.cancel_btn.setAttribute('value','Cancel');
	p.appendChild(this.cancel_btn);
	
	
	return p;
}

MoveMacro.prototype.move=function(event,me)
{
	if(me.ListMacrosFrom.getValue() == undefined)
	{
		new dialog_alert("Notice","Missing Name of the Macro",'notice');				
		return;
	}
	
	if(me.ListMacrosTo.getValue() == undefined)
	{
		new dialog_alert("Notice","Missing To",'notice');				
		return;
	}
	
	var callback = {
	  success: function(o) {
								myLogWriter.log(o.responseText, "info");
								me.MyMicro.conf.progressbar.hide();
								me.hide();
								me.refresh();
								
							},
	  failure: function(o) {
								myLogWriter.log(o.status+":"+o.statusText+":"+o.responseText, "info");
								me.MyMicro.conf.progressbar.hide();
								me.dialog("Info",o.responseText,YAHOO.widget.SimpleDialog.ICON_WARN);
							}
	};

	var url='admin/cgi-bin/moveMacro.cgi?'
	url+="conf="+document.getElementById("micro").value;
	url+="&from="+me.ListMacrosFrom.getValue();
	url+="&to="+me.ListMacrosTo.getValue();
	var cObj = YAHOO.util.Connect.asyncRequest('GET', url, callback);
	me.MyMicro.conf.progressbar.show();
}

