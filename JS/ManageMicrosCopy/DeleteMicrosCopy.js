DeleteMicrosCopy=function(manager,micros)
{
	this.allMicros=micros;
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
		var div=document.createElement('div');
		div.className='deleteMicro';
		
		var labelContent=document.createElement('label')
		labelContent.innerHTML="Select Micro: ";
		div.appendChild(labelContent);
		var ul=document.createElement('ul');
		for(var i=0;i<micros.length;i++)
		{
			var li=document.createElement('li');
			var checkbox=document.createElement('input');
			checkbox.setAttribute('type','radio');
			checkbox.setAttribute('name','microdelete');
			checkbox.setAttribute('value',micros[i]);
			li.appendChild(checkbox);
			var span=document.createElement('span');
			
			span.innerHTML=micros[i]
			li.appendChild(span);
			ul.appendChild(li);
		}
		div.appendChild(ul);
		_setContentdialogMacro(div);
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
								window.location.reload();
								
							},
	  failure: function(o) {
								me.hide_progress_bar();
								new dialog_alert("Error",o.responseText,'error');																			
								myLogWriter.log(o.status+":"+o.responseText, "info");
							}
	};
	var micro;
	for(var i=0;i<document.getElementsByName('microdelete').length;i++)
	{
		if(document.getElementsByName('microdelete')[i].checked)
		{
			micro=document.getElementsByName('microdelete')[i].value;
		}
	}
	
	if(micro)
	{
		var url='admin/cgi-bin/micro.cgi?ACTION=deletemicro';
		url+="&micro="+micro;	
		me.show_progress_bar();
		var cObj = YAHOO.util.Connect.asyncRequest('GET', url, callback);
		
	}
	else
	{
		new dialog_alert("Error",'','error','DELMICRONOSELECT');																			
		
	}

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

