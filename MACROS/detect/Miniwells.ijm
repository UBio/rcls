setBatchMode(true);
file=getArgument()
open("#file#");
run("Rotate 90 Degrees Right");
//Aquí debería abrir la imágen roja
redID = getImageID();
redTitle = getTitle();
run("Duplicate...", "title=[rojo binario]");
binaryRedID = getImageID();
binaryRedTitle = getTitle();
//Aquí empieza el procesado de la imágen roja, la cual contiene
//los pocillos
run("Median...", "radius=4");
setAutoThreshold("Default dark");
run("Convert to Mask");
run("Fill Holes");
run("BinaryFilterReconstruct ", "erosions=6 white");
run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
run("Analyze Particles...", "size=1201-Infinity circularity=0.00-1.00 show=Nothing display exclude add in_situ");

//Aquí se podría llamar a la funcion particle eraser para
//eliminar las partículas que no cumplan la condición de tamaño
//anterior

particleEraser();

selectImage(redID);
run("Open Next");
run("Rotate 90 Degrees Right");
binaryGreenID = getImageID();
binaryGreenTitle = getTitle();
//Aquí empieza el procesado de la imàgen verde, la cual contiene
// las partículas
run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
run("Median...", "radius=1");
setAutoThreshold("RenyiEntropy dark");
run("Convert to Mask");
run("BinaryFilterReconstruct ", "erosions=1 white");

run("Analyze Particles...", "size=12-120 circularity=0.00-1.00 show=Nothing display exclude add in_situ");
roiManager("Show All with labels");
roiManager("Show All");

//Aquí se podría llamar a la funcion particle eraser para
//eliminar las partículas que no cumplan la condición de tamaño
//anterior

particleEraser();
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
run("Analyze Particles...", "size=0-Infinity circularity=0.00-1.00 show=Nothing display exclude add in_situ");
roiManager("Show All with labels");
roiManager("Show All");
//selectWindow(""+binarygreenANDredTitle+"");

//aqui hay que meter el loop que vaya seleccionando los pocillos que
//tienen al menos una imágen
/*height = getHeight();
width = getWidth();
newImage("Untitled", "8-bit", width, height, 1);
newID = getImageID();
roiManager("select", index);//cambiar index por i
setForegroundColor(255, 255, 255);
run("Fill", "slice");
imageCalculator("AND create", "Untitled","Result of rojo binario");
*/
//La siquiente línea de código permite seleccionar en la imágen que
// contiene a las partículas, aquellas partículas que están solas
//en un pocillo
selectImage(binaryGreenID);
nRois = roiManager("count");
print("nRois: "+nRois);
for(i=nRois; i>=1;i--)
{
print("i: "+i);
updateResults();
nResults;
IJ.deleteRows(0, nResults);
roiManager("select", i-1);
run("Analyze Particles...", "size=0-Infinity circularity=0.00-1.00 show=Nothing display exclude in_situ");
print("nResults: "+nResults);
if(nResults!=1)
{
roiManager("select", i-1);
roiManager("Delete");
}
}


//Esta función permite eliminar las partículas que no están en 
//el ROI manager
function particleEraser()
{
n = roiManager("count");
indexes = newArray(n);
for(i=0; i<n;i++)
{
indexes[i] = i;	
print("indexes["+i+"]: "+indexes[i]);
}

run("Create Selection");
run("Make Inverse");
setForegroundColor(0, 0, 0);
run("Fill", "slice");

setForegroundColor(255, 255, 255);
roiManager("select", indexes);
roiManager("Fill");
roiManager("Reset");
}



//Aquí falta seleccionar todas las ROIs y pointarlas