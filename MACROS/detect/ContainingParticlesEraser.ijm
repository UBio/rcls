/*
 * Macro hecha para el proyecto CAM de la Unidad de Microscopía
 * Confocal. Funciona a partir de una ventana de Results que
 * contiene n partículas en filas y 4 columnas: BX (coordenada
 * x del bounding rectangle de la partícula), BY (coordenada y
 * del bounding rectangle de la partícula), Width (grosor del 
 * bounding rectangle) y Height (altura del bounding rectangle).
 * La macro crea una nueva columna (Area) con el area del 
 * bounding rectangle de cada partícula, ordena las partículas de
 * mayor a menor área y elimina las partículas que están incluidas
 * dentro de otras.
 */

/*Esta parte del código crea la ventana de Results, está aquí
 * por motivos de evaluación. Comentar si no hace falta. Hay que
 * correrla sobre la imágen a analizar.
 */
open("#file#");
setBatchMode(true);
run("8-bit");
run("Enhance Contrast", "saturated=0.35");
//run("Rotate 90 Degrees Right");
setAutoThreshold("Default");
setThreshold(20, 115);
run("Convert to Mask");
run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
run("Set Measurements...", "  bounding redirect=None decimal=3");
run("Analyze Particles...", "size=1000-1000000 pixel circularity=0-1.00 show=Outlines display exclude clear");
/*
 * Aquí termina el código que crea la ventana de Results y empieza
 * la macro própiamente dicha.
 */




 
BAreaArray = newArray(nResults);//Contendrá las áreas de las partículas ordenadas por aparición en "Results"
/*
 * Este bucle va a crear la columna Area
 */
for(i=0;i<nResults;i++)
{
a=getResult("Width", i);
b=getResult("Height", i);
setResult("BArea", i, a*b);
BAreaArray[i]=getResult("BArea", i);
//print(i,BAreaArray[i]);
updateResults();
}

/*Las tres siguientes líneas de código crean un array que contiene
 * el rango de Áreas ordenado de mayor a menor según su aparición
 * en "Results"
 */
rankArray = Array.rankPositions(BAreaArray);
//print(rankArray[0], rankArray[1], rankArray[2]);
Array.reverse(rankArray);
//Array.print(rankArray);

/*Crear un array(superArray) que contiene BX, BY, Width, Height 
 *and BArea de todas las selecciones
*/
//print("nResults: "+nResults);
//print("nResults*5: "+nResults*5);
superArray=newArray(nResults*5);
for(i=0;i<nResults;i++)
{
superArray[i*5]=getResult("BX",i);
//print("superArray[i]: "+i, superArray[i]);
superArray[i*5+1]=getResult("BY",i);
superArray[i*5+2]=getResult("Width",i);
superArray[i*5+3]=getResult("Height",i);
superArray[i*5+4]=getResult("BArea",i);
//print(getResult("BX",i));
}
//print("superArray[74]: "+superArray[74]);
//print("superArray[75]: "+superArray[75]);

//Ordena la ventana de Results de mayor a menor Area
for(i=0;i<nResults;i++)
{
n=rankArray[i];
//Array.print(rankArray);
setResult("BX",i, superArray[n*5]);
setResult("BY",i, superArray[n*5+1]);
setResult("Width",i, superArray[n*5+2]);
setResult("Height",i, superArray[n*5+3]);
setResult("BArea",i, superArray[n*5+4]);
	
//print(i, rankArray[i], superArray[n*5]);
}

/*
 * Empieza el proceso de borrado, primero se seleccionarán las 
 * partículas que contienen a otras, y se almacenarán en un array
 * que servirá para borrarlas luego.
 */
borrarArray=newArray(nResults);//Este array contendrá el índice de las selecciones a borrar
//Hasta aquí todo OK
for(i=0;i<nResults;i++)
{
x=getResult("BX",i);
y=getResult("BY",i);
width=getResult("Width",i);
height=getResult("Height",i);
makeRectangle(x, y, width, height);
//selectionContains(x, y);
//waitForUser("dale a la tecla campeón");

	for(j=i+1;j<nResults;j++)
	{
	x1=getResult("BX",j);
	y1=getResult("BY",j);
	x2=getResult("BX",j)+getResult("Width",j);
	y2=getResult("BY",j);
	x3=getResult("BX",j);
	y3=getResult("BY",j)+getResult("Height",j);
	x4=getResult("BX",j)+getResult("Width",j);
	y4=getResult("BY",j)+getResult("Height",j);
	//print("coordenadas: "+x1,y1,x2,y2,x3,y3,x4,y4);	
		if(selectionContains(x1,y1)==1 && selectionContains(x2,y2)==1 && selectionContains(x3,y3)==1 && selectionContains(x4,y4)==1)
		{
			//print("la selección "+j+" está dentro de la selección "+i);
			borrarArray[j]=j;
		}
	}
}

/*A partir de aquí se van a borrar de "Results" las selecciones
 * contenidas dentro de otras
 */

//Array.print(borrarArray);
rankBorrarArray=Array.rankPositions(borrarArray);
//Array.print(rankBorrarArray);
//print(rankArray[0], rankArray[1], rankArray[2]);
Array.reverse(rankBorrarArray);
//Array.print(rankBorrarArray);

for(i=0;i<nResults;i++)
{
	j=rankBorrarArray[i];
	if (borrarArray[j]!=0)
	{IJ.deleteRows(j, j)}
}
//setResult("BX", 0, 1324);
//setResult("Column", row, value)
//selectionContains(x, y)
//IJ.deleteRows(index1, index2)
//updateResults()