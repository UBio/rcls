open("#file#");

//print("\\Clear");//resetea el contenido del "log window"
wsizeRectangle = #widthRectangle#; //cambiar para definir la anchura del roi
hsizeRectangle = #heightRectangle#; //cambiar para definir la altura del roi



//run("Median...", "radius=3");
//run("Subtract Background...", "rolling=2 separate create sliding");
//run("Brightness/Contrast...");
run("Invert");
run("Enhance Contrast", "saturated=0.35");
//run("Apply LUT");
run("Rotate 90 Degrees Right");
setAutoThreshold("Default");
setThreshold(180, 255);
run("Convert to Mask");
run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");



imageWidth=#widthImage#
imageHeight=#heightImage#

xIni=#initImageX#
yIni=#initImageY#

xRatio = imageWidth/wsizeRectangle;
roundupxRatio = floor(xRatio)+1;
yRatio = imageHeight/hsizeRectangle;
roundupyRatio = floor(yRatio)+1;

for(i=0; i<roundupxRatio; i++)
{
	for(j=0; j<roundupyRatio; j++)
	{
		x=i*wsizeRectangle+xIni;
		y=j*hsizeRectangle+yIni;
		makeRectangle(x, y, wsizeRectangle, hsizeRectangle);
		getStatistics(area, mean, min, max);
		if (max == 0)
		{
			print(x+"  "+y);
			drawRect(x, y, wsizeRectangle, hsizeRectangle);
		}
	}
}
