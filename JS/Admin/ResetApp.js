ResetApp=function(manager)
{
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
					
	DialogApp.call(this,this.options);
	var _setTitleDialogApp=this.setTitleDialogApp;
	var _setContentdialogApp=this.setContentDialogApp;
	var _setButtonsDialogApp=this.setButtonsDialogApp;
	
	this.setTitleDialogApp=function()
	{
		var label=document.createElement('label');
		label.innerHTML="Reset App";
		_setTitleDialogApp(label);
	}
	
	this.setContentDialogApp=function()
	{	
		_setContentdialogApp(this.getContent());
	}
	this.setButtonsDialogApp=function()
	{
		_setButtonsDialogApp(this.getButtons());
		// 
		new YAHOO.widget.Button(this.cancel_btn).on('click',this.cancel);
		// //  
		new YAHOO.widget.Button(this.delete_btn).on('click',this.reset_app,this);
	}

	this.setTitleDialogApp();
	this.setContentDialogApp();
	this.setButtonsDialogApp();
	
}
ResetApp.prototype.reset_app=function(event,me)
{
	
	var callback = {
	  success: function(o) {
								myLogWriter.log(o.responseText, "info");
								me.hide();
								var re = /^https?:\/\/[^/]+/i;
								// alert(re.exec(window.location.href)[0]);
								window.location.href = '.';								// me.MyMicro.conf.progressbar.hide();								
							},
	  failure: function(o) {
								myLogWriter.log(o.status+":"+o.statusText+":"+o.responseText, "info");
								// me.MyMicro.conf.progressbar.hide();
								// new dialog_alert("Notice",o.responseText,'notice');		
								
							}
	};

	var url='admin/cgi-bin/reset.cgi?'
	var cObj = YAHOO.util.Connect.asyncRequest('GET', url, callback);
	// me.MyMicro.conf.progressbar.show();
}

ResetApp.prototype.getContent=function()
{

	var p=document.createElement(p);
	
	var label=document.createElement('label');
	label.innerHTML='Are you sure?'
	p.appendChild(label);
	return p;
}

ResetApp.prototype.getButtons=function()
{
	var p=document.createElement('p');
	this.delete_btn=document.createElement('input');
	this.delete_btn.setAttribute('type','button');
	this.delete_btn.setAttribute('value','Reset');
	p.appendChild(this.delete_btn);
	
	this.cancel_btn=document.createElement('input');
	this.cancel_btn.setAttribute('type','button');
	this.cancel_btn.setAttribute('value','Cancel');
	p.appendChild(this.cancel_btn);
	
	
	return p;
}
