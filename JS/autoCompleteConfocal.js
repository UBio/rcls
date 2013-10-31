autoCompleteConfocal=function(data,input,container)
{
	var oDS = new YAHOO.util.LocalDataSource(data);
	this.data=data;
    oDS.responseSchema = {fields : ["templates"]};
    // Instantiate the AutoComplete
    this.oAC = new YAHOO.widget.AutoComplete(input, container, oDS);
    this.oAC.useShadow = true;
	this.oAC.minQueryLength = 0; 
	this.oAC.maxResultsDisplayed = 100;
	this.currentValue="";
	
	this.onChangeEvent=new YAHOO.util.CustomEvent("onChange",null);
	
	var me=this;
	this.oAC.itemSelectEvent.subscribe(function(event,args){
																me.currentValue=args[2][0];
																me.onChangeEvent.fire(me.currentValue);
															});
}
autoCompleteConfocal.prototype.destroy=function()
{
	this.oAC.destroy();
}
autoCompleteConfocal.prototype.getValue=function()
{
	return this.currentValue;
}

autoCompleteConfocal.prototype.setValue=function(value)
{
	
	for(var i=0;i<this.data.length;i++)
	{
		if(value==this.data[i])
		{
			this.oAC.getInputEl().value=value;
			this.currentValue=value;
			return true;
		}
	}
	return false;
}