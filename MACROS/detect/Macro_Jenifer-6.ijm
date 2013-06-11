/*
 * Esta macro se diseñó para Jenifer Clausell, dentro del proyecto
 * del CAM. Funciona sobre dos imágenes que son dos canales
 * distintos de un stitching de baja resolución. El canal rojo
 * contiene los pocillos de un chip y el verde células. La macro 
 * abre el canal rojo, binariza los pocillos y selecciona las 
 * células que están solas dentro de un pocillo. Devuelve el 
 * bounding rectangle de cada una de estas células. El número de
 * resultados está limitado. Para cambiar el límite hay que 
 * modificar la variable "límite" en la línea 144.
 */
run("Set Measurements...", "  bounding redirect=None decimal=3");
//El "Set Measurements" tiene que estar aquí, de lo contrario
//puede dar problemas
run("Options...", "iterations=1 count=1 black edm=Overwrite");
//Las anteriores son las opciones de binarización
setBatchMode(false);
setBatchMode(true);
open("#file#");
//Aquí debería abrir la imágen roja
redID = getImageID();
redTitle = getTitle();
run("Rotate 90 Degrees Right");
run("Duplicate...", "title=[rojo binario]");
binaryRedID = getImageID();
binaryRedTitle = getTitle();
//Aquí empieza el procesado de la imágen roja, la cual contiene
//los pocillos
run("Median...", "radius=4");
run("Auto Local Threshold", "method=Niblack radius=15 parameter_1=0 parameter_2=0 white");
//setAutoThreshold("Default dark");
run("Convert to Mask");
run("Fill Holes");
run("BinaryFilterReconstruct ", "erosions=6 white");
run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
//run("Analyze Particles...", "size=169-1088 pixel circularity=0.70-1.00 show=Nothing display exclude add in_situ");
run("Analyze Particles...", "size=169-1088 pixel circularity=0.70-1.00 show=Nothing exclude clear add");
roiManager("Show All with labels");
roiManager("Show All");

//Aquí se podría llamar a la funcion particle eraser para
//eliminar las partículas que no cumplan la condición de tamaño
//anterior

particleEraser();

selectImage(redID);
run("Open Next");
binaryGreenID = getImageID();
binaryGreenTitle = getTitle();
run("Rotate 90 Degrees Right");
//Aquí empieza el procesado de la imàgen verde, la cual contiene
// las partículas
run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
run("Median...", "radius=1");
setAutoThreshold("RenyiEntropy dark");
run("Convert to Mask");
//run("BinaryFilterReconstruct ", "erosions=1 white");

run("Watershed");
//waitForUser("antes del analyze particles previo al último particle eraser");
//run("Analyze Particles...", "size=4-64 circularity=0.70-1.00 show=Nothing display exclude clear add in_situ");
run("Analyze Particles...", "size=4-64 pixel circularity=0.70-1.00 show=Nothing exclude clear add");
roiManager("Show All with labels");
roiManager("Show All");



//La funcion particle eraser para elimina las partículas que no
//cumplen la condición de tamaño anterior

//nResults;

//IJ.deleteRows(0, nResults-1);

//waitForUser("empieza el último particle eraser");
particleEraser();

//waitForUser("termina el último particle eraser");

//A partir de aquí se empieza a seleccionar las partículas que 
//están contenidas dentro de un pocillo
imageCalculator("AND create", ""+binaryRedTitle+"",""+binaryGreenTitle+"");
binarygreenANDredID = getImageID();//Esta imágen contiene las partículas que están dentro de un pocillo
binarygreenANDredTitle = getTitle();
run("BinaryReconstruct ", "mask=["+binaryRedTitle+"] seed=["+binarygreenANDredTitle+"] create white");
binaryReconstructedID = getImageID();//Esta imágen estará compuesta por los pocillos que contienen una célula o más
binaryReconstructedTitle = getTitle();
selectImage(binaryRedID);
close();
selectImage(binarygreenANDredID);
close();
selectImage(binaryReconstructedID);
//run("Analyze Particles...", "size=0-Infinity circularity=0.00-1.00 show=Nothing display exclude add in_situ");
run("Analyze Particles...", "size=0-Infinity pixel circularity=0.00-1.00 show=Nothing exclude clear add");
roiManager("Show All with labels");
roiManager("Show All");
//waitForUser("0");
close();//Cierra la imágen binaryReconstructed, pero mantiene en 
//el ROI manager la selección de pocillos que contienen una célula
//o más

