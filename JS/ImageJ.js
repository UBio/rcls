imagej=function(imagej,container,manager,MyMicro)
{
	this.name=imrc_labels['imagej']['title'];
	this.container=container;
	this.running=true;
	this.MyMicro=MyMicro;
	this.currentImage;
	this.currentSlide=0;
	this.currentChamber=0;
	this.currentOptionsImagen=new Array();
	this.currentOptionsImagen[0]=new Array();
	this.currentOptionsImagen[0][0]=this.getParametersDefaultImage();
	this.panelChangeImage=null;
	this.panelOptiones=null;
	this.PanelViewImageJ=null;
	this.manager=manager;

	this.rotate=0;

	this.SelectChangeImage=document.createElement('select');
	this.isRun=false;

	var optionWindow={
						expand:false,
						width:"750px",
						isExpanded:false,
						close:false,
						modal:false,
						center:false,
						visible:true
					};

	this.imagej=new itemWindow(imagej,container,manager,optionWindow);
	this.create_window(MyMicro.conf.getMacros('Detect'),MyMicro.conf.getTemplates());



	this.unlockEvent=new YAHOO.util.CustomEvent("unLock",null);
	this.lockEvent=new YAHOO.util.CustomEvent("Lock",null);
	this.onReadyEvent=new YAHOO.util.CustomEvent("onReady",null);
	this.onFinishedEvent=new YAHOO.util.CustomEvent("onFinished",null);
	this.onErrorEvent=new YAHOO.util.CustomEvent("onError",null);
	this.onRemoveBlacksEvent=new YAHOO.util.CustomEvent("onRemoveBlacks",null);
	this.onChangeTemplateStep2Event=new YAHOO.util.CustomEvent("onChangeTemplateStep2",null);

	MyMicro.changeMicroEvent.subscribe(function(event,args,me){
																me.oAC.destroy();
																me.oAC=new autoCompleteConfocal(me.MyMicro.conf.getTemplates(),"step2","myContainerACStep2");
																},this);

// this.getParams();
}


imagej.prototype.show=function()
{
	this.imagej.show();
	this.running=true;
	this.container.style.display='inline';
}
imagej.prototype.hide=function()
{
	this.imagej.hide();
	this.running=false;
	this.container.style.display='none';
}


imagej.prototype.CreateListMacroDetect=function(listMacrosDetect)
{
	var p=document.createElement(p);
	this.ListMacrosDetect=new combo(imrc_labels['imagej']['label1'],p,listMacrosDetect);
	return p;
}
imagej.prototype.CreateListMacroBlack=function(listMacrosBlacks)
{
	var p=document.createElement('p');

	this.chkremoveblacks = new YAHOO.widget.Button({
	                            type: "checkbox",
	                            label: imrc_labels['imagej']['button1']['off'],
	                            value: "1",
	                            container: p,
	                            checked: false });

	this.chkremoveblacks.subscribe("checkedChange",this.onRemoveBlacks,this);

	this.ListMacrosBlack=new combo(imrc_labels['imagej']['label3'],p,listMacrosBlacks);
	this.ListMacrosBlack.disabled();
	return p;
}
imagej.prototype.RefreshListMacroDetect=function(listMacrosDetect)
{
	this.ListMacrosDetect.refresh(listMacrosDetect);
}
imagej.prototype.RefreshListMacroBlack=function(listMacrosBlacks)
{
	this.ListMacrosBlack.refresh(listMacrosBlacks);
}

imagej.prototype.RefreshList=function()
{
	this.RefreshListMacroDetect(this.MyMicro.conf.getMacros('Detect'));
	this.RefreshListMacroBlack(this.MyMicro.conf.getMacros('Blacks'));
}

imagej.prototype.getRoutine=function()
{
	return this.ListMacrosDetect.getValue();
}
imagej.prototype.setRoutine=function(routine)
{
	return this.ListMacrosDetect.setValue(routine);
}


imagej.prototype.getTemplate=function()
{
	return this.oAC.getValue();
}
imagej.prototype.setTemplate=function(template)
{
	return this.oAC.setValue(template);
}
// imagej.prototype.getCorrection=function()
// {
// 	return this.chkCoordinateCorrection.get('checked');
// }

