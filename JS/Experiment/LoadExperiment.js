LoadExperiment=function(manager,micro,lowObj,detectionObj,highObj,stitching)
{
	this.MyMicro=micro;
	this.lowObj=lowObj;
	this.detectionObj=detectionObj;
	this.highObj=highObj;
	this.stitchingObj=stitching;
	
	this.form_load_experiment;
	
	
	this.cancel_btn;	
	this.load_btn;
	
	this.options={
						expand:false,
						width:"350px",
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
		label.innerHTML="Load ....";
		_setTitleDialogApp(label);
	}
	// 
	this.setContentDialogApp=function()
	{		
		this.form_load_experiment=this.getContent();
		_setContentdialogApp(this.form_load_experiment);
	}
	
	this.setButtonsDialogApp=function()
	{
		_setButtonsDialogApp(this.getButtons());
		// 
		
		new YAHOO.widget.Button(this.cancel_btn).on('click',this.cancel);
		// //  
		new YAHOO.widget.Button(this.load_btn).on('click',this.load,this);
	}
	
	this.setTitleDialogApp();
	
	this.setContentDialogApp();
	
	this.setButtonsDialogApp();
	
};
LoadExperiment.prototype.getContent=function()
{
	
	var  form=document.createElement('form');
	form.setAttribute('method','post');
	form.setAttribute('enctype','multipart/form-data');
	
	var p=document.createElement('p');
	
	var label=document.createElement('label');
	label.innerHTML="Select Experiment File:";
	this.inputFile=document.createElement('input');
	this.inputFile.setAttribute('name','loadExperiment');
	this.inputFile.setAttribute('type','file');

	
	
	p.appendChild(label);
	p.appendChild(this.inputFile);
	form.appendChild(p);



	return form;

}


LoadExperiment.prototype.getButtons=function()
{
	var p=document.createElement('p');
	p.className="buttons";
	this.cancel_btn=document.createElement('input');
	this.cancel_btn.setAttribute('type','button');
	this.cancel_btn.setAttribute('value','Cancel');
	p.appendChild(this.cancel_btn);

	this.load_btn=document.createElement('input');
	this.load_btn.setAttribute('type','button');
	this.load_btn.setAttribute('value','Load');
	p.appendChild(this.load_btn);	
	
	return p;
}

LoadExperiment.prototype.load=function(event,me)
{
	if(me.inputFile.value == '')
	{
		new dialog_alert("Notice","Missing Experiment File",'notice');				
		return;
	}
	
	
	var callback = {
		   
		  upload: function(o) {
									myLogWriter.log(o.responseText, "info");
									me.MyMicro.conf.progressbar.hide();
									me.hide();
									me.setExperiment(o.responseXML);
									
									new dialog_alert("Notice",'Finished','notice');
								},
		  success:function(o){
									me.MyMicro.conf.progressbar.hide();
								},
		  failure: function(o) {
									myLogWriter.log(o.status+":"+o.statusText+":"+o.responseText, "info");
									me.MyMicro.conf.progressbar.hide();
									new dialog_alert("Notice",o.responseText,'notice');								
								}
		};
	
	
	var url='cgi-bin/Experiment/load.cgi';
	
	YAHOO.util.Connect.setForm(me.form_load_experiment,true);
	var cObj = YAHOO.util.Connect.asyncRequest('POST', url, callback);
	me.MyMicro.conf.progressbar.show();

}
// <?xml version="1.0" encoding="UTF-8" ?>, referer: http://localhost/~acarro/Confocal/
// <mscr>
// 	<microscope name="white" experiment="experiment--2013_08_09_18_05"/>
// 	<low template="CathyDBM222Low"/>
// 	<detection routine_name="CellDet-CM-MANUAL.ijm" template="CathyDBM237High" correction="true">
// 		<remove_blacks value="true"/>
// 		<advanced_options>
// 			<threshold min="10" max="150"/>
// 			<size min="100" max="1000"/>
// 			<circularity circularity="1.0"/>
// 		</advanced_options>
// 	</detection>
// 	<high all="true"/>
// 	<stitching code_color="BG" routine_name="Rotar90derechaStitching.ijm"/>
// </mscr>

LoadExperiment.prototype.setExperiment=function(xmlDocument)
{
	var existsMicro=this.MyMicro.setCurrentMicro(xmlDocument.getElementsByTagName('microscope')[0].getAttribute("name"));
	
	if(existsMicro)
	{
		var existsExperiment=this.MyMicro.setSelectExperiment(xmlDocument.getElementsByTagName('microscope')[0].getAttribute("experiment"));
		if(existsExperiment)
		{
			var existsTemplateLow=this.lowObj.setTemplate(xmlDocument.getElementsByTagName('low')[0].getAttribute("template"));
			if(existsTemplateLow)
			{
				var existsDetectionRoutine=this.detectionObj.setRoutine(xmlDocument.getElementsByTagName('detection')[0].getAttribute("routine_name"));
				if(existsDetectionRoutine)
				{
					var existsTemplateHight=this.detectionObj.setTemplate(xmlDocument.getElementsByTagName('detection')[0].getAttribute("template"));
					if(existsTemplateHight)
					{
						var existsTemplateRemoveBlacks=this.detectionObj.setRemoveBlacksParams(
														eval(xmlDocument.getElementsByTagName('remove_blacks')[0].getAttribute("value")),
														xmlDocument.getElementsByTagName('remove_blacks')[0].getAttribute("template")
														);
						// if(existsTemplateRemoveBlacks)
						// {
							this.detectionObj.setCorrection(eval(xmlDocument.getElementsByTagName('detection')[0].getAttribute("correction")));
							this.detectionObj.setAdvanceOptions(
								xmlDocument.getElementsByTagName('threshold')[0].getAttribute("min"),
								xmlDocument.getElementsByTagName('threshold')[0].getAttribute("max"),
								xmlDocument.getElementsByTagName('size')[0].getAttribute("min"),
								xmlDocument.getElementsByTagName('size')[0].getAttribute("max"),
								xmlDocument.getElementsByTagName('circularity')[0].getAttribute("circularity")					
							);
							this.highObj.setScanAllTempates(eval(xmlDocument.getElementsByTagName('high')[0].getAttribute("all")));
							
							var existsStitchingRoutine=this.stitchingObj.setRoutine(xmlDocument.getElementsByTagName('stitching')[0].getAttribute("routine_name"));
							if(existsStitchingRoutine)
							{
								var existsCodeColor=this.stitchingObj.setCodeColor(xmlDocument.getElementsByTagName('stitching')[0].getAttribute("code_color"));
								if(!existsCodeColor)
								{
									alert('this code color not exits');
								}
							}
							else
							{
								alert('Routine stitching not exits');
							}
						// }
						
					}
					else
					{
						alert('Remove Blacks template not exits');
						
					}
				}
				else
				{
					alert('routine detection not exists');
				}
			}
			else
			{
				alert('low template not exits');
			}
		}
		else
		{
			
			alert('experiment not exists');
		}
	}
	else
	{
		alert('micro not exists');
	}
}