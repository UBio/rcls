calExperimentSelect=function(container,dirimages,listExperiments)
{
	this.container=container;

	this.ulListExperiments=document.createElement('UL');
	document.getElementById(listExperiments).appendChild(this.ulListExperiments);
	this.selectDays(dirimages);
    // this.calendar.render();
	this.selectExperiment=new YAHOO.util.CustomEvent("selectExperiment",null);
	
}

calExperimentSelect.prototype.create=function(container,dirimages,ulListExperiments)
{
	var navConfig = {
        strings : {
            month: "Choose Month",
            year: "Enter Year",
            submit: "OK",
            cancel: "Cancel",
            invalidYear: "Please enter a valid year"
        },
        monthFormat: YAHOO.widget.Calendar.SHORT,
        initialFocus: "year"
    };
    this.calendar = new YAHOO.widget.Calendar(container, {navigator: navConfig});
	var me=this;
	this.calendar.selectEvent.subscribe(function(type,args,obj) {
		var dates = args[0];
		var date = dates[0];
		// var txtDate1 = document.getElementById("date1");
		me.findExperiemnt(date,dirimages,ulListExperiments);
	}, this.calendar, true,this);
}
calExperimentSelect.prototype.selectDayExperiment=function(CurrentExperiment)
{
	
	var experiment=CurrentExperiment.split("--");
	var date_experiment=experiment[1].split("_");
	
	this.findExperiemnt(date_experiment,this.dirimages,this.ulListExperiments);
}
calExperimentSelect.prototype.findExperiemnt=function(dateSelected,dirimages,ulListExperiments)
{
	var hoursAviables=new Array();
	var index=0;
	ulListExperiments.innerHTML="";
	// <input id="radio2" type="radio" name="radiofield1" value="Radio 2">
	for(var i=0;i<dirimages.length;i++)
	{
		var experiment=dirimages[i].split("--");
		if(experiment[0] == "experiment")
		{
			var date_experiment=experiment[1].split("_");
			
			// #formato de la fecha mes dia año
			if(dateSelected[0] == date_experiment[0] && dateSelected[1] == date_experiment[1] && dateSelected[2]==date_experiment[2])
			{
				var li=document.createElement("li");
				var inputRB=document.createElement('input');
				inputRB.setAttribute('type','radio');
				inputRB.setAttribute('name','dirImages');
				inputRB.setAttribute('value',dirimages[i]);
				
				YAHOO.util.Event.addListener(inputRB,"click",function(event,me){me[0].selectExperiment.fire(me[1]);},[this,dirimages[i]]);
				
				li.appendChild(inputRB);
				
				var span=document.createElement('span');
				span.innerHTML=date_experiment[3]+":"+date_experiment[4];
				li.appendChild(span);
				ulListExperiments.appendChild(li);
				
				hoursAviables[index]=date_experiment[1]+"/"+date_experiment[2]+"/"+date_experiment[0]+"/"+date_experiment[3]+"/"+date_experiment[4];
				index++;
			}
		}
	}
	return hoursAviables;
}

// calExperimentSelect.prototype.handleSelect=function(type,args,obj) {
// 	var dates = args[0];
// 	var date = dates[0];
// 	var year = date[0], month = date[1], day = date[2];
// 	// var txtDate1 = document.getElementById("date1");
// 	alert(month + "/" + day + "/" + year);
// }


calExperimentSelect.prototype.clear=function()
{
	// this.calendar.clear();
	// this.calendar.resetRenderers();
	// this.calendar.reset();
	this.ulListExperiments.innerHTML="";
	this.calendar.destroy();
}

calExperimentSelect.prototype.getSelectExperiment=function()
{
	var nodelistCheck=document.getElementsByTagName('input');
	
	for(var i=0;i<nodelistCheck.length;i++)
	{
		if(nodelistCheck[i].type=='radio' &&  nodelistCheck[i].checked)
		{
			return nodelistCheck[i].value;
		}
		
	}
	
}

calExperimentSelect.prototype.setSelectExperiment=function(currentExperiment)
{
	var nodelistCheck=document.getElementsByTagName('input');
	
	for(var i=0;i<nodelistCheck.length;i++)
	{
		if(nodelistCheck[i].type=='radio' &&  nodelistCheck[i].value==currentExperiment)
		{
			nodelistCheck[i].checked=true;
			return true;
		}	
	}	
	return false;
}

calExperimentSelect.prototype.selectDays=function(dirimages)
{
	this.dirimages=dirimages;	
	
	if(this.calendar)
	{
		this.clear();
	}
	this.create(this.container,dirimages,this.ulListExperiments);
	
	for(var i=0;i<dirimages.length;i++)
	{
		var experiment=dirimages[i].split("--");
		if(experiment[0] == "experiment")
		{
			var date_experiment=experiment[1].split("_");
			
			// #formato de la fecha mes dia año
			var date=date_experiment[1]+"/"+date_experiment[2]+"/"+date_experiment[0];
			
			this.calendar.addRenderer(date, this.calendar.renderCellStyleHighlight1); 
		}
		
		
	}
	this.calendar.render();
}