// imagej.prototype.setCorrection=function(value)
// {
// 	this.chkCoordinateCorrection.set('checked',value);
// }
imagej.prototype.getRemoveBlacksParams=function()
{
	var param={'value':this.chkremoveblacks.get('checked'),
			'template':this.ListMacrosBlack.getValue()
			};
	return param;
}

imagej.prototype.setRemoveBlacksParams=function(value,template)
{
	var value=eval(value);
	if(value)
	{
		var existe=this.ListMacrosBlack.setValue(template);
		if(existe)
		{
			this.chkremoveblacks.set('checked',true);
		}
		return existe;
	}
}


imagej.prototype.getParametersDefaultImage=function()
{
	var param={'thresholdmin':0,'thresholdmax':100,'size':1000,'maxsize':'Infinity','circularity':'0.0'};
	return param;
}

imagej.prototype.getAdvanceOptions=function()
{
	
	if(!document.getElementById("thresholdmin"))
	{
		return this.getParametersDefaultImage();
	}
	return {'thresholdmin':document.getElementById("thresholdmin").value
			,'thresholdmax':document.getElementById("thresholdmax").value
			,'size':document.getElementById("size").value
			,'maxsize':document.getElementById("maxsize").value
			,'circularity':document.getElementById("circularity").value};

}

imagej.prototype.setAdvanceOptions=function(thresholdmin,thresholdmax,size,maxsize,circularity)
{
	
	var slide=0;
	var chamber=0;
	this.currentOptionsImagen[slide][chamber]={'thresholdmin':thresholdmin,
											 'thresholdmax':thresholdmax,
											 'size':size,
											 'maxsize':maxsize,
											 'circularity':circularity
											};
											



}



imagej.prototype.create_window=function(macrosDetect,templates)
{
	var label=document.createElement('label');
	label.innerHTML=this.name;

	this.imagej.getHead().appendChild(label);

	this.imagej.getBody().appendChild(this.CreateListMacroDetect(macrosDetect));

	var p=document.createElement('p');
	var divautocomplete=document.createElement('div');
	divautocomplete.className="autocomplete";
	divautocomplete.setAttribute('id','myAutoCompleteStep2');

	var label=document.createElement('label');
	label.innerHTML=imrc_labels['imagej']['label2'];
	divautocomplete.appendChild(label);

	var input=document.createElement('input');
	input.setAttribute('id',"step2");
	input.setAttribute('name',"step2");
	input.setAttribute('type',"text");
	divautocomplete.appendChild(input);

	var div=document.createElement('div');
	div.setAttribute("id",'myContainerACStep2');
	div.className="ContainerAutoComplete";
	divautocomplete.appendChild(div);
	p.appendChild(divautocomplete);
	this.imagej.getBody().appendChild(p);


	this.imagej.getBody().appendChild(this.CreateListMacroBlack(this.MyMicro.conf.getMacros('Blacks')));



	var p=document.createElement('p');


	// this.chkCoordinateCorrection = new YAHOO.widget.Button({
	//                             type: "checkbox",
	//                             label: imrc_labels['imagej']['button2']['off'],
	//                             value: "1",
	//                             container: p,
	//                             checked: false });
	// 
	// this.chkCoordinateCorrection.subscribe("checkedChange",function(event)
	// 														{
	// 															if(event.newValue)
	// 															{
	// 																this.set('label',imrc_labels['imagej']['button2']['on']);
	// 															}
	// 															else
	// 															{
	// 																this.set('label',imrc_labels['imagej']['button2']['off']);
	// 															}
	// 
	// 														});
	// 
	// 
	// this.imagej.getBody().appendChild(p);


	var input=document.createElement('input');
	input.setAttribute('type','button');
	input.setAttribute('id','AdvanceOptions');
	input.setAttribute('name','AdvanceOptions');
	input.setAttribute('value',imrc_labels['imagej']['button3']);
	this.imagej.getFooter().appendChild(input);
	this.AdvanceOptionsbtn=new YAHOO.widget.Button("AdvanceOptions");
	YAHOO.util.Event.addListener(document.getElementById("AdvanceOptions"),"click",this.showPanelOptions,this);


	var input=document.createElement('input');
	input.setAttribute('type','button');
	input.setAttribute('id','searchcreate');
	input.setAttribute('name','searchcreate');
	input.setAttribute('value',imrc_labels['imagej']['button4']);
	this.imagej.getFooter().appendChild(input);

	this.searchcreatebtn=new YAHOO.widget.Button("searchcreate");
	YAHOO.util.Event.addListener(document.getElementById('searchcreate'),"click",this.run,this);

	var input=document.createElement('input');
	input.setAttribute('type','button');
	input.setAttribute('id','ViewDetectImageJ');
	input.setAttribute('name','ViewDetectImageJ');
	input.setAttribute('value',imrc_labels['imagej']['button5']);
	this.imagej.getFooter().appendChild(input);
	this.ViewDetectImageJBtn=new YAHOO.widget.Button("ViewDetectImageJ");
	YAHOO.util.Event.addListener(document.getElementById("ViewDetectImageJ"),"click",this.ViewDetectImageJ,this);

	var input=document.createElement('input');
	input.setAttribute('type','button');
	input.setAttribute('id','ChangeImage');
	input.setAttribute('name','ChangeImage');
	input.setAttribute('value',imrc_labels['imagej']['button6']);
	this.imagej.getFooter().appendChild(input);
	this.ChangeImagebtn=new YAHOO.widget.Button("ChangeImage");
	YAHOO.util.Event.addListener(document.getElementById("ChangeImage"),"click",this.showPanelChangeImage,this);

	this.oAC=new autoCompleteConfocal(templates,"step2","myContainerACStep2");

	this.oAC.onChangeEvent.subscribe(function(event,args,me){me.onChangeTemplateStep2Event.fire(args);},this);

}
imagej.prototype.onRemoveBlacks=function(event,me)
{
	if(event.newValue)
	{
		this.set('label',imrc_labels['imagej']['button1']['on']);
		me.ListMacrosBlack.enabled();
		me.onRemoveBlacksEvent.fire(true);
	}
	else
	{
		this.set('label',imrc_labels['imagej']['button']['off']);
		me.ListMacrosBlack.disabled();
		me.onRemoveBlacksEvent.fire(false);
	}
}


