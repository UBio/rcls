high=function(step,container,manager,micro)
{
	this.name="High Resolution Scanning";
	this.running=true;
	this.container=container;
	this.MyMicro=micro;
	this.template_step2;
	
	this.container=container;
	this.step=step;
	this.error=0;
	this.scanAllTemplates=true;
	this.currentTempleteScan=1;
	var optionWindow={
						expand:false,
						width:"750px",
						isExpanded:false,
						close:false,
						modal:false,
						center:false,
						visible:true
					};
					
	this.high=new itemWindow(step,container,manager,optionWindow);
	this.create_window();

	this.onFinishedOneEvent=new YAHOO.util.CustomEvent("onFinishedOne",null);
	this.onReadyEvent=new YAHOO.util.CustomEvent("onReady",null);
	this.onFinishedEvent=new YAHOO.util.CustomEvent("onFinished",null);
	this.onErrorEvent=new YAHOO.util.CustomEvent("onError",null);
	
	
}
high.prototype.getScanAllTempates=function()
{
	return this.scanAllTemplates;
}

high.prototype.setScanAllTempates=function(value)
{
	this.scanAllTemplates=value;
	this.inputcheckbox.checked=value;
}
high.prototype.create_window=function()
{
	
	var label=document.createElement('label');
	label.innerHTML=this.name;
	this.high.getHead().appendChild(label);
	
	var p=document.createElement('p');
	this.inputcheckbox=document.createElement('input');
	this.inputcheckbox.setAttribute('type','checkbox');
	this.inputcheckbox.setAttribute('id','chkalltemplatestep2');
	this.inputcheckbox.setAttribute('checked',true);
	var label=document.createElement('label');
	label.innerHTML="Scan All Templates:&nbsp;";
	
	YAHOO.util.Event.addListener(this.inputcheckbox,"change",function(event,me){me.scanAllTemplates=this.checked;},this);
	
	p.appendChild(label);
	p.appendChild(this.inputcheckbox);
	
	this.high.getBody().appendChild(p);

	var p=document.createElement('p');
	this.select=document.createElement('select');
	this.select.setAttribute('name','select_template_high');
	
	// var o=document.createElement('option');
	// o.innerHTML='Prueba1';
	// o.setAttribute('value','p1');
	// this.select.appendChild(o);
	// var o=document.createElement('option');
	// o.innerHTML='Prueba2';
	// o.setAttribute('value','p2');
	// this.select.appendChild(o);
	// var o=document.createElement('option');
	// o.innerHTML='Prueba3';
	// o.setAttribute('value','p3');
	// this.select.appendChild(o);
	// 
	var label=document.createElement('label');
	label.innerHTML="Select Template:";	
	p.appendChild(label);
	p.appendChild(this.select);
	
	this.high.getBody().appendChild(p);
	
	var input=document.createElement('input');
	input.setAttribute('type','button');
	input.setAttribute('id','PlayStep2');
	input.setAttribute('name','PlayStep2');
	input.setAttribute('value',"Run High Scanning");
	this.high.getFooter().appendChild(input);

	this.PlayStep2Btn=new YAHOO.widget.Button("PlayStep2",{disabled:false}); 
	YAHOO.util.Event.addListener(document.getElementById("PlayStep2"),"click",this.run,this);
	
}
high.prototype.newTemplates=function(templates)
{
	// this.select=document.getElementById('select_template_high');
	this.select.innerHTML=""
	for(var i=0;i<templates.length;i++)
	{
		var option=document.createElement('option');
		option.value=templates[i];
		option.innerHTML=templates[i];
		this.select.appendChild(option);
	}
}
high.prototype.show=function()
{
	this.high.show();
	this.running=true;
	this.container.style.display='inline';
}
high.prototype.hide=function()
{
	this.high.hide();
	this.running=false;
	this.container.style.display='none';
}
high.prototype.run=function(event,me)
{
	
	//var MicroIsUse=me.MyMicro.isUse();
	var callback = {
	  success: function(o) {
								var response=eval(o.responseText);
								myLogWriter.log(o.responseText, "info");
								me.MyMicro.conf.progressbar.hide();

								if(me.currentTempleteScan<me.select.getElementsByTagName('option').length)
								{
									me.onFinishedOneEvent.fire();
									me.currentTempleteScan++;
									me.run('nextTemplate',me);
								}
								else
								{
								if(!me.scanAllTemplates || me.currentTempleteScan>=me.select.getElementsByTagName('option').length)
								{
									me.onFinishedEvent.fire();
									me.currentTempleteScan=1;
									if(event != 'RUNAllProcess')
									{
										new dialog_alert("Finish",me.name,"info");									
									}
								}
								}
							},
	  failure: function(o) {
								myLogWriter.log(o.status+":"+o.statusText, "info");
								me.MyMicro.conf.progressbar.hide();
								
								me.disabledAllButtons();
								me.lockEvent.fire();
								me.dialog("Notice",o.responseText);
							}
	};

	var url=me.check()
	if(url!=-1)
	{
		var cObj = YAHOO.util.Connect.asyncRequest('GET', url, callback);
		if(event != 'RUNAllProcess')
		{
			me.MyMicro.conf.progressbar.show();
		}
	}
	
}
high.prototype.check=function()
{
	//Necesitamos el template 2 para precargarlo
	var url='cgi-bin/LeicaConfocal.cgi?step=high&template_high='+this.select.getElementsByTagName('option')[this.currentTempleteScan-1].value;
	url+="&name="+document.getElementById("micro").value+"&template_step2="+this.template_step2;
	if(this.select.value=='')
	{
		new dialog_alert("Error",'missing template high',"error");									
		
		this.onErrorEvent.fire("ERROR: missing template high");
		return -1;
	}
	if(this.template_step2=='' || this.template_step2==undefined)
	{
		new dialog_alert("Error",'missing template 2',"error");									
		this.onErrorEvent.fire("ERROR: missing template");
		return -1;
	}
	return url;
}
// En el exp: experiment--2013_01_29_16_08
//  
// Con Cytoolow10X y Pattern63X o si lo quieres normal hay un Cytoolow63X
//  
// Threshold 100-255
// Tamaño 15-45 deberian salirte 10 o 15 posiciones únicas no mosaicos
//  
// Ya me dices si puedo hacer algo
//  
// Diego
