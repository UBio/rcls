AddMicrosCopy=function(manager)
{
	
	this.options={
						expand:false,
						width:"600px",
						// height:'260px',
						isExpanded:false,
						close:true,
						modal:true,
						center:true,
						visible:false,
						container:document.body,
						manager:manager
					};
					
	DialogMicrosCopy.call(this,this.options);
	
	this.currentStep=0;
	
	var _setTitleDialogMacro=this.setTitleDialogMacro;
	var _setContentdialogMacro=this.setContentDialogMacro;
	var _setButtonsDialogMacro=this.setButtonsDialogMacro;
	
	this.setTitleDialogMacro=function()
	{
		var label=document.createElement('label');
		label.innerHTML="Add MicrosCopy";		
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
		this.btnYUIbutton=new YAHOO.widget.Button(this.next_btn);
		this.btnYUIbutton.on('click',this.nextStep,this);
	}
		
	// this.refresh=function()
	// {
	// 	this.MyMicro.refresh("DeleteMacro",this.MyMicro);
	// 	this.ListMacros.refresh(this.MyMicro.conf.getMacros('All'));
	// 	this.fire(this.DELETE_MACRO);
	// }
	// 
	
	this.setTitleDialogMacro();
	this.setContentDialogMacro();
	this.setButtonsDialogMacro();
}

AddMicrosCopy.prototype.getButtons=function()
{
	var p=document.createElement('p');
	p.className="buttons";
	this.cancel_btn=document.createElement('input');
	this.cancel_btn.setAttribute('type','button');
	this.cancel_btn.setAttribute('value','Cancel');
	p.appendChild(this.cancel_btn);

	this.next_btn=document.createElement('input');
	this.next_btn.setAttribute('type','button');
	this.next_btn.setAttribute('value','Next');
	p.appendChild(this.next_btn);	
	
	return p;
}

AddMicrosCopy.prototype.getContent=function()
{
	var tabs=document.createElement('div');
	tabs.className="tabsAddMicroscopy";
	this.tabViewAddMicrosCopySteps = new YAHOO.widget.TabView(); 
	
	this.create_step1();
	this.create_step2();
	this.create_step3();
	
	this.tabViewAddMicrosCopySteps.appendTo(tabs); 
	
	this.tabViewAddMicrosCopySteps.subscribe("activeTabChange",function(event,me)
															{
																me.currentStep=this.getTabIndex(event.newValue);
																if(me.currentStep!=2)
																{
																	me.btnYUIbutton.set('label','Next');
																}
																else
																{
																	me.btnYUIbutton.set('label','Finish and Reload Page');
																	me.currentStep=3;
																}
																
															},this);
	
	return tabs;
}

AddMicrosCopy.prototype.nextStep=function(event,args)
{
	var me=args;

	if(me.currentStep==3)
	{
		me.insertMicrosCopy();
	}
	
	if(me.currentStep<2)
	{
		me.currentStep++;
		me.tabViewAddMicrosCopySteps.selectTab(me.currentStep);

	}
	if(me.currentStep==2)
	{
		// alert(me.next_btn.value);
		me.btnYUIbutton.set('label','Finish and Reload Page');
		me.currentStep=3;
		// me.next_btn.value='Finish and Reload Page';
	}

}