//La siquiente línea de código permite seleccionar en la imágen que
// contiene a las partículas, aquellas partículas que están solas
//en un pocillo
selectImage(binaryGreenID);
run("Duplicate...", "title=BinaryGreen-duplicate.tif");
binaryGreenDuplicateID = getImageID();
binaryGreenDuplicateTitle = getTitle();

nRois = roiManager("count");
//print("nRois: "+nRois);
individualCellCounter = 0;//Esta variable va a contar el número
//de partículas que están solas en un pocillo
for(i=nRois; i>=1;i--)
{
//print("i: "+i);
//waitForUser("1");
//updateResults();
//waitForUser("2");
//nResults;
//waitForUser("3");
//IJ.deleteRows(0, nResults);
roiManager("select", i-1);
//run("Analyze Particles...", "size=0-Infinity circularity=0.00-1.00 show=Nothing display exclude in_situ");
//waitForUser("aosdif");
run("Analyze Particles...", "size=0-Infinity pixel circularity=0.00-1.00 show=Nothing exclude clear");
//print("nResults: "+nResults);
//waitForUser("4");
if(nResults!=1)
{
roiManager("select", i-1);
roiManager("Delete");
}
/*Este código va a limitar el número de resultados a un nùmero.
 * Para variar el número hay que escribirlo en la "variable" 
 * limite (línea 144) 
 */
if(nResults ==1)
{
	individualCellCounter ++;
	//print("individualCellCounter: "+individualCellCounter);
}
	limite=100;
if (individualCellCounter == limite)
{
	//exit();
	//exit("we have reached 100 results");//La versión de Ángel
	// no puede mostrar ventanas emergentes

n = roiManager("count");
indexes = newArray(limite);//Este es el número al que se limitará el
//número de resultados
//print(n);
a=n-1;
//print(a);
//parseInt(a);
b=n-limite-1;
//print(b);
//parseInt(b);
elementMatrixCounter=0;
for(i=a; i>b;i--)
{
//print("elementMatrixCounter: "+elementMatrixCounter);
indexes[elementMatrixCounter] = i;	
//print("indexes["+elementMatrixCounter+"]: "+indexes[elementMatrixCounter]);
elementMatrixCounter++;
}

run("Select All");
setForegroundColor(0, 0, 0);
run("Fill", "slice");

setForegroundColor(255, 255, 255);
roiManager("select", indexes);
roiManager("Fill");

imageCalculator("AND create", ""+binaryGreenDuplicateTitle+"",""+binaryGreenTitle+"");
finalImageID = getImageID();
finalImageTitle = getTitle();
updateResults();
nResults;
IJ.deleteRows(0, nResults);
selectImage(finalImageID);
//run("Set Measurements...", "  bounding display redirect=None decimal=3");
run("Analyze Particles...", "size=0-Infinity circularity=0.00-1.00 show=Nothing display exclude in_situ");
selectImage(finalImageID);
close();
selectImage(binaryGreenDuplicateID);
close();
selectImage(binaryGreenID);
close();
//print("\\Clear");//Ángel necesita que el Log window está vacía
selectWindow("Results");
exit();
}
}

//-------------------------------------------------------------------
//Esta función permite eliminar las partículas que no están en 
//el ROI manager
function particleEraser()
{
n = roiManager("count");
//print(n);
indexes = newArray(n);
for(i=0; i<n;i++)
{
indexes[i] = i;	
//print("indexes["+i+"]: "+indexes[i]);
}

run("Select All");
setForegroundColor(0, 0, 0);
run("Fill", "slice");

setForegroundColor(255, 255, 255);
roiManager("select", indexes);
roiManager("Fill");
roiManager("Reset");
}
