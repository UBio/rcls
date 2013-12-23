setBatchMode(true);
file=getArgument()
open("#file#");
run("8-bit");
run("Median...", "radius=3");
run("Invert");
// run("Subtract Background...", "rolling=2 separate create sliding");
run("Enhance Contrast", "saturated=0.35");
run("Rotate 90 Degrees Right");
setAutoThreshold("Default");
setThreshold(#thresholdMin#, #thresholdMax#);
run("Convert to Mask");
run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
run("Set Measurements...", "  bounding redirect=None decimal=3");
run("Analyze Particles...", "size=#size#-#maxsize# pixel circularity=#circularity#-1.00 show=Nothing display exclude clear");