autoCompleteConfocal=function(data,input,container)
{
	var oDS = new YAHOO.util.LocalDataSource(data);
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