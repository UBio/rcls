AddParcentricity=function(manager,microDefault)
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
		label.innerHTML="Parcentricity";		
		_setTitleDialogMacro(label);
	}
	
	this.setContentDialogMacro=function()
	{	
		_setContentdialogMacro(this.getContent());
	}
	
	this.setButtonsDialogMacro=function()
	{
		_setButtonsDialogMacro(this.getButtons());
		// // 
		new YAHOO.widget.Button(this.cancel_btn).on('click',this.cancel);
		// // //  
		this.btnYUIbutton=new YAHOO.widget.Button(this.save_parcentricity);
		this.btnYUIbutton.on('click',this.save,this);
	}
		

	this.setTitleDialogMacro();
	this.setContentDialogMacro();
	this.setButtonsDialogMacro();
}
AddParcentricity.prototype.check_url=function()
{
	if(this.text_parcentricity.value=='')
	{
		new dialog_alert("Error",'Parcentricity is enpty, plese insert parcentricity','error');											
		return -1;
	}
}


AddParcentricity.prototype.save=function(event,me)
{
	var url=me.check_url();
	if(url==-1)
	{
		return;
	}
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
	
	
	var url='admin/cgi-bin/micro.cgi?ACTION=parcentricity';
	url+="&micro="+me.currentMicro;
	url+="&parcentricity="+me.text_parcentricity.value.replace(/\n/g,"$"); ;
	
	me.show_progress_bar();
	var cObj = YAHOO.util.Connect.asyncRequest('GET', url, callback);
}
AddParcentricity.prototype.setMicro=function(micro)
{
	this.currentMicro=micro;
}
AddParcentricity.prototype.getButtons=function()
{
	var p=document.createElement('p');
	p.className="buttons";
	this.cancel_btn=document.createElement('input');
	this.cancel_btn.setAttribute('type','button');
	this.cancel_btn.setAttribute('value','Cancel');
	p.appendChild(this.cancel_btn);

	this.save_parcentricity=document.createElement('input');
	this.save_parcentricity.setAttribute('type','button');
	this.save_parcentricity.setAttribute('value','Save');
	p.appendChild(this.save_parcentricity);	
	
	return p;
}


AddParcentricity.prototype.getContent=function()
{
	var p=document.createElement('p');
	p.className='parcentricity';
	this.text_parcentricity=document.createElement('textarea');

	
	p.appendChild(this.text_parcentricity);
	
	
	return p;
}



