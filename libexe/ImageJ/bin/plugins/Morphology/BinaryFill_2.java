import ij.*;
import ij.plugin.filter.PlugInFilter;
import ij.process.*;
import ij.gui.*;

//Binary Fill 2 by Gabriel Landini, G.Landini@bham.ac.uk
//21/May/2008

public class BinaryFill_2 implements PlugInFilter {
	protected boolean doIwhite;

	public int setup(String arg, ImagePlus imp) {

		ImageStatistics stats;
		stats=imp.getStatistics();
		if (stats.histogram[0]+stats.histogram[255]!=stats.pixelCount){
			IJ.error("8-bit binary image (0 and 255) required.");
			return DONE;
		}

		if (arg.equals("about"))
			{showAbout(); return DONE;}
		GenericDialog gd = new GenericDialog("BinaryFill", IJ.getInstance());
		gd.addMessage("Binary Fill");
		gd.addCheckbox("White particles on black background",false);

		gd.showDialog();
		if (gd.wasCanceled())
			return DONE;

		doIwhite = gd.getNextBoolean ();
		return DOES_8G+DOES_STACKS;
	}

	public void run(ImageProcessor ip) {
		int xe = ip.getWidth();
		int ye = ip.getHeight();
		int x, y, X=xe-1, Y=ye-1;
		int [][] pixel = new int [xe][ye];

		//original converted to white particles
		if (doIwhite==false){
			for(y=0;y<ye;y++) {
				for(x=0;x<xe;x++)
					ip.putPixel(x,y,255-ip.getPixel(x,y));
			}
		}

		//get original
		for(y=0;y<ye;y++) {
			for(x=0;x<xe;x++)
				pixel[x][y]=ip.getPixel(x,y);
		}

		FloodFiller ff = new FloodFiller(ip);
		ip.setColor(127);

		for (y=0; y<ye; y++){
			if (ip.getPixel(0,y)==0) ff.fill(0, y);
			if (ip.getPixel(X,y)==0) ff.fill(X, y);
		}
		for (x=0; x<xe; x++){
			if (ip.getPixel(x,0)==0) ff.fill(x, 0);
			if (ip.getPixel(x,Y)==0) ff.fill(x, Y);
		}

		for(y=0;y<ye;y++) {
			for(x=0;x<xe;x++){
				if(ip.getPixel(x,y)==0)
					ip.putPixel(x,y,255);
				else
					ip.putPixel(x,y,pixel[x][y]);
			}
		}

		//return to original state
		if (doIwhite==false){
			for(y=0;y<ye;y++) {
				for(x=0;x<xe;x++)
					ip.putPixel(x,y,255-ip.getPixel(x,y));
			}
		}
	}


	void showAbout() {
		IJ.showMessage("About BinaryFill_2...",
		"BinaryFill_ by Gabriel Landini,  G.Landini@bham.ac.uk\n"+
		"ImageJ plugin for filling holes in 8-connected binary\n"+
		"particles.\n"+
		"Supports black and white foregrounds.");
	}

}
