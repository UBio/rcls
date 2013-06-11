setBatchMode(true);
dir = "#DIR#";


inixgrid=#INIXGRID#;
iniygrid=#INIYGRID#;
size_xgrid=#SIZEXGRID#-#INIXGRID#+1;
size_ygrid=#SIZEYGRID#-#INIYGRID#+1;


run("Grid/Collection stitching", "type=[Filename defined position] order=[Defined by filename] grid_size_x="+size_xgrid+" grid_size_y="+size_ygrid+" tile_overlap=10 first_file_index_x="+inixgrid+" first_file_index_y="+iniygrid+" directory=["+dir+"] file_names=Field-X{xx}-Y{yy}.tif output_textfile_name=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 subpixel_accuracy computation_parameters=[Save memory (but be slower)] image_output=[Fuse and display]");
saveAs("Tiff", "#tiffOutput#");



