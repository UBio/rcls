// 'addmacro':{
// 			title:'Add macro',
// 			button1:'Save',
// 			button2:'Cancel',
// 			label1: 'Select macro file: ',
// 			select:{
// 				title:'Type of macros',
// 				options:['Objects detection','Remove Non Informative Areas','Mosaic images stitching']
// 					}
// 			
// }

UploadMacro=function(manager,MyMicro)
{
	this.ListTypeMacros;
	this.cancel_btn;
	this.upload_btn;
	this.form_add_macro;
	this.inputFile;
	this.MyMicro=MyMicro;
	
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
	DialogMacro.call(this,this.options);
	
	var _setTitleDialogMacro=this.setTitleDialogMacro;
	var _setContentdialogMacro=this.setContentDialogMacro;
	var _setButtonsDialogMacro=this.setButtonsDialogMacro;
	
	this.setTitleDialogMacro=function()
	{
		var label=document.createElement('label');
		label.innerHTML=imrc_labels['addmacro']['title'];
		_setTitleDialogMacro(label);
	}
	this.setContentDialogMacro=function()
	{	
		this.form_add_macro=this.getContent(MyMicro.conf.getTypesMacro());
		_setContentdialogMacro(this.form_add_macro);
	}
	this.setButtonsDialogMacro=function()
	{
		_setButtonsDialogMacro(this.getButtons());
		
		new YAHOO.widget.Button(this.cancel_btn).on('click',this.cancel);
	
		new YAHOO.widget.Button(this.upload_btn).on('click',this.upload,this);
	}
	
	this.setTitleDialogMacro();
	this.setContentDialogMacro();
	this.setButtonsDialogMacro();
	
}


UploadMacro.prototype.getContent=function(listTypeMacros)
{
	var  form=document.createElement('form');
	form.setAttribute('method','post');
	form.setAttribute('enctype','multipart/form-data');
		
	var p=document.createElement('p');
	console.log(imrc_labels['addmacro']['select']['options']);
	
	this.ListTypeMacros=this.createList(imrc_labels['addmacro']['select']['title'],p,imrc_labels['addmacro']['select']['options']);
	
	form.appendChild(p);
	
	
	var p=document.createElement('p');
	var label=document.createElement('label');
	label.innerHTML=imrc_labels['addmacro']['label1'];
	this.inputFile=document.createElement('input');
	this.inputFile.setAttribute('name','AddMacro');
	this.inputFile.setAttribute('type','file');

	
	p.appendChild(label);
	p.appendChild(this.inputFile);
	form.appendChild(p);

	return form;
}
// 
// 
UploadMacro.prototype.getButtons=function()
{
	var p=document.createElement('p');
	this.upload_btn=document.createElement('input');
	this.upload_btn.setAttribute('type','button');

	this.upload_btn.setAttribute('value',imrc_labels['addmacro']['button1']);
	p.appendChild(this.upload_btn);
	
	this.cancel_btn=document.createElement('input');
	this.cancel_btn.setAttribute('type','button');
	this.cancel_btn.setAttribute('value',imrc_labels['addmacro']['button2']);
	p.appendChild(this.cancel_btn);
	
	return p;
}
UploadMacro.prototype.upload=function(event, args)
{
	var me=args;

	if(me.ListTypeMacros.getValue() == undefined)
	{
		new dialog_alert("Notice","Missing Name of the Macro",'notice');				
		return;
	}
	
	if(me.inputFile.value == "")
	{
		new dialog_alert("Notice","Missing Macro",'notice');		
		return;
	}
	
	var input=document.createElement('input');
	input.setAttribute('type','hidden');
	input.setAttribute('name','typeMacro');
	input.setAttribute('value',me.ListTypeMacros.getValue());
	me.form_add_macro.appendChild(input);
	var callback = {
		   
		  upload: function(o) {
									myLogWriter.log(o.responseText, "info");
									me.MyMicro.conf.progressbar.hide();
									me.hide();
									me.fire(me.FINISH_UPLOAD);
									new dialog_alert("Notice",o.responseText,'notice');
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
	
	
	var url='admin/cgi-bin/saveMacroOrPlugging.cgi';
	
	YAHOO.util.Connect.setForm(me.form_add_macro,true);
	var cObj = YAHOO.util.Connect.asyncRequest('POST', url, callback);
	me.MyMicro.conf.progressbar.show();
}