imagej.prototype.updateParamatersOptionsImage=function(slide,chamber)
{
	if( typeof(document.getElementById("maxsize").value)=='string' && isNaN(document.getElementById("maxsize").value))
	{
		this.currentOptionsImagen[slide][chamber]={'thresholdmin':document.getElementById("thresholdmin").value,
												 'thresholdmax':document.getElementById("thresholdmax").value,
												 'size':document.getElementById("size").value,
												 'maxsize':'document.getElementById("maxsize").value',
												 'circularity':document.getElementById("circularity").value
												};
		return;
	}
	this.currentOptionsImagen[slide][chamber]={'thresholdmin':document.getElementById("thresholdmin").value,
											 'thresholdmax':document.getElementById("thresholdmax").value,
											 'size':document.getElementById("size").value,
											 'maxsize':document.getElementById("maxsize").value,
											 'circularity':document.getElementById("circularity").value
											};
	return;
}
imagej.prototype.setParamatersOptionsImage=function(slide,chamber)
{
	if(!this.panelOptiones)
	{
		this.panelOptiones = new YAHOO.widget.Panel("panelOptiones", { width:"320px", visible:false, zindex:5,modal:true,draggable:true, close:true,fixedcenter:true} );
		this.panelOptiones.setHeader(imrc_labels['imagej']['advanced']['title']);
		this.setParamatersOptionsImage(0,0);
		this.panelOptiones.setFooter("<button id='btnPanelOptionesRefresh'>"+imrc_labels['imagej']['advanced']['button2']+"</button>");
		this.panelOptiones.render(document.body);
		this.btnPanelOptionesRefresh=new YAHOO.widget.Button("btnPanelOptionesRefresh");
		YAHOO.util.Event.addListener(document.getElementById("btnPanelOptionesRefresh"),"click",this.refresh,this);
	}
	if(!slide)
	{
		slide=0;
	}
	if(!chamber)
	{
		chamber=0;
	}
	
	var bodyOptionsImage="<div><p>"+imrc_labels['imagej']['advanced']['label1']+"<input type ='text' size=3 id='thresholdmin' name='thresholdmin' value='"+this.currentOptionsImagen[slide][chamber].thresholdmin+"'> - ";
	bodyOptionsImage+="<input  type ='text' size=3 id='thresholdmax' name='thresholdmax' value='"+this.currentOptionsImagen[slide][chamber].thresholdmax+"'></p><br>";
	bodyOptionsImage+="<p>"+imrc_labels['imagej']['advanced']['label2']+"<input type ='text' size=6  id='size' name='size' value='"+this.currentOptionsImagen[slide][chamber].size+"'>-";
	bodyOptionsImage+="<input type ='text' size=6  id='maxsize' name='maxsize' value='"+this.currentOptionsImagen[slide][chamber].maxsize+"'></p><br>";
	bodyOptionsImage+="<p>"+imrc_labels['imagej']['advanced']['label3']+"<input  type ='text' size=3 id='circularity' name='circularity' value='"+this.currentOptionsImagen[slide][chamber].circularity+"'></p></div>";
	this.panelOptiones.setBody(bodyOptionsImage);
	return bodyOptionsImage;
}
imagej.prototype.panelChangeImageOk=function(event,me)
{
	var regexp=/Slide--S(\d+)/i;
	me.currentSlide=parseInt(me.SelectChangeImage.value.match(regexp)[1]);
	regexp=/Chamber--U(\d+)--V00/i;
	me.currentChamber=parseInt(me.SelectChangeImage.value.match(regexp)[1]);
	me.panelChangeImage.hide();
}
imagej.prototype.enabledAllButtons=function()
{
	this.ViewDetectImageJBtn.set('disabled',false);
	this.searchcreatebtn.set('disabled',false);
	this.AdvanceOptionsbtn.set('disabled',false);
	// document.getElementById('chkremoveblacks').removeAttribute('disabled');
}
imagej.prototype.disabledAllButtons=function()
{
	this.ViewDetectImageJBtn.set('disabled',true);
	this.searchcreatebtn.set('disabled',true);
	this.AdvanceOptionsbtn.set('disabled',true);
	// document.getElementById('chkremoveblacks').setAttribute('disabled',true);
}

