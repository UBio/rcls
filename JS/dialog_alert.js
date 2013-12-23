dialog_alert=function(head,msg,type)
{
	var icon;
	if(type=='help')
	{
		icon=YAHOO.widget.SimpleDialog.ICON_HELP;
	}
	if(type=='notice')
	{
		icon=YAHOO.widget.SimpleDialog.ICON_WARN;
	}
	if(type=='error')
	{
		icon=YAHOO.widget.SimpleDialog.ICON_ALARM;
	}
	var id="dialogFinish"+Math.floor(Math.random()*1000000+1);
	
	var dialogFinish = new YAHOO.widget.SimpleDialog(id, 
														 { width: "450px",
														   fixedcenter: true,
														   visible: false,
														   draggable: false,
														   close: true,
														   text: msg,
														   icon: icon,
														   constraintoviewport: true,
														   zIndex:999,
														   modal:true,
														   buttons: [ { text:"Ok", handler:function(){this.destroy();}, isDefault:true }]
														 } );
	dialogFinish.setHeader(head);						
	dialogFinish.render(document.body);
	dialogFinish.show();
}