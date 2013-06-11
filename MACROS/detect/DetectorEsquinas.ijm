/*
 * Macro diseñada para el proyecto del CAM. Se trata de encontrar las coordenadas
 * más cercanas a las esquinas superiores (izquierda y derecha) de la imágen dónde
 * empieza el mosaico. Se han generado unos bucles que capturan el valor del píxel
 * empezando por cada una de las esquinas y recorriendo unas sóla dimensión (x o y)
 * . La macro binariza la imágen encendiendo los píxeles que valen 0 (sin señal), 
 * se considera que empieza el mosaico cuando el valor del píxel vale 1.
 */
run("Options...", "iterations=1 count=1 black edm=Overwrite");
//Las anteriores son las opciones de binarización
getDimensions(width, height, channels, slices, frames);
//print("width: "+width);
//print("height: "+height);
setThreshold(0, 0);
run("Convert to Mask");
//getPixel(x, y);
for(i=0; i<=width-1;i++)
{
	pixelValue=getPixel(i,0);
	//print("i: "+i);
	if(pixelValue==0)
	{
		xEsquinaSuperiorIzquierda=i-1;
		//print("---------------------");
		//print("x Esquina superior izquierda: "+xEsquinaSuperiorIzquierda);
		i=width;
		print(xEsquinaSuperiorIzquierda+", "+0);
	}
}
for(i=0; i<=height-1;i++)
{
	pixelValue=getPixel(0,i);
	//print("i: "+i);
	if(pixelValue==0)
	{
		yEsquinaSuperiorIzquierda=i-1;
		//print("---------------------");
		//print("y Esquina superior izquierda: "+yEsquinaSuperiorIzquierda);
		i=height;
		print(0+", "+yEsquinaSuperiorIzquierda);
	}
}
for(i=width-1; i>=0;i--)
{
	pixelValue=getPixel(i,0);
	//print("i: "+i);
	if(pixelValue==0)
	{
		xEsquinaSuperiorDerecha=i+1;
		//print("i: "+i);
		//print("---------------------");
		//print("x Esquina superior derecha: "+xEsquinaSuperiorDerecha);
		i=-1;
		print(xEsquinaSuperiorDerecha+", "+0);
		
	}
}
for(i=0; i<=height-1;i++)
{
	pixelValue=getPixel(width-1,i);
	//print("i: "+i);
	if(pixelValue==0)
	{
		yEsquinaSuperiorDerecha=i-1;
		//print("---------------------");
		//print("y Esquina superior derecha: "+yEsquinaSuperiorDerecha);
		i=height;
		print(width-1+", "+yEsquinaSuperiorDerecha);		
		
	}
}