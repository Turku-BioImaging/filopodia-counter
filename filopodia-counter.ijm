
run("Close All");
print("\\Clear");
run("Collect Garbage");
roiManager("reset");
run("Set Measurements...", "  redirect=None decimal=3");
run("Clear Results");

// select file to be corrected
// select file(s) to be corrected
#@ File[] (label="Select the file(s) to be corrected") files ;

#@ String (label="Select filopodia channel", choices={"C1", "C2", "C3", "C4"}, style="listBox") filo
#@ String (label="Select cell channel", choices={"C1", "C2", "C3", "C4"}, style="listBox") cell

#@ File (label="Select where to save results", style="directory") results_path ;

//-----------------------


for (p = 0; p < lengthOf(files); p++) {
	
	roiManager("reset");
	
	options = "open=[" + files[p] + "] autoscale color_mode=Default stack_order=XYCZT use_virtual_stack "; // here using bioformats
	run("Bio-Formats", options);
	
	name = getTitle();

	getDimensions(width, height, channels, slices, frames);
	
	if (channels > 1) {
		run("Split Channels");
	}
	
	//rename windows for easier handlling
	selectWindow(filo +"-"+ name);
	rename("filopodia");
	
	selectWindow(cell +"-"+ name);
	rename("cell");
	
	//process image
	selectWindow("cell");
	run("Subtract Background...", "rolling=50");
	
	setAutoThreshold("Triangle");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Invert");
	run("Fill Holes");
	run("Options...", "iterations=1 count=5 black do=Close");
	run("Keep Largest Region");
	close("cell");
	selectWindow("cell-largest");
	rename("cell");
	
	run("Analyze Particles...", "add");
	
	roiManager("Select", 0);
	run("Convex Hull");
	roiManager("Add");
	
	roiManager("Select", 1);
	roiManager("Rename", name);
	run("Enlarge...", "enlarge=-6");
	run("Make Band...", "band=8");
	
	roiManager("Update");
	
	//roiManager("Fill");
	
	selectWindow("filopodia");
	run("Median...", "radius=0.5");
	run("Top Hat...", "radius=2");
	roiManager("Select", 1);
	run("Find Maxima...", "prominence=3000 strict output=Count");
	//run("Find Maxima...", "prominence=3000 strict output=[Single Points]");
	//rename("tips");

	//create and save QC image
	selectWindow("filopodia");
	roiManager("Show All without labels");
	roiManager("Select", 0);
	roiManager("Set Color", "pink");
	roiManager("Select", 1);
	roiManager("Set Color", "white");

	run("Flatten");
	run("RGB Color");
	
	
	
	saveAs(".tiff", results_path + File.separator + name + "_mask");
	
	close("*");
	
}

selectWindow("Results");
saveAs("Results", results_path + "/results.csv");	
//close("Results");
