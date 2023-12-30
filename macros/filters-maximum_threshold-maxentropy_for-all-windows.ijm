run("Maximum...", "radius=2");
setAutoThreshold("MaxEntropy dark");
run("Create Selection");
roiManager("Add");
saveAs("Tiff");