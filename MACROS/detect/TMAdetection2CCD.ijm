setBatchMode(true);
file=getArgument()
open("#file#");
run("8-bit");
run("Enhance Contrast", "saturated=0.35");
setAutoThreshold("Default");
setThreshold(#thresholdMin#, #thresholdMax#);
run("Convert to Mask");
run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
run("Set Measurements...", "  center redirect=None decimal=3");
run("Analyze Particles...", "size=#size#-#maxsize# pixel circularity=#circularity#-1.00 show=Outlines display clear include add");