imagej.prototype.showPanelChangeImage=function(event,me)
{
	if(me.isRun)
	{
		if(!me.panelChangeImage)
		{
			me.panelChangeImage = new YAHOO.widget.Panel("panelChangeImage", { width:"500px", visible:false, zindex:5,modal:true,draggable:true, close:true,fixedcenter:true} );
			me.panelChangeImage.setHeader("Change Image");
			me.panelChangeImage.setBody(me.SelectChangeImage);
			me.panelChangeImage.setFooter("<button id='btnpanelChangeImageOk'>Ok</button>");
			me.panelChangeImage.render(document.body);
			me.btnpanelChangeImageOk=new YAHOO.widget.Button("btnpanelChangeImageOk");
			YAHOO.util.Event.addListener(document.getElementById("btnpanelChangeImageOk"),"click",me.panelChangeImageOk,me);
		}
		me.panelChangeImage.show();
	}
	else
	{
		new dialog_alert("Notice",'','notice',"IMAGEJ_CHECK_RUN");
		
	}
}
imagej.prototype.showPanelOptions=function(event,me)
{
	me.setParamatersOptionsImage(me.currentSlide,me.currentChamber);
	me.panelOptiones.show();
	me.btnPanelOptionesRefresh.set("label",imrc_labels['imagej']['advanced']['button1']);
}
imagej.prototype.refresh=function(event,me)
{
	me.updateParamatersOptionsImage(me.currentSlide,me.currentChamber);
	if(me.btnPanelOptionesRefresh.get("label")=='ok')
	{
		me.panelOptiones.hide();
	}
	else
	{
		me.run('refresh',me);
	}
}

imagej.prototype.viewResul=function(image)
{
	this.PanelViewImageJ.setBody("<img src='"+image+"' width='600' />");
}


imagej.prototype.ViewImage=function(response)
{
	if(!this.PanelViewImageJ)
	{
		this.PanelViewImageJ =
				new YAHOO.widget.Panel("PanelViewImageJ",
					{ width:"600px",
					  height:"500px",
					  fixedcenter:true,
					  constraintoviewport:true,
					  close:true,
					  draggable:true,
					  zindex:4,
					  modal:true,
					  visible:false
					}
				);
		this.PanelViewImageJ.setHeader("ImageJ Result ");
	}
	if(response != "")
	{
		this.PanelViewImageJ.setBody("<img width='600px' src='"+response+"'/>");
		this.PanelViewImageJ.setFooter("<button id='btnPanelOptiones'>Show Advanced Options</button>");
	}
	else
	{
		this.PanelViewImageJ.setBody("<p>No Existe La Imagen Seleccionada</p>");
	}
	this.PanelViewImageJ.render(document.body);
	if(response != "")
	{
		YAHOO.util.Event.addListener("btnPanelOptiones", "click", this.panelOptiones.show, this.panelOptiones, true);
		this.btnPanelOptionesRefresh.set("label",imrc_labels['imagej']['advanced']['button2']);
	}

	this.PanelViewImageJ.show();
}


