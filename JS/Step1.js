step1=function(step,container,manager,MyMicro)
{
	this.name=imrc_labels['step1']['title'];
	this.running=true;
	this.container=container;
	this.step=step;
	this.error=0;
	this.MyMicro=MyMicro;
	

	
	var optionWindow={
						expand:true,
						width:"750px",
						isExpanded:false,
						close:false,
						modal:false,
						center:false,
						visible:true
					};
	this.step1=new itemWindow(step,container,manager,optionWindow);
	this.create_window();
	
	
	
	this.MyMicro.selectExperimentEvent.subscribe(function(event,args,me){if(args ==""){
													//me.visible(true);
													me.AFPlayStep1Btn.set('disabled',false);
												}
												else
												{
													//me.visible(false);
													me.AFPlayStep1Btn.set('disabled',true);
												}
												},this);
	
										
	this.MyMicro.unlockEvent.subscribe(function(event,args,me){
											me.AFPlayStep1Btn.set('disabled',false);
											me.ViewScanStep1Btn.set('disabled',false);
											me.unlockEvent.fire();
										},this);
	this.MyMicro.lockEvent.subscribe(function(event,args,me){
										me.AFPlayStep1Btn.set('disabled',true);
										me.ViewScanStep1Btn.set('disabled',true);
										me.lockEvent.fire();
									},this);
	this.ViewScanStep1 =  
			new YAHOO.widget.Panel("PanelViewScanStep1",  
				{ width:"600px",
				  height:"400px",
				  fixedcenter:true, 
				  close:true, 
				  draggable:false, 
				  zindex:4,
				  modal:true,
				constraintoviewport:true,

				  visible:false
				} 
			);
	
	this.MicroIsUse=this.MyMicro.isUse();
	
	if(this.MicroIsUse)
	{
		this.AFPlayStep1Btn.set('disabled',true);
		this.ViewScanStep1Btn.set('disabled',true);
	}
	else
	{
		this.AFPlayStep1Btn.set('disabled',false);
		this.ViewScanStep1Btn.set('disabled',false);
	}
	
	this.onReadyEvent=new YAHOO.util.CustomEvent("onReady",null);
	this.onFinishedEvent=new YAHOO.util.CustomEvent("onFinished",null);
	
	this.onErrorEvent=new YAHOO.util.CustomEvent("onError",null);
	
	this.unlockEvent=new YAHOO.util.CustomEvent("unLock",null);
	this.lockEvent=new YAHOO.util.CustomEvent("Lock",null);
	
	
	MyMicro.changeMicroEvent.subscribe(function(event,args,me){
																me.oAC.destroy();
																me.oAC=new autoCompleteConfocal(me.MyMicro.conf.getTemplates(),"step1","myContainerACStep1");
																},this);
												
}

step1.prototype.create_window=function()
{
	var label=document.createElement('label');
	label.innerHTML=this.name;
	
	this.step1.getHead().appendChild(label);
	
	// 		<p>
	// 			<div class="autocomplete" id="myAutoCompleteStep1">
	// 				Select Low Resolution Scanning Settings:
	// 				<input id="step1" name="step1" type="text">
	// 				<div id="myContainerACStep1" class="ContainerAutoComplete"></div>
	// 			</div>
	// 		</p>
	// 		<p>Remove Blacks: <input type="checkbox" id="chkremoveblacks"  />
	// 							<select id="selectmacro_blacks" name="removeblacks">
	// 							</select>
	// 		</p>
	
	
	var p=document.createElement('p');

	var label=document.createElement('label');
	label.innerHTML=imrc_labels['step1']['label1'];

	var divautocomplete=document.createElement('div');
	divautocomplete.className="autocomplete";
	divautocomplete.setAttribute('id','myAutoCompleteStep1');
	divautocomplete.appendChild(label);
	
	var input=document.createElement('input');
	input.setAttribute('id','step1');
	input.setAttribute('name','step1');
	input.setAttribute('type','text');
	divautocomplete.appendChild(input);
	var div=document.createElement('div');
	div.setAttribute('id','myContainerACStep1');
	div.className="ContainerAutoComplete";
	divautocomplete.appendChild(div);
	
	p.appendChild(divautocomplete);	
	this.step1.getBody().appendChild(p);


	
	
	var input=document.createElement('input');
	input.setAttribute('id','AFPlayStep1');
	input.setAttribute('name','step1');
	input.setAttribute('type','button');
	input.setAttribute('value',imrc_labels['step1']['button1']);
	input.className='bottom_footer';
	var divMakeAF=document.createElement('div');
	divMakeAF.className='MakeAF';
		
	this.step1.getFooter().appendChild(input);
	this.step1.getFooter().appendChild(divMakeAF);
	
	var select=document.createElement('select');
	select.setAttribute('id','ViewScanStep1_select');
	select.setAttribute('name','ViewScanStep1_select');
	this.step1.getFooter().appendChild(select);

	var input=document.createElement('input');
	input.setAttribute('id','ViewScanStep1');
	input.setAttribute('name','ViewScanStep1');
	input.setAttribute('type','button');
	input.setAttribute('value',imrc_labels['step1']['button3']);
	this.step1.getFooter().appendChild(input);	
	
	this.AFPlayStep1Btn=new YAHOO.widget.Button("AFPlayStep1",{disabled:true}); 
	this.ViewScanStep1Btn=new YAHOO.widget.Button("ViewScanStep1");


	YAHOO.util.Event.addListener(document.getElementById("ViewScanStep1"),"click",this.ViewScanStep1,this);	
	YAHOO.util.Event.addListener(document.getElementById("AFPlayStep1"),"click",this.run,this);
	this.makeAF = new YAHOO.widget.Button({
	                            type: "checkbox",
	                            label: imrc_labels['step1']['button2']['on'],
	                            value: "1",
	                            container: divMakeAF,
	                            checked: true });

	this.makeAF.subscribe("checkedChange",this.onMakeAF,this);
	
	this.oAC=new autoCompleteConfocal(this.MyMicro.conf.getTemplates(),"step1","myContainerACStep1");
	
}
step1.prototype.onMakeAF=function(event,me)
{
	if(event.newValue)
	{
		this.set('label', imrc_labels['step1']['button2']['on']);
	}
	else
	{
		this.set('label',imrc_labels['step1']['button2']['off']);

	}
}

