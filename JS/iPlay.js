iPlay=function(container,workflow)
{
	this.control=document.getElementById(container);
	this.playAll;
	this.currentStep=0;
	this.workflow=workflow;
	this.ProgressBar;
	

	this.create_control(container);
	
	this.onStartAllProcessEvent=new YAHOO.util.CustomEvent("onStartAllProcess",null);
	this.onEndAllProcessEvent=new YAHOO.util.CustomEvent("onEndAllProcess",null);
	// this.onNextProcessEvent=new YAHOO.util.CustomEvent("onNextProcess",null);
	
}
// onFinisheEvent
iPlay.prototype.create_ProgressBarWindow=function()
{
	var optionWindow={
						expand:false,
						width:"350px",
						isExpanded:false,
						close:false,
						modal:true,
						center:true,
						visible:false
					};
					
	this.ProgressBarWindow=new itemWindow('iPlayProgressBar',document.body,null,optionWindow);
	
	var labelHead=document.createElement('label');
	labelHead.innerHTML="Processing ...";
	this.ProgressBarWindow.getHead().appendChild(labelHead);
	
	
	var divProgressBar=document.createElement('div');
	divProgressBar.className="progressBar";
	this.control.appendChild(divProgressBar);
	this.ProgressBarWindow.getBody().appendChild(divProgressBar);
	
	 

	
	
	this.labelCurrentStep=document.createElement('label');
	this.labelCurrentStep.innerHTML="Current Step Name";
	this.labelCurrentStep.className="currentStep";
	this.ProgressBarWindow.getFooter().appendChild(this.labelCurrentStep);
	
	
	var div=document.createElement('div');
	div.setAttribute('class',"buttonsProgressBar");
	
	var buttonClose=document.createElement('input');
	buttonClose.setAttribute('type','button');
	buttonClose.setAttribute('value','Close');
	div.appendChild(buttonClose);
	
	this.ProgressBarWindow.getFooter().appendChild(div);
	
	this.closeProgressBarWindow=new YAHOO.widget.Button(buttonClose); 
	
	this.closeProgressBarWindow.on("click", function(event,args){args.ProgressBarWindow.hide();},this); 
	this.closeProgressBarWindow.set('disabled',true);
	
	
	
	this.ProgressBar=new YAHOO.widget.ProgressBar({value:0,minValue:0,maxValue:this.workflow.length}).render(divProgressBar);
	
	this.ProgressBar.set('width','330px');
	
}

iPlay.prototype.create_control=function(container)
{

	
	this.create_ProgressBarWindow();
	
	this.control.className="control_process";
	
	this.playAll=document.createElement('div');
	
	
	var label=document.createElement('label');
	label.className='button';
	
	label.innerHTML="Play";
	this.playAll.appendChild(label);
	
	this.control.appendChild(this.playAll);
	

	
	YAHOO.util.Event.addListener(this.playAll,"click",this.run_all_process,this);
	// me.ProgressBar.set('value',me.workflow.length);
}

iPlay.prototype.run_all_process=function(event,me)
{
	if(me.currentStep<me.workflow.length)
	{
		if(me.workflow[me.currentStep].running)
		{
			me.labelCurrentStep.innerHTML=me.workflow[me.currentStep].name;
		}
		
		if(me.currentStep==0)
		{
			me.ProgressBarWindow.show();
			me.onStartAllProcessEvent.fire();
		}
		else
		{
			me.ProgressBar.set('value',me.currentStep);
		}
		if(me.workflow[me.currentStep].running)
		{
			var error=me.workflow[me.currentStep].run('RUNAllProcess',me.workflow[me.currentStep]);
			me.workflow[me.currentStep].onFinishedEvent.subscribe(function(event,args,me)
																		{
																			me.currentStep++;
																			me.run_all_process('next',me);
																			},me);													
			// }
			// else
			// {
			// 	me.ProgressBarWindow.hide();
			// }																
		}
		else
		{
			me.currentStep++;
			me.run_all_process('next',me);																
		}
	}
	else
	{
		me.closeProgressBarWindow.set('disabled',false);
		me.labelCurrentStep.innerHTML="Finished";
		me.ProgressBar.set('value',me.workflow.length);
		me.currentStep=0;
		me.onEndAllProcessEvent.fire();
	}
}