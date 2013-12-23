SaveExperiment=function(manager,micro,lowObj,detectionObj,highObj,stitching)
{
	this.MyMicro=micro;
	this.lowObj=lowObj;
	this.detectionObj=detectionObj;
	this.highObj=highObj;
	this.stitchingObj=stitching;
	this.cancel_btn;
	
	this.save_btn;
	
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
	// 
	this.setTitleDialogApp=function()
	{
		var label=document.createElement('label');
		label.innerHTML="Save ....";
		_setTitleDialogApp(label);
	}
	// 
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
		new YAHOO.widget.Button(this.save_btn).on('click',this.save,this);
	}
	
	this.setTitleDialogApp();
	
	this.setContentDialogApp();
	
	this.setButtonsDialogApp();
	
};
SaveExperiment.prototype.getContent=function()
{
	
	var div=document.createElement('div')
	var p=document.createElement('p');
	var label=document.createElement('label');
	label.innerHTML="Name:";
	label.className='label';
	p.appendChild(label);	
	this.nameFile=document.createElement('input');
	this.nameFile.setAttribute('type','text');
	this.nameFile.setAttribute('value',	this.MyMicro.getCurrentMicro()+"_"+this.MyMicro.getSelectExperiment());
	p.appendChild(this.nameFile);
	div.appendChild(p);
	
	
	
	return div;
}


SaveExperiment.prototype.getButtons=function()
{
	var p=document.createElement('p');
	p.className="buttons";
	this.cancel_btn=document.createElement('input');
	this.cancel_btn.setAttribute('type','button');
	this.cancel_btn.setAttribute('value','Cancel');
	p.appendChild(this.cancel_btn);

	this.save_btn=document.createElement('input');
	this.save_btn.setAttribute('type','button');
	this.save_btn.setAttribute('value','Save');
	p.appendChild(this.save_btn);	
	
	return p;
}

SaveExperiment.prototype.save=function(event,me)
{
	
	var url='exp='+me.MyMicro.getSelectExperiment();
	url+='&name_file='+me.nameFile.value;
	url+='&micro='+me.MyMicro.getCurrentMicro();
	url+='&lowTemplate='+me.lowObj.getTemplate();
	url+='&det_routine_name='+me.detectionObj.getRoutine();
	url+='&det_template='+me.detectionObj.getTemplate();
	url+='&threshold='+me.detectionObj.getAdvanceOptions().thresholdmin+","+me.detectionObj.getAdvanceOptions().thresholdmax;
	url+='&size='+me.detectionObj.getAdvanceOptions().size+","+me.detectionObj.getAdvanceOptions().maxsize;
	url+='&circularity='+me.detectionObj.getAdvanceOptions().circularity;	
	url+='&correction='+me.detectionObj.getCorrection();
	
	url+='&rm_blacks='+me.detectionObj.getRemoveBlacksParams().value;
	url+='&rm_blacks_template='+me.detectionObj.getRemoveBlacksParams().template;
	url+='&highAll='+me.highObj.getScanAllTempates();
	
	url+='&stitch_routine_name='+me.stitchingObj.getRoutine();
	url+='&stitch_cod_color='+me.stitchingObj.getCodeColor();
	

	var url='cgi-bin/Experiment/save.cgi?'+url
	window.location=url;
	me.hide();
}