AddMicrosCopy.prototype.check_url=function()
{
	if(this.nameMicro.value=='')
	{
		new dialog_alert("Error",'Missing Name Micro','error');											
		return -1;
	}
	if(this.ipmicro.value=='')
	{
		new dialog_alert("Error",'Missing IP Micro','error');											
		return -1;
	}
	else
	{
		if(this.check_ip()==-1)
		{
			return -1;
		}
	}
	if(this.SharingDirImages.value=='')
	{
		new dialog_alert("Error",'Missing Shared Dir Images Micro','error');											
		return -1;
	}
	if(this.LocalDirImages.value=='')
	{
		new dialog_alert("Error",'Missing Local Dir Images Micro','error');											
		return -1;
	}
	if(this.SharingDirTemplates.value=='')
	{
		new dialog_alert("Error",'Missing Shared Dir Templates Micro','error');											
		return -1;
	}
	if(this.LocalDirImages.value=='')
	{
		new dialog_alert("Error",'Missing Local Dir Images Micro','error');											
		return -1;
	}
	if(this.userSamba.value=='')
	{
		new dialog_alert("Error",'Missing User Samba','error');											
		return -1;
	}
	if(this.passSamba.value=='')
	{
		new dialog_alert("Error",'Missing Password Samba','error');											
		return -1;
	}
	
	var url='admin/cgi-bin/micro.cgi?ACTION=insertmicro';
	url+="&name="+this.nameMicro.value;
	url+="&ip="+this.ipmicro.value;
	url+="&sharingimagesdir="+this.SharingDirImages.value;
	url+="&imagesdir="+this.LocalDirImages.value;
	url+="&sharingtemplatesdir="+this.SharingDirTemplates.value;
	url+="&templatesdir="+this.LocalDirTemplates.value;
	url+="&user="+this.userSamba.value;
	url+="&passwd="+this.passSamba.value;
	
	return url;
}
AddMicrosCopy.prototype.check_ip=function()
{
	var ip=this.ipmicro.value.split('.');
	if(ip.length!=4)
	{
		new dialog_alert("Error",'Malformated IP, xxx.xxx.xxx.xxx','error');											
		return -1;
	}
	for(var i=0;i<ip.length;i++)
	{
		if(!parseInt(ip[i]) && ip[i] !=0)
		{
			new dialog_alert("Error",'Malformated IP, xxx.xxx.xxx.xxx, value '+ip[i]+' is not numeric','error');											
			return -1;
		}
		if(ip[i]<0 || ip[i]>254)
		{
			new dialog_alert("Error",'Malformated IP, xxx.xxx.xxx.xxx, xxx>0 and xxx<254','error');											
			return -1;
		}
	}
	return 0;
}
AddMicrosCopy.prototype.insertMicrosCopy=function()
{
	var url=this.check_url();
	if(url==-1)
	{
		return;
	}
	var callback = {
	  success: function(o) {
								myLogWriter.log(o.responseText, "info");
								window.location.reload();
							},
	  failure: function(o) {
								new dialog_alert("Error",o.responseText,'error');																			
								myLogWriter.log(o.status+":"+o.responseText, "info");
							}
	};
	
	
	var url='admin/cgi-bin/micro.cgi?ACTION=insertmicro';
	url+="&name="+this.nameMicro.value;
	url+="&ip="+this.ipmicro.value;
	url+="&sharingimagesdir="+this.SharingDirImages.value;
	url+="&imagesdir="+this.LocalDirImages.value;
	url+="&sharingtemplatesdir="+this.SharingDirTemplates.value;
	url+="&templatesdir="+this.LocalDirTemplates.value;
	url+="&user="+this.userSamba.value;
	url+="&passwd="+this.passSamba.value;
	
	

	var cObj = YAHOO.util.Connect.asyncRequest('GET', url, callback);
	// me.wait.show();
}

AddMicrosCopy.prototype.create_step1=function()
{
	var div=document.createElement('div');
	div.className='step1';
	var p=document.createElement('p');
	var label=document.createElement('div');
	label.className='label';
	
	label.innerHTML='Name Micro:';
	p.appendChild(label);	
	this.nameMicro=document.createElement('input');
	this.nameMicro.setAttribute('type','text');
	p.appendChild(this.nameMicro);
	div.appendChild(p);
	
	var p=document.createElement('p');
	var label=document.createElement('div');
	label.className='label';
	label.innerHTML='IP:';
	p.appendChild(label);	
	this.ipmicro=document.createElement('input');
	this.ipmicro.setAttribute('type','text');
	p.appendChild(this.ipmicro);
	div.appendChild(p);
	
	this.tabViewAddMicrosCopySteps.addTab( new YAHOO.widget.Tab({
        label: 'Step 1: Name',
        contentEl: div,
    	active: true
		}));
}