imagej.prototype.ViewDetectImageJ=function(event,me)
{
	var callback = {
	  success: function(o) {
								myLogWriter.log(o.responseText, "info");
								me.ViewImage(o.responseText);
								if(event == "refresh")
								{
									me.panelOptiones.hide();
								}


								me.MyMicro.conf.progressbar.hide();

							},
	  failure: function(o) {myLogWriter.log(o.status+":"+o.statusText, "info");me.MyMicro.conf.progressbar.hide();}
	};

	if(me.isRun)
	{
		var url='cgi-bin/coordenates.cgi?conf='+document.getElementById("micro").value;
		url+="&dir="+me.MyMicro.getSelectExperiment()+"&image="+me.SelectChangeImage.value;
		url+="&rotate="+me.rotate;
		var cObj = YAHOO.util.Connect.asyncRequest('GET', url, callback);
		me.MyMicro.conf.progressbar.show();
	}
	else
	{
		new dialog_alert("Notice",'','notice',"IMAGEJ_CHECK_RUN");
		
	}
}
imagej.prototype.check_url=function()
{

	if(!this.panelOptiones)
	{
		this.setParamatersOptionsImage();
	}
	var dirImages=this.MyMicro.getSelectExperiment();
	var template_step1=document.getElementById("step1").value;
	var template_step2=document.getElementById("step2").value;
	if(template_step1 =='')
	{
		var dialog=new dialog_alert("Error",'','error','IMAGEJ_MISS_TEM1');	
		this.onErrorEvent.fire('Error:'+dialog.code2text('IMAGEJ_MISS_TEM1'));
		return -1;
	}
	if(template_step2 =='')
	{
		var dialog=new dialog_alert("Error",'','error','IMAGEJ_MISS_TEM2');	
		this.onErrorEvent.fire('Error:'+dialog.code2text('IMAGEJ_MISS_TEM2'));
		return -1;
	}
	if(dirImages =='' || dirImages==undefined)
	{
		var dialog=new dialog_alert("Error",'','error','IMAGEJ_STIT_CHECK');
		this.onErrorEvent.fire('Error:'+dialog.code2text('IMAGEJ_STIT_CHECK'));
		return -1;
	}
	if(this.ListMacrosDetect.getValue() == undefined)
	{
		var dialog=new dialog_alert("Error",'','error','IMAGEJ_MISS_DET_MACRO');
		this.onErrorEvent.fire('Error:'+dialog.code2text('IMAGEJ_MISS_DET_MACRO'));
		return -1;
	}

	if(this.chkremoveblacks.get('checked') && this.ListMacrosBlack.getValue() == undefined)
	{
		var dialog=new dialog_alert("Error",'','error','IMAGEJ_MISS_BLACK_MACRO');
		this.onErrorEvent.fire('Error:'+dialog.code2text('IMAGEJ_MISS_BLACK_MACRO'));
		return -1;
	}

	var url='cgi-bin/LeicaConfocal.cgi?action=create&step=imagej&black='+this.chkremoveblacks.get('checked');
	url+='&template_step1='+template_step1;

	// url+='&coor='+this.chkCoordinateCorrection.get("checked");

	url+='&template_step2='+template_step2;
	url+="&name="+document.getElementById("micro").value;
	url+="&dir="+dirImages;
	url+="&thresholdMin="+document.getElementById("thresholdmin").value;
	url+="&thresholdMax="+document.getElementById("thresholdmax").value;
	url+="&size="+document.getElementById("size").value;
	url+="&maxsize="+document.getElementById("maxsize").value;
	url+="&circularity="+document.getElementById("circularity").value;
	if(this.chkremoveblacks.get('checked'))
	{
		url+="&macro_blacks=blacks/"+this.ListMacrosBlack.getValue();
	}
	url+="&macro_detect=detect/"+this.ListMacrosDetect.getValue();

	return url;
}
imagej.prototype.run=function(event,me)
{
	var url=me.check_url()
	var MicroStatusObj=null;
	if(url!=-1)
	{

		var callback = {
		  success: function(o) {
									myLogWriter.log(o.responseText, "info");
									// me.MyMicro.conf.progressbar.hide();
									MicroStatusObj.hide();
									if(event == "refresh")
									{
										me.ViewDetectImageJ('refresh',me);
									}
									else
									{
										me.isRun=true;
										var response=eval(o.responseText);
										var schemas="";
										var schemasErr="";
										me.SelectChangeImage.innerHTML=""
										var templates=new Array();
										var itemplates=0;


										for(var i=0;i<response.length;i++)
										{
											if(response[i].ERROR==0)
											{
												me.rotate=response[i].rotate;
												me.currentOptionsImagen[parseInt(response[i].slide)][parseInt(response[i].chamber)]=me.getParametersDefaultImage();
												var option=document.createElement("option");
												
												var basename=response[i].img.split('/');
												option.innerHTML=basename[basename.length-1];
												option.setAttribute('value',response[i].img);
												me.SelectChangeImage.appendChild(option);
												schemas+="<li>"+response[i].MSG+"</li>";
												templates[itemplates]=response[i].MSG;
												itemplates++;
											}
											else
											{
												schemas="-1";
												schemasErr+="<li>"+response[i].MSG+"</li>";
											}
										}
										var results;
										if(schemas != '')
										{
											if(schemasErr == '')
											{
												results="<p><b>Load:</b><ul>"+schemas+"</ul></p>";

											}
											else
											{
												results="<p><b>Load:</b><ul>"+schemas+"</ul></p><p><b>ERROR:</b><ul>"+schemasErr+"</ul></P>";
											}
											new dialog_alert("Info",'','info','IMAGEJ_FINISH',null,results);
																						
										}
										else
										{
											new dialog_alert("Error",'','error','IMAGEJ_UNEXPECTED');
										}

										me.onFinishedEvent.fire(templates,document.getElementById("step2").value);
									}
								},
		  failure: function(o) {
									myLogWriter.log(o.status+":"+o.statusText+":"+o.responseText, "info");
									me.lockEvent.fire();
									me.disabledAllButtons();
									MicroStatusObj.hide();
									// me.MyMicro.conf.progressbar.hide();
									new dialog_alert("Error",'','error','IMAGEJ_UNEXPECTED',null,o.responseText);
								}
		};


		MicroStatusObj=new MicroStatus(cObj,me.MyMicro.getCurrentMicro(),me.manager);
		var cObj = YAHOO.util.Connect.asyncRequest('GET', url, callback);
		
		// if(event != 'RUNAllProcess')
		// {
			// me.MyMicro.conf.progressbar.show();
		// }
	}
}

