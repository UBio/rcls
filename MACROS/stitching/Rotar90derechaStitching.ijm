setBatchMode(true);
dir = "#DIR#";


inixgrid=#INIXGRID#;
iniygrid=#INIYGRID#;
size_xgrid=#SIZEXGRID#;
size_ygrid=#SIZEYGRID#;


run("Stitch Grid of Images", "grid_size_x="+size_xgrid+" grid_size_y="+size_ygrid+" overlap=10 directory="+dir+" file_names=Field-X{xx}-Y{yy}.tif rgb_order=rgb output_file_name=TileConfiguration.txt start_x="+inixgrid+" start_y="+iniygrid+" start_i=1 channels_for_registration=[Red, Green and Blue] fusion_method=[Linear Blending] fusion_alpha=1.50 regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 compute_overlap");
saveAs("Tiff", "#tiffOutput#");