AddMicrosCopy.prototype.CheckDir=function(SharedDir)
{
	if(SharedDir[0] == '/' || SharedDir[0] == '\\')
	{
		
		return SharedDir.substr(1);
	}
	return SharedDir;
}

AddMicrosCopy.prototype.create_step2=function()
{
	var div=document.createElement('div');
	div.className='step2';
	
	var divImages=document.createElement('div');
	divImages.className='marco';
	var divTitleImages=document.createElement('div');
	divTitleImages.className="title";
	divTitleImages.innerHTML="Images (Warning Case Sensitive)";
	divImages.appendChild(divTitleImages);
	var p=document.createElement('p');
	var label=document.createElement('div');
	label.className='label';	
	label.innerHTML='Sharing Directory:';
	p.appendChild(label);	
	
	this.SharingDirImages=document.createElement('input');
	this.SharingDirImages.setAttribute('type','text');
	p.appendChild(this.SharingDirImages);
	divImages.appendChild(p);
	

	
	var p=document.createElement('p');
	var label=document.createElement('div');
	label.className='label';
	label.innerHTML='Images dir:';
	p.appendChild(label);	
	this.LocalDirImages=document.createElement('input');
	this.LocalDirImages.setAttribute('type','text');
	
	p.appendChild(this.LocalDirImages);
	divImages.appendChild(p);
	
	YAHOO.util.Event.addListener(this.SharingDirImages,'change',function(event,me)
																	{
																		this.value=me.CheckDir(this.value);
																		me.LocalDirImages.value=this.value;
																		
																	},this);
	
	var divTemplates=document.createElement('div');
	divTemplates.className='marco';
	var divTitleImages=document.createElement('div');
	divTitleImages.className="title";
	divTitleImages.innerHTML="Templates (Warning Case Sensitive)";
	divTemplates.appendChild(divTitleImages);
	
	var p=document.createElement('p');
	var label=document.createElement('div');
	label.className='label';	
	label.innerHTML='Sharing Directory:';
	p.appendChild(label);	
	
	this.SharingDirTemplates=document.createElement('input');
	this.SharingDirTemplates.setAttribute('type','text');
	p.appendChild(this.SharingDirTemplates);
	divTemplates.appendChild(p);
	
	var p=document.createElement('p');
	var label=document.createElement('div');
	label.className='label';
	label.innerHTML='Templates dir:';
	p.appendChild(label);	
	this.LocalDirTemplates=document.createElement('input');
	this.LocalDirTemplates.setAttribute('type','text');
	
	p.appendChild(this.LocalDirTemplates);
	divTemplates.appendChild(p);
	
	
	YAHOO.util.Event.addListener(this.SharingDirTemplates,'change',function(event,me)
																	{
																		this.value=me.CheckDir(this.value);
																		me.LocalDirTemplates.value=this.value;
																		
																	},this);
	
	div.appendChild(divImages);
	div.appendChild(divTemplates);
	
	this.tabViewAddMicrosCopySteps.addTab( new YAHOO.widget.Tab({
        label: 'Step 2: Directory Images And Templates',
        contentEl: div
	}));
}



AddMicrosCopy.prototype.create_step3=function()
{
	var div=document.createElement('div');
	div.className='step2';
	var p=document.createElement('p');
	var label=document.createElement('div');
	label.className='label';
	
	label.innerHTML='User:';
	p.appendChild(label);	
	this.userSamba=document.createElement('input');
	this.userSamba.setAttribute('type','text');
	p.appendChild(this.userSamba);
	div.appendChild(p);
	
	var p=document.createElement('p');
	var label=document.createElement('div');
	label.className='label';
	label.innerHTML='Password:';
	p.appendChild(label);	
	this.passSamba=document.createElement('input');
	this.passSamba.setAttribute('type','text');
	p.appendChild(this.passSamba);
	div.appendChild(p);
	
	this.tabViewAddMicrosCopySteps.addTab( new YAHOO.widget.Tab({
        label: 'Step 3: Credentials',
        contentEl: div
	}));
}
