imagej.prototype.getParams=function()
{
	// <detection>
	// 	<tempalte file="Cytoolow63X" />
	// 	<routine template="" macro="TMAdetection2.ijm">
	// 		<threshold min="100" max="255" />
	// 		<size min="15" max="45" />
	// 		<circulary value="0.0" />
	// 	</routine>
	// </detection>
	// var params_array=new Array();
	// var params={'template':'','routine':{'macro':'','threshold':{'max':0,'min':0},'size':{'max':0,'min':0},'circulary':0.0}};

	// alert(this.currentOptionsImagen[slide][chamber]);


	// for(var islide=0;islide<this.currentOptionsImagen.length;islide++)
	// {
	// 	for(var ichamber=0;ichamber<this.currentOptionsImagen[islide].length;ichamber++)
	// 	{
	// 		var params={'template':'','routine':{'macro':'','threshold':{'max':0,'min':0},'size':{'max':0,'min':0},'circulary':0.0}};
	// 		params.template=document.getElementById('step2').value;
	// 		params.routine.macro=document.getElementById("selectmacro_detect").value;
	//
	// 		params.routine.threshold.max=document.getElementById("thresholdmax").value;
	// 		params.routine.threshold.min=document.getElementById("thresholdmin").value;
	//
	// 		params.routine.size.max=document.getElementById("maxsize").value;
	// 		params.routine.size.min=document.getElementById("size").value;
	//
	// 		params.routine.circulary=document.getElementById("circularity").value;
	// 	}
	// }
	//
	//
	//

	return params;
}
