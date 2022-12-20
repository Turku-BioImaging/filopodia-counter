
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

#@ Integer (label="Prominance", value=800) prominence


//-----------------------


for (p = 0; p < lengthOf(files); p++) {

	roiManager("reset");
	
	options = "open=[" + files[p] + "] autoscale color_mode=Default stack_order=XYCZT use_virtual_stack "; // here using bioformats
	run("Bio-Formats", options);
	
	name = getTitle();
	
	getDimensions(width, height, channels, slices, frames);
	
	run("Duplicate...", "duplicate");
	rename("QC");
	
	selectWindow(name);
	
	if (channels > 1) {
		run("Split Channels");
	} else {
		exit("Multi-channel image reqruired");
	}
	
	//rename windows for easier handlling
	selectWindow(filo +"-"+ name);
	rename("filopodia");
	
	selectWindow(cell +"-"+ name);
	rename("cell");
	run("Duplicate...", " ");
	
	// find cell outlines 
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
	
	run("Analyze Particles...", "exclude add");

	roiManager("Select", 0);
	run("Convex Hull");
	run("Enlarge...", "enlarge=6");
	
	roiManager("Add");

	//find cell inside
	
	selectWindow("cell-1");
	run("Select None");
	roiManager("Deselect");
	
	run("Gaussian Blur...", "sigma=2");
	setAutoThreshold("Li dark");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Fill Holes");
	run("Options...", "iterations=20 count=1 black do=Open");
	run("Keep Largest Region");
	close("cell-1");
	selectWindow("cell-1-largest");
	rename("cell-1");
	
	run("Analyze Particles...", "exclude add");
	
	roiManager("Select", 2);
	roiManager("Update");
	
	//measure filopodia tips	
	selectWindow("filopodia");
	
	// hide cell centre
	setBackgroundColor(255, 255, 255);
	roiManager("Select", 2);
	roiManager("Fill");
	
	roiManager("Deselect");
	
	run("Median...", "radius=0.5");
	run("Top Hat...", "radius=2");
	roiManager("Select", 1);

	run("Find Maxima...", "prominence=" + prominence + " output=Count");
	run("Find Maxima...", "prominence=" + prominence + " output=[Single Points]");
	
		
	setResult("Filename", p, name);

	//clean roiManager for QC image
	roiManager("reset");

	//create and save QC image
	selectWindow("filopodia Maxima");
	run("Watershed");
	run("Analyze Particles...", "exclude add");
	nRoi = roiManager("count");
	print(nRoi);
	
	for (i = 0; i < nRoi; i++) {
		roiManager("Select", i);
		run("Enlarge...", "enlarge=3 pixel");
		roiManager("update");
		
	}
		
	selectWindow("QC");
	
	Stack.setDisplayMode("composite");
	
	setSlice(1);
	run("Grays");
	run("Enhance Contrast", "saturated=0.35");
	setSlice(2);
	run("Green");
	run("Enhance Contrast", "saturated=0.35");
	
	run("RGB Color");
	close("\\Others");
	rename("name");
	
	roiManager("show all without labels");
	
	saveAs(".tiff", results_path + File.separator + name + "_mask");
	close("*");

}

selectWindow("Results");

saveAs("Results", results_path + "/results.csv");	
close("Results");
