stitching=function(stitching,container,manager,MyMicro)
{
	this.name="Stiching";
	this.running=false;
	this.container=container;
	this.template_step2="";
	this.codeColor="";
	
	this.MyMicro=MyMicro;
	
	var optionWindow={
						expand:false,
						width:"750px",
						isExpanded:false,
						close:false,
						modal:false,
						center:false,
						visible:false
					};
					
	
	var PanelViewStitchingOptions={
										expand:false,
										width:"600px",
										isExpanded:false,
										close:true,
										modal:true,
										center:true,
										visible:false
									};
									
	
	this.stitching=new itemWindow(stitching,container,manager,optionWindow);
	this.create_window(MyMicro.conf.getMacros('Stitching'));
	
	this.PanelViewStitching=null;
	this.PanelViewStitching=new itemWindow("PanelViewStitching",document.body,manager,PanelViewStitchingOptions);
	this.imgenStitching=null;
	this.create_window_view_stitching();
	

	
	// document.getElementById("ViewImageStitching").style.visibility="hidden";
	this.onReadyEvent=new YAHOO.util.CustomEvent("onReady",null);
	this.onFinishedEvent=new YAHOO.util.CustomEvent("onFinished",null);
	this.onErrorEvent=new YAHOO.util.CustomEvent("onError",null);
	
	
}
stitching.prototype.create_window_view_stitching=function()
{
	var label=document.createElement('lable');
	label.innerHTML="Stitch Image";
	this.PanelViewStitching.getHead().appendChild(label);
	
	var p=document.createElement('p');
	this.imgenStitching=document.createElement('img');
	p.appendChild(this.imgenStitching);
	
	this.PanelViewStitching.getBody().appendChild(p);
	
	
}
stitching.prototype.RefreshListMacroStitching=function(listMacrosStitching)
{	
	this.MacroStitching.refresh(listMacrosStitching);	
}

stitching.prototype.RefreshList=function()
{
	this.RefreshListMacroStitching(this.MyMicro.conf.getMacros('Stitching'));
}
stitching.prototype.getRoutine=function()
{
	return this.MacroStitching.getValue();
}
stitching.prototype.setRoutine=function(routine)
{
	return this.MacroStitching.setValue(routine);
}

stitching.prototype.getCodeColor=function()
{
	return this.codeColor.getValue();
}
stitching.prototype.setCodeColor=function(codecolor)
{
	return this.codeColor.setValue(codecolor);
}

stitching.prototype.create_window=function(macrosStitching)
{
	
	var label=document.createElement('lable');
	label.innerHTML=this.name;
	this.stitching.getHead().appendChild(label);
	
	var p=document.createElement('p');

	this.MacroStitching=new combo('Select Macro',p,macrosStitching);
	

	this.stitching.getBody().appendChild(p);
	
	var pMenuCodeColor=document.createElement('p');
	var menu = [
			{ text: "One Color", value: 'ONE'},
			{ text: "Blue,Green,Red", value: 'BGR'},
			{ text: "Blue,Red,Green", value: 'BRG'},
			{ text: "Red,Green,Blue", value: 'RGB'},
			{ text: "Blue,Red,Green", value: 'RBG'},
			{ text: "Green,Blue,Red", value: 'GBR'},
			{ text: "Green,Red,Blue", value: 'GRB'},
			{ text: "Green,Red", value: 'GR'},
			{ text: "Red,Green", value: 'RG'},
			{ text: "Green,Blue", value: 'GB'},
			{ text: "Blue,Green", value: 'BG'},
			{ text: "Blue,Red", value: 'BR'},
			{ text: "Red,Blue", value: 'RB'}
	
		];
		
	this.stitching.getBody().appendChild(pMenuCodeColor);
		
	this.codeColor=new combo('Select Code Color',pMenuCodeColor);
	this.codeColor.setMenu(menu);
	
	var p=document.createElement('p');
	p.setAttribute('id','ViewImageStitching');
	// var select=document.createElement('select');
	// select.setAttribute('id','stitchingimages');
	// select.setAttribute('name','stitchingimages');
	

	var input=document.createElement('input');
	input.setAttribute('type','button');
	input.setAttribute('id','btnstitchingimages');
	input.setAttribute('name','btnstitchingimages');
	input.setAttribute('value','View');
	// div_select.appendChild(select);
	// p.appendChild(select);
	p.appendChild(input);
	this.stitching.getBody().appendChild(p);
	this.SelectViewImagesStitching=new combo('Select Images',p);
	

	
	new YAHOO.widget.Button("btnstitchingimages"); 
	YAHOO.util.Event.addListener(document.getElementById("btnstitchingimages"),"click",this.viewStitchImage,this);
	


	var input=document.createElement('input');
	input.setAttribute('type','button');
	input.setAttribute('id','stitchingbtn');
	input.setAttribute('name','stitchingbtn');
	input.setAttribute('value','Stiching');
	this.stitching.getFooter().appendChild(input);
	new YAHOO.widget.Button("stitchingbtn"); 
	YAHOO.util.Event.addListener(document.getElementById("stitchingbtn"),"click",this.run,this);
	
	
}


