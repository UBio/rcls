// dialog_alert=function(head,msg,type)
// {
// 	var icon;
// 	if(type=='help')
// 	{
// 		icon=YAHOO.widget.SimpleDialog.ICON_HELP;
// 	}
// 	if(type=='notice')
// 	{
// 		icon=YAHOO.widget.SimpleDialog.ICON_WARN;
// 	}
// 	if(type=='error')
// 	{
// 		icon=YAHOO.widget.SimpleDialog.ICON_ALARM;
// 	}
// 	var id="dialogFinish"+Math.floor(Math.random()*1000000+1);
// 	
// 	var dialogFinish = new YAHOO.widget.SimpleDialog(id, 
// 														 { width: "450px",
// 														   fixedcenter: true,
// 														   visible: false,
// 														   draggable: false,
// 														   close: true,
// 														   text: msg,
// 														   icon: icon,
// 														   constraintoviewport: true,
// 														   zIndex:999,
// 														   modal:true,
// 														   buttons: [ { text:"Ok", handler:function(){this.destroy();}, isDefault:true }]
// 														 } );
// 	dialogFinish.setHeader(head);						
// 	dialogFinish.render(document.body);
// 	dialogFinish.show();
// }

dialog_alert=function(head,msg,type,num_error,context,more_info)
{

	errors=new Array();
	errors['LOAD_EXP_DIR']="El experimento no existe, es un esperimento nuevo?";
	errors['LOAD_EXP_RM_BLACK']="this code color not exits";
	errors['LOAD_EXP_STITCH']="Routine stitching not exits";
	errors['LOAD_EXP_HIGH']="high template not exits";
	errors['LOAD_EXP_DETECTIOM']="routine detection not exists";
	errors['LOAD_EXP_LOW']="low template not exits";
	errors['LOAD_EXP_MICRO']="micro not exists";
	errors['LOAD_EXP_MISS']="Missing Experiment File";
	

	var error_msg="Unknow error";
	
	if(msg!='')
	{
		error_msg=msg;
	}
	else
	{
		if(num_error != '')
		{
			if( typeof(num_error)=='string')
			{
				if(errors[num_error])
				{
					error_msg=errors[num_error];
				}
				else
				{
					error_msg=num_error;
				}
			}
			else
			{
				error_msg='<ul>';
				for(var i=0;i<num_error.length;i++)
				{
					error_msg+='<li>'+errors[num_error[i]]+'</li>';
				}
				error_msg+='</ul>';
			}
		}
	}
	var id="error_dialog"+"_"+Math.floor(Math.random()*1000000);
	if(type != 'tooltip')
	{
		var error_win= new YAHOO.widget.SimpleDialog(id, 
				 { width: "300px",
				   fixedcenter: true,
				   visible: false,
				   draggable: false,
				   close: false,
					modal:true,
				   text: error_msg,
				   icon: YAHOO.widget.SimpleDialog.ICON_WARN,
				   constraintoviewport: true,
				 });
		error_win.setHeader("Error");
		if(type != 'forbidden')
		{
			error_win.cfg.queueProperty("buttons", [ { text:"Close", handler:function(){this.hide();this.destroy();}, isDefault:true }]);
		}
		
		if(type == 'warning')
		{
			this.clickYES=new YAHOO.util.CustomEvent("clickYES",null);
			var clickYES=this.clickYES;
			error_win.setHeader("Are you sure?");
			error_win.cfg.queueProperty("buttons", [ { text:"Yes", handler:function(){clickYES.fire();this.hide();this.destroy();}},
													{ text:"No", handler:function(){this.hide();this.destroy();}, isDefault:true }
													]);
		}

		if(type == 'info' || type=='help' || type=='notice')
		{
			this.clickYES=new YAHOO.util.CustomEvent("clickYES",null);
			var clickYES=this.clickYES;
			error_win.setHeader("Info");
			error_win.cfg.queueProperty("buttons", [ { text:"Ok", handler:function(){clickYES.fire();this.hide();this.destroy();}}
													]);
		}
	
	


		error_win.render(document.body);
		document.getElementById(id).getElementsByTagName('span')[0].className="ace-icon-error";
		if(type == 'warning')
		{
			document.getElementById(id).getElementsByTagName('span')[0].className="ace-icon-warning";
		}
		if(type == 'info' || type=='help' || type=='notice')
		{
			document.getElementById(id).getElementsByTagName('span')[0].className="ace-icon-info";
		}
		error_win.show();
		
		document.getElementById(error_win.id).parentNode.style.zIndex=10000;
		
	}
	else
	{
		// if(document.getElementById('myTooltip1'))
		// {
		// 	document.getElementById('myTooltip1').parentNode.removeChild(document.getElementById('myTooltip1'));
		// }
		var myTooltip = new YAHOO.widget.Tooltip("myTooltip1", { 
		    context:context, 
		    text: error_msg+": "+more_info,
		    showDelay: 500
		});
		// myTooltip1.focus();
		// myTooltip1.show();
	}
	
}