step1.prototype.refresh=function()
{
	this.MyMicro.refresh("step1",this.MyMicro);
}
step1.prototype.disabledAllButtons=function()
{
	this.AFPlayStep1Btn.set('disabled',true);
	this.ViewScanStep1Btn.set('disabled',true);
}

// step1.prototype.show=function()
// {
// 	// var error=this.MyMicro.show();
// 	// if(error==0)
// 	// {
// 	// 	this.step1.show();
// 	// 	return 0;
// 	// }
// 	// return -1;
// }

step1.prototype.ViewScanStep1=function(event,me)
{
	var callback = {
	  success: function(o) {
		
								var response=eval(o.responseText);
								var def;
								def=response[0].def;
								var images=response[0].images;
							
								if(images.length>0)
								{
									document.getElementById('ViewScanStep1_select').innerHTML="";
									for(var i=0;i<images.length;i++)
									{
										var option=document.createElement('option');
										option.setAttribute('value',images[i].image);
										option.innerHTML=images[i].name;
										document.getElementById('ViewScanStep1_select').appendChild(option);
									}
									myLogWriter.log(o.responseText, "info");
									document.getElementById('ViewScanStep1_select').style.display="inline";
								}
								me.ViewScanStep1.setHeader("Low Resolution Image");
								me.ViewScanStep1.setBody('<img width="600px" src="'+def+'"/>');
								me.ViewScanStep1.render(document.body);
								me.ViewScanStep1.show();
								
								me.MyMicro.conf.progressbar.hide();
							},
	  failure: function(o) {myLogWriter.log(o.status+":"+o.statusText, "info");me.MyMicro.conf.progressbar.hide();}
	};
	if(!me.MyMicro.isUse())
	{
		var image=document.getElementById("ViewScanStep1_select").value;
		var dir=me.MyMicro.getSelectExperiment();
		var url='cgi-bin/ViewImageStep1.cgi?conf='+me.MyMicro.getCurrentMicro();
		url+="&image="+image;
		url+="&dir="+dir;
		
		if(image == '' &&  dir==undefined)
		{
			new dialog_alert("Notice","Select dir o run this step first","notice");
		}
		else
		{
			var cObj = YAHOO.util.Connect.asyncRequest('GET', url, callback);
			me.MyMicro.conf.progressbar.show();
		}
	}
}

step1.prototype.getTemplate=function()
{
	return document.getElementById('step1').value;
}

step1.prototype.setTemplate=function(template)
{
	return this.oAC.setValue(template);
}


step1.prototype.visible=function(value)
{
	if(value)
	{
		this.step1.show();
		this.running=true;
		this.container.style.display='inline';		
	}
	else
	{
		this.step1.hide();
		this.container.style.display='none';
		this.running=false;
	}
}

step1.prototype.run=function(event,me)
{
	
	//var MicroIsUse=me.MyMicro.isUse();
	var callback = {
	  success: function(o) {
								var response=eval(o.responseText);
								document.getElementById('ViewScanStep1_select').innerHTML="";
								
								if(response.length>0)
								{
									var experimentpath=response[0].image.split("/"); 
									var experimentDir=experimentpath[experimentpath.length-5];
									me.MyMicro.setSelectExperiment(experimentDir);									
								}
								for(var i=0;i<response.length;i++)
								{
									var option=document.createElement('option');
									option.setAttribute('value',response[i].image);
									option.innerHTML=response[i].name;
									document.getElementById('ViewScanStep1_select').appendChild(option);
								}
								myLogWriter.log(o.responseText, "info");
								document.getElementById('ViewScanStep1_select').style.display="inline";
								me.MyMicro.conf.progressbar.hide();
								
								me.onFinishedEvent.fire();
								
							},
	  failure: function(o) {
								myLogWriter.log(o.status+":"+o.statusText, "info");
								me.MyMicro.conf.progressbar.hide();
								
								me.disabledAllButtons();
								me.lockEvent.fire();
								new dialog_alert("Notice",o.responseText,"notice");
								
							}
	};

	
	if(me.check()==0)
	{
		var url='cgi-bin/LeicaConfocal.cgi?step=step1&template_step1='+document.getElementById("step1").value;
		url+="&name="+document.getElementById("micro").value;
		url+="&autofocus"+me.makeAF.get('checked');
		
		// var cObj = YAHOO.util.Connect.asyncRequest('GET', url, callback);
		if(event != 'RUNAllProcess')
		{
			me.MyMicro.conf.progressbar.show();
		}
	}
}
step1.prototype.show=function()
{
	this.step1.show();
	this.running=true;
	this.container.style.display='inline';	
}
step1.prototype.hide=function()
{
	this.step1.hide();
	this.running=false;
	this.container.style.display='none';
}

step1.prototype.check=function()
{
	if(document.getElementById("step1").value == '')
	{
		new dialog_alert("Error",'','Error','STEP1_MISS_TEM');	
		this.onErrorEvent.fire('STEP1_MISS_TEM');
		return -1;
	}
	return 0;
}

