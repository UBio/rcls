DeleteMicrosCopy=function(manager,microDefault)
{
	this.currentMicro=microDefault;
	this.options={
						expand:false,
						width:"200px",
						isExpanded:false,
						close:true,
						modal:true,
						center:true,
						visible:false,
						container:document.body,
						manager:manager
					};
					
	DialogMicrosCopy.call(this,this.options);
	
	
	var _setTitleDialogMacro=this.setTitleDialogMacro;
	var _setContentdialogMacro=this.setContentDialogMacro;
	var _setButtonsDialogMacro=this.setButtonsDialogMacro;
	
	this.setTitleDialogMacro=function()
	{
		var label=document.createElement('label');
		label.innerHTML="Delete Micro";		
		_setTitleDialogMacro(label);
	}
	
	this.setContentDialogMacro=function()
	{	
		
		this.labelContent=document.createElement('label')
		this.labelContent.innerHTML="Do you want delete  this micro "+this.currentMicro+"?";
		_setContentdialogMacro(this.labelContent);
	}
	
	this.setButtonsDialogMacro=function()
	{
		
		_setButtonsDialogMacro(this.getButtons());// // 
		new YAHOO.widget.Button(this.cancel_btn).on('click',this.cancel);
		// // //  
		this.btnYUIbutton=new YAHOO.widget.Button(this.delete_parcentricity);
		this.btnYUIbutton.on('click',this.delete,this);
	}
		

	this.setTitleDialogMacro();
	this.setContentDialogMacro();
	this.setButtonsDialogMacro();
}


DeleteMicrosCopy.prototype.delete=function(event,me)
{
	var callback = {
	  success: function(o) {
								myLogWriter.log(o.responseText, "info");
								me.hide_progress_bar();	
								me.hide();
								new dialog_alert('Notice','Finished','notice');
								
							},
	  failure: function(o) {
								me.hide_progress_bar();
								new dialog_alert("Error",o.responseText,'error');																			
								myLogWriter.log(o.status+":"+o.responseText, "info");
							}
	};
	
	var url='admin/cgi-bin/micro.cgi?ACTION=deletemicro';
	url+="&micro="+me.currentMicro;
	me.show_progress_bar();
	var cObj = YAHOO.util.Connect.asyncRequest('GET', url, callback);
}

DeleteMicrosCopy.prototype.setMicro=function(micro)
{
	this.currentMicro=micro;
	this.labelContent.innerHTML="Do you want delete this micro "+this.currentMicro+"?";
}
DeleteMicrosCopy.prototype.getButtons=function()
{
	var p=document.createElement('p');
	p.className="buttons";
	this.cancel_btn=document.createElement('input');
	this.cancel_btn.setAttribute('type','button');
	this.cancel_btn.setAttribute('value','Cancel');
	p.appendChild(this.cancel_btn);

	this.delete_parcentricity=document.createElement('input');
	this.delete_parcentricity.setAttribute('type','button');
	this.delete_parcentricity.setAttribute('value','Delete');
	p.appendChild(this.delete_parcentricity);	
	
	return p;
}

