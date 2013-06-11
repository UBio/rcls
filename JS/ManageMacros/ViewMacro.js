ViewMacro=function(manager,MyMicro)
{
	this.MyMicro=MyMicro;
	this.cancel_btn;
	this.view_btn;
	
	this.options={
						expand:false,
						width:"725px",
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
		label.innerHTML="View Macro";
		_setTitleDialogMacro(label);
	}
	
	this.setContentDialogMacro=function()
	{	
		_setContentdialogMacro(this.getContent(MyMicro.conf.getMacros('All')));
	}
	
	this.setButtonsDialogMacro=function()
	{
		_setButtonsDialogMacro(this.getButtons());
		
		new YAHOO.widget.Button(this.cancel_btn).on('click',this.cancel);
		//  
		new YAHOO.widget.Button(this.view_btn).on('click',this.downloadMacro,this);
	}
	
	this.setTitleDialogMacro();
	this.setContentDialogMacro();
	this.setButtonsDialogMacro();
	
}
ViewMacro.prototype.downloadMacro=function(event,me)
{
	// me.dlgViewSelectName.show();
	if(me.ListMacros.getValue() == undefined)
	{
		new dialog_alert("Notice","Please, select one macro",'notice');				
		return;
	}
	document.location='download.php?path=MACROS/'+me.ListMacros.getValue();
}
ViewMacro.prototype.getContent=function(listMacros)
{
	var div=document.createElement('div');
	var p=document.createElement(p);
		

	this.ListMacros=this.createList('Select Macro',p,listMacros);
	this.ListMacros.addListener('valueChange',this.loadMacro,this);
	div.appendChild(p);
	// YAHOO.util.Event.addListener(select,"change",this.loadMacro,this);
		
	
	var p=document.createElement('p');
	var textarea=document.createElement('textarea');
	
	textarea.className="macroView";
	textarea.setAttribute('name','viewMacro');
	textarea.setAttribute('id','viewMacro');
	
	p.appendChild(textarea);
	div.appendChild(p);
	
	return div
}

ViewMacro.prototype.loadMacro=function(event,me)
{
	var callback = {
	  success: function(o) {
								myLogWriter.log(o.responseText, "info");
								me.MyMicro.conf.progressbar.hide();
								document.getElementById("viewMacro").value=o.responseText;
							},
	  failure: function(o) {
								myLogWriter.log(o.status+":"+o.statusText+":"+o.responseText, "info");
								me.MyMicro.conf.progressbar.hide();
								new dialog_alert("Notice",o.responseText,'notice');		
								
							}
	};
	
	var url='admin/cgi-bin/editMacro.cgi?'
	url+="conf="+document.getElementById("micro").value;
	url+="&action=load";
	url+="&macro="+me.ListMacros.getValue();
	var cObj = YAHOO.util.Connect.asyncRequest('GET', url, callback);
	me.MyMicro.conf.progressbar.show();
	
}

ViewMacro.prototype.getButtons=function()
{
	var p=document.createElement('p');
	p.className="buttonsView";
	this.view_btn=document.createElement('input');
	this.view_btn.setAttribute('type','button');
	this.view_btn.setAttribute('value','Download');
	p.appendChild(this.view_btn);
	
	this.cancel_btn=document.createElement('input');
	this.cancel_btn.setAttribute('type','button');

	this.cancel_btn.setAttribute('value','Cancel');
	p.appendChild(this.cancel_btn);

	return p;
}
ViewMacro.prototype.viewMacro=function(event,arg)
{
	
}

