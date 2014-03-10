MicroStatus=function(connectionObj,micro,manager)
{

	this.connectionObj=connectionObj;
	this.micro=micro;
	this.manager=manager;
	
	this.totalwells=0;
	this.totalfields=0;
	this.progressbar=new progressBar();
	this.init();
}

MicroStatus.prototype.init=function()
{
	var me=this;
	var callback = {
	success: function(o) {
		  						if(o.responseText!='end')
								{
									me.progressbar.hide();
			  						var initrest=eval(o.responseText);
									me.totalwells=initrest[0].wells;
									me.totalfields=initrest[0].fields;
									me.createWindow(me.totalwells,me.totalfields);
									me.status.show();
									me.getstatus();
								}
								me.progressbar.hide();
							},
	  failure: function(o) {
		  						me.progressbar.hide();
								new dialog_alert("Notice",o.responseText,"notice");
							}
	};
	me.progressbar.show();
	var url='cgi-bin/STATUS/status.cgi?micro='+this.micro+'&init=1';
	var cObj = YAHOO.util.Connect.asyncRequest('GET', url, callback);
}

// 
MicroStatus.prototype.getstatus=function()
{
	var me=this;
	var callback = {
	  success: function(o) {
		  						if(o.responseText!='end')
								{
									if(o.responseText!='noack' && o.responseText!='next')
									{
										var current_status=eval(o.responseText);
										me.setStatus(current_status[0].well,current_status[0].field);
									}
									else
									{
										if(o.responseText=='next')
										{
											me.init();
										}
										else
										{
											me.getstatus();
										}
									}
								}
								else
								{
									me.wellpb.set('value',me.totalwells);
									me.fieldpb.set('value',me.totalfields);
								}
							},
	  failure: function(o) {
								new dialog_alert("Notice",o.responseText,"notice");
							}
	};
	var url='cgi-bin/STATUS/status.cgi?micro='+this.micro+'&init=0';
	var cObj = YAHOO.util.Connect.asyncRequest('GET', url, callback);
}


MicroStatus.prototype.setStatus=function(well,field)
{
	this.currentValueWellLabel.innerHTML=well;
	this.currentValueFieldLabel.innerHTML=field;
	this.wellpb.set('value',(well));
	this.fieldpb.set('value',(field));
	this.getstatus();
}

MicroStatus.prototype.createWindow=function(totalwells,totalfields)
{
	var optionWindow={
						expand:false,
						width:"500px",
						isExpanded:false,
						close:false,
						modal:true,
						center:true,
						visible:false
					};
	if(!this.status)
	{
		this.status=new itemWindow('Progress',document.body,this.manager,optionWindow);
	
		var div=document.createElement('div');
		var label=document.createElement('label');
		label.innerHTML='Progress:'+this.micro;
		this.status.getHead().appendChild(label);
	
		var wellDiv=document.createElement('div');
		wellDiv.className='status well';
		var label=document.createElement('label');
		label.innerHTML='WELLS:';
	
		var wellPB=document.createElement('div');
		wellPB.className='progressbar';
		this.wellpb = new YAHOO.widget.ProgressBar({
												value:0,
												maxValue:totalwells,
												minValue:0
											}).render(wellPB);
		this.currentValueWellLabel=document.createElement('label');
		this.currentValueWellLabel.className='current';
		this.currentValueWellLabel.innerHTML=1;
		this.labelTotalWell=document.createElement('label');
		this.labelTotalWell.className='total';
	
		wellDiv.appendChild(label);
		wellDiv.appendChild(wellPB);
		wellDiv.appendChild(this.currentValueWellLabel);
		wellDiv.appendChild(this.labelTotalWell);
	
		var FieldDiv=document.createElement('div');
		FieldDiv.className='status well';
		var label=document.createElement('label');
		label.innerHTML='FIELDS:';
	
		var fieldPB=document.createElement('div');
		fieldPB.className='progressbar';
		this.fieldpb = new YAHOO.widget.ProgressBar({
												value:0,
												maxValue:totalfields,
												minValue:0
											}).render(fieldPB);
	
		this.currentValueFieldLabel=document.createElement('label');
		this.currentValueFieldLabel.className='current';
		this.currentValueFieldLabel.innerHTML=1;
		this.labelTotalField=document.createElement('label');
		this.labelTotalField.className='total';
	
		FieldDiv.appendChild(label);
		FieldDiv.appendChild(fieldPB);
		FieldDiv.appendChild(this.currentValueFieldLabel);
		FieldDiv.appendChild(this.labelTotalField);
	
		div.appendChild(wellDiv)
		div.appendChild(FieldDiv);
		this.status.getBody().appendChild(div); 
	}
	
	this.currentValueWellLabel.innerHTML=0;
	this.currentValueFieldLabel.innerHTML=0;
	this.wellpb.set('value',0);
	this.wellpb.set('maxValue',totalwells);
	
	this.fieldpb.set('value',0);
	this.fieldpb.set('maxValue',totalfields);
	
	
	this.labelTotalWell.innerHTML=totalwells;
	this.labelTotalField.innerHTML=totalfields;
	
}
MicroStatus.prototype.show=function()
{
	this.status.show();
}
MicroStatus.prototype.hide=function()
{
	if(this.status)
	{
		this.status.hide();
		this.status.destroy();
	}
}
//isCallInProgress will return true if the transaction has not been completed.
// var callStatus = YAHOO.util.Connect.isCallInProgress(cObj);