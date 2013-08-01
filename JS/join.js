join=function(container,manager,MyMicro)
{
	this.name="Join Templates";
	this.totalFiles=new Array();
	
	this.MyMicro=MyMicro;
	
	this.divInputsFiles;
	
	var optionWindow={
						expand:false,
						width:"400px",
						isExpanded:false,
						close:true,
						modal:true,
						center:true,
						visible:false
					};
	
	this.win_join=new itemWindow("joinTemplates",container,manager,optionWindow);
	
	this.create_window(MyMicro.conf.getTemplates());
	
}
join.prototype.addTemplates=function(select,templates)
{
	select.innerHTML="";	
	for(var i=0;i<templates.length;i++)
	{
		var option=document.createElement('option');
		option.setAttribute('value',templates[i]);
		option.innerHTML=templates[i];
		select.appendChild(option);
	}
}
join.prototype.refresh=function()
{
	this.win_join.getHead().innerHTML='';
	this.win_join.getBody().innerHTML='';
	this.win_join.getFooter().innerHTML='';
	this.create_window(this.MyMicro.conf.getTemplates());
}
join.prototype.create_window=function(templates)
{
	var label=document.createElement('label');
	label.innerHTML="Join Templates";
	this.win_join.getHead().appendChild(label);
	this.divInputsFiles=document.createElement('div');

	var p=document.createElement('p');
	var select=document.createElement('select');
	select.setAttribute('id','joinTemplatesFirst');
	select.setAttribute('name','joinTemplatesFirst');

	this.addTemplates(select,templates);
	
	p.appendChild(select);
	this.divInputsFiles.appendChild(p);
	
	var p=document.createElement('p');
	var select=document.createElement('select');
	select.setAttribute('id','joinTemplatesSecond');
	select.setAttribute('name','joinTemplatesSecond');
	
	this.addTemplates(select,templates);
	
	
	p.appendChild(select);
	this.divInputsFiles.appendChild(p);
	this.win_join.getBody().appendChild(this.divInputsFiles);
	
	var input=document.createElement("input");
	input.setAttribute('type','button');
	input.setAttribute('id','moreInputJoin');
	input.setAttribute('name','moreInputJoin');
	input.setAttribute('value','More');
	this.win_join.getFooter().appendChild(input);
	
	var input=document.createElement("input");
	input.setAttribute('type','button');
	input.setAttribute('id','InputJoin');
	input.setAttribute('name','InputJoin');
	input.setAttribute('value','Join');
	this.win_join.getFooter().appendChild(input);
	
	new YAHOO.widget.Button("moreInputJoin");
	new YAHOO.widget.Button("InputJoin");
	YAHOO.util.Event.addListener(document.getElementById("moreInputJoin"),"click",this.add,this);
	YAHOO.util.Event.addListener(document.getElementById("InputJoin"),"click",this.actionjoin,this);
}
join.prototype.actionjoin=function(event,me)
{
	var TotalFileJoin=me.divInputsFiles.getElementsByTagName('select').length;
	var Templates=me.divInputsFiles.getElementsByTagName('select')[0].value;
	for(var i=1;i<TotalFileJoin;i++)
	{
		Templates+=","+me.divInputsFiles.getElementsByTagName('select')[i].value
	}
	
	
	var callback = {
	  success: function(o) {
		  						var response=eval(o.responseText); 
								myLogWriter.log(o.responseText, "info");
								
								me.MyMicro.conf.progressbar.hide();
								if(response[0].ERROR==-1)
								{
									new dialog_alert("Error",response[0].MSG,"error");									
									
								}
								else
								{
									me.win_join.hide();
									new dialog_alert("Finish",me.name,"info");									
								}					
							},
	  failure: function(o) {myLogWriter.log(o.status+":"+o.statusText, "info");me.MyMicro.conf.progressbar.hide();
	;}
	};
	
	
	var url='cgi-bin/LeicaConfocal.cgi?step=merge&name='+document.getElementById("micro").value;
	url+='&merge='+Templates;
	var cObj = YAHOO.util.Connect.asyncRequest('GET', url, callback);
	me.MyMicro.conf.progressbar.show();
}
join.prototype.deleteTemplate=function(event,me)
{
	var p=me;
	p.parentNode.removeChild(p);
}
join.prototype.join_templates=function()
{
	this.win_join.show();
}
join.prototype.add=function(event,me)
{
	me.addFile();
}
join.prototype.addFile=function()
{
	var p=document.createElement('p');
	p.className="more";
	var select=document.createElement('select');
	select.setAttribute('type','file');
	var joinTemplatesFirst=document.getElementById('joinTemplatesFirst').getElementsByTagName('option');
	for(var ioption=0;ioption<joinTemplatesFirst.length;ioption++)
	{
		var option=document.createElement('option');
		option.setAttribute('value',joinTemplatesFirst[ioption].value);
		option.innerHTML=joinTemplatesFirst[ioption].value;
		select.appendChild(option);
	}
	var img=document.createElement('img');
	img.setAttribute('src','IMG/trash.png');
	YAHOO.util.Event.addListener(img,"click",this.deleteTemplate,p);
	
	p.appendChild(select);
	p.appendChild(img);
	this.divInputsFiles.appendChild(p);
}