stitching.prototype.show=function()
{
	// document.getElementById("ViewImageStitching").style.display="block";
	this.container.style.display="block";
	this.running=true;
	
	this.stitching.show();
	
}
stitching.prototype.hide=function()
{
	// document.getElementById("ViewImageStitching").style.display="none";
	this.container.style.display="none";
	this.running=false;
	
	this.stitching.hide();
}
stitching.prototype.viewStitchImage=function(event,me)
{
	var callback = {
	  success: function(o) {
								
								me.imgenStitching.setAttribute('src',o.responseText);
								me.PanelViewStitching.show();
								me.MyMicro.conf.progressbar.hide();
							},
	  failure: function(o) {myLogWriter.log(o.status+":"+o.statusText, "info");me.MyMicro.conf.progressbar.hide();
	}
	};
	
	if(me.SelectViewImagesStitching.getValue() != '' && me.SelectViewImagesStitching.getValue() != undefined)
	{
		var url;
		var channels=me.codeColor.getValue();
		if(channels != undefined)
		{
			url='cgi-bin/ViewImageStitching.cgi?image='+me.SelectViewImagesStitching.getValue()+"&conf="+me.MyMicro.getCurrentMicro();
			url+="&channels="+channels;
			var cObj = YAHOO.util.Connect.asyncRequest('GET', url, callback);
			me.MyMicro.conf.progressbar.show(me.name);
		}
		else
		{
			new dialog_alert("Error",'Missing CodeColor',"error");									

			me.onErrorEvent.fire('ERROR:Missing CodeColor');
		}
	}
	else
	{
		new dialog_alert("Error",'Select Image,please',"error");									

		me.onErrorEvent.fire('ERROR:Select Image,please');
	}
	
}

stitching.prototype.run=function(event,me)
{
	var callback = {
	  success: function(o) {
								var http_request = new XMLHttpRequest();
								var sURL = "cgi-bin/getImagesStitching.cgi?conf="+me.MyMicro.getCurrentMicro()+"&dir="+me.MyMicro.getSelectExperiment();
							    http_request.open("GET", sURL, false);
							    http_request.send(null);
								var response=eval(http_request.responseText);
								var menu = new Array();
								for(iresponse=0;iresponse<response.length;iresponse++)
								{
									var item={text: "", value: ''};
									item.text=response[iresponse].name;
									item.value=response[iresponse].path+"/"+response[iresponse].name;
									menu[iresponse]=item;
								}
								me.SelectViewImagesStitching.setMenu(menu);
								myLogWriter.log(o.responseText, "info");
								me.MyMicro.conf.progressbar.hide();
								me.onFinishedEvent.fire();
								
							},
	  failure: function(o) {
								myLogWriter.log(o.status+":"+o.statusText, "info");
								me.MyMicro.conf.progressbar.hide();
								new dialog_alert("Notice",o.responseText,"notice");									
								
								
							}
	};
	
	var menu = new Array();
		
	var url=me.check();
	if(url!=-1)
	{
		var cObj = YAHOO.util.Connect.asyncRequest('GET', url, callback);
		if(event != 'RUNAllProcess')
		{
			me.MyMicro.conf.progressbar.show(me.name);
		}
	}
}
stitching.prototype.check=function()
{
	var url='cgi-bin/LeicaConfocal.cgi?step=join&name='+this.MyMicro.getCurrentMicro();
	var dirImages=this.MyMicro.getSelectExperiment();
	var template_step2=this.template_step2;
	var codeColor=this.codeColor.getValue();
	var macroStitching=this.MacroStitching.getValue();
	if(dirImages=='' || dirImages==undefined)
	{
		new dialog_alert("Error",'Missing Xgrid and yGrid, please running imagej again or Select dir Images',"error");									
		this.onErrorEvent.fire('ERROR:Missing Xgrid and yGrid, please running imagej again');
		return -1;
	}
	if(macroStitching=='' || macroStitching==undefined)
	{
		new dialog_alert("Error",'Select Macro, please',"error");									
		this.onErrorEvent.fire('ERROR:Select Macro, pleas');
		return -1;
	}
	if(template_step2 =='' || template_step2==undefined)
	{
		new dialog_alert("Error",'Missing Template Step2',"error");									
		
		this.onErrorEvent.fire('ERROR:Missing Template Step2');
		return -1;
	}
	if(codeColor==undefined)
	{
		new dialog_alert("Error",'Missing CodeColor',"error");									
		
		this.onErrorEvent.fire('ERROR:Missing CodeColor');
		return -1;
	}	

	var url='cgi-bin/LeicaConfocal.cgi?step=join&name='+this.MyMicro.getCurrentMicro();
	url +="&dir="+this.MyMicro.getSelectExperiment();
	url+='&template_step2='+this.template_step2;
	url+='&macro_stitching=stitching/'+macroStitching;
	url+='&codecolor='+codeColor;
	
	return url;
}
