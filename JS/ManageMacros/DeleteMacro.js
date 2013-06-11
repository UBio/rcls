DeleteMacro=function(manager,MyMicro)
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
		label.innerHTML="Delete Macro";
		_setTitleDialogMacro(label);
	}
	
	this.setContentDialogMacro=function()
	{	
		_setContentdialogMacro(this.getContent(MyMicro.conf.getMacros('All')));
	}
	
	this.setButtonsDialogMacro=function()
	{
		_setButtonsDialogMacro(this.getButtons());
		// 
		new YAHOO.widget.Button(this.cancel_btn).on('click',this.cancel);
		// //  
		new YAHOO.widget.Button(this.delete_btn).on('click',this.deleteMacro,this);
	}
		
	this.refresh=function()
	{
		this.MyMicro.refresh("DeleteMacro",this.MyMicro);
		this.ListMacros.refresh(this.MyMicro.conf.getMacros('All'));
		this.fire(this.DELETE_MACRO);
	}
	
	this.setTitleDialogMacro();
	this.setContentDialogMacro();
	this.setButtonsDialogMacro();
}


DeleteMacro.prototype.getContent=function(listMacros)
{

	var p=document.createElement(p);
	
	this.ListMacros=this.createList('Select Macro',p,listMacros);
	
	return p;
}

DeleteMacro.prototype.getButtons=function()
{
	var p=document.createElement('p');
	this.delete_btn=document.createElement('input');
	this.delete_btn.setAttribute('type','button');
	this.delete_btn.setAttribute('value','Remove');
	p.appendChild(this.delete_btn);
	
	this.cancel_btn=document.createElement('input');
	this.cancel_btn.setAttribute('type','button');
	this.cancel_btn.setAttribute('value','Cancel');
	p.appendChild(this.cancel_btn);
	
	
	return p;
}

DeleteMacro.prototype.deleteMacro=function(event,me)
{
	if(me.ListMacros.getValue() == undefined)
	{
		new dialog_alert("Notice","Missing Name of the Macro",'notice');				
		return;
	}
	
	var callback = {
	  success: function(o) {
								myLogWriter.log(o.responseText, "info");
								me.refresh();
								me.hide();
								me.MyMicro.conf.progressbar.hide();								
							},
	  failure: function(o) {
								myLogWriter.log(o.status+":"+o.statusText+":"+o.responseText, "info");
								me.MyMicro.conf.progressbar.hide();
								new dialog_alert("Notice",o.responseText,'notice');		
								
							}
	};

	var url='admin/cgi-bin/deleteMacro.cgi?'
	url+="conf="+document.getElementById("micro").value;
	url+="&macro="+me.ListMacros.getValue();
	var cObj = YAHOO.util.Connect.asyncRequest('GET', url, callback);
	me.MyMicro.conf.progressbar.show();
}




