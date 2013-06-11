setBatchMode(true);
open("#file#");
run("Rotate 90 Degrees Right");
setThreshold(0, 30);
run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
run("Set Measurements...", "  bounding redirect=None decimal=3");
run("Analyze Particles...", "size=20-50 circularity=0.00-1.00 show=Nothing display clear");
close();
 ;
