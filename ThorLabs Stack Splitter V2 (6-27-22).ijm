//Before using make sure to copy the Garbage.ijm macro into the macro folder in order to remove the memory leaks
//Also before using, go to Bio-Foramts Plugin Configuration, go to Formats tab, find TIFF (tagged image file format) and uncheck enable
//save location. Need to change this depending on the computer and intention
input="D:/Abby/#3_07122022/try/" //where the files to process are located. Make sure they are forward slashes and it ends with a forward slash.
Path="D:/Abby/#3_07122022/"; // save location of processed files
zstacks=5; //user input required 
channels=1; //user input required
//Remove any Z-planes (e.g. flyback issues)? Enter the relevant values here. This assumes 2 channels.
RemoveZplanes=0    ///set to 0 to keep all z-planes, set to 1 to enable the z-plane remover
KeepStackStart=2  ////this the first plane that it keeps
KeepStackEnd=5   ///this is the last plane that it keeps

runMacro("Garbage");
list=getFileList(input);
print("Number of files in folder:",list.length);
for (i=0; i<list.length; i++) {
	print("Name of file:",list[i]);
	print("Working on file number:",i);
	file=list[i];
	tempfile=input+" "+list[i];
	File.rename(input+list[i], tempfile);
	npath=tempfile;
	print("Opening 1st file from:",npath);
	open(npath);
		//Get the file info before messing with it
	Y=getInfo("window.title");
	print("Name of file opened:",Y);
	eos=lengthOf(Y);
	sos=eos-8;
	Z=substring(Y, 1,sos);
	print("Trimmed file name:",Z);
	OG_filename=File.name;
	Stack.getDimensions(Wd,Ht,Ch,Sl,F);
	
	//Rearrange the stacks from XYZTC into a more common XYCZT
	//add if statements - split stack and interleave only when channels = 2 
	if (channels == 2){
		run("Stack Splitter", "number=2");  //For ThorImage, first half is Gcamp, second half is red channel
		close(" "+file);
		runMacro("Garbage");
		B="stk_0001_"+OG_filename;
		C="stk_0002_"+OG_filename;
		run("Interleave", "stack_1=C stack_2=B");//interleaving the two channels to make it XYCZT
	}
	if (channels == 1){
		runMacro("Garbage");
		rename("Combined Stacks");
		}
	Stack.getDimensions(Wd,Ht,Ch,Sl,F);
	close("Stk*");
	File.rename(tempfile, input+list[i]);
	runMacro("Garbage");
	
	//remove blank frames from end of recording
	Stack.getDimensions(Wd,Ht,Ch,Sl,F);
	print("slices=",Sl,"Frames=",F);
	Y=getInfo("window.title");
	print("Name of window:",Y);
	Stack.setSlice(Sl);
	roiManager("reset");
	Table.reset("Results");
	run("Select All");
	roiManager("add");
	roiManager("measure");
	Mean=Table.get("Mean", 0);
	print("Mean value of last frame:",Mean);
	increment=zstacks*channels;
	print("Number of frames to increment:",increment);
	
	while (Mean==0) {
		Stack.getDimensions(Wd,Ht,Ch,Sl,F);
		slstart=(Sl-increment)+1;
		mksub="slices="+slstart+"-"+Sl+" delete";
		print("input to substack",mksub);
		run("Make Substack...", mksub);
		close("Substack*");
		Table.reset("Results");
		roiManager("measure");
		Mean=Table.get("Mean", 0);
		print("Mean value of last frame:",Mean);
		Table.reset("Results");
	}
	print("All zeroes removed");
	
	//remove any bad z-planes e.g. a flyback frame
	if (RemoveZplanes==1) {
		Stack.getDimensions(Wd,Ht,Ch,Sl,F);
		frames=Sl/zstacks/channels;
		hyperstack="order=xyczt(default) channels="+channels+" slices="+zstacks+" frames="+frames+" display=Color";
		print("input to hyperstack",hyperstack);
		run("Stack to Hyperstack...", hyperstack);
		substk="channels=1-"+channels+" slices="+KeepStackStart+"-"+KeepStackEnd+" frames=1-"+frames;
		print("input to substack",substk);
		run("Make Substack...", substk);
		close("\\Others");	
		rename("Combined Stacks");
		runMacro("Garbage");
	}
	
	//Breaking large images into pieces that are less than 4 gigabytes per file
	Size=getValue("image.size");//get image size in gb
	Stack.getDimensions(Wd,Ht,Ch,Sl,F);
	print("Sl",Sl);
	print("F",F);
	F=Sl*F*Ch;
	print("newF",F);
	print("Slice Size",Sl);
	print("Stack Size",F);
	print("ImageSize", Size);
	S=Size/4E9; //divide the image size by 4 gigabytes 
	S=Math.round(S);//round and then increment 
	S++;
	print("Initial Split number",S);
	Remainder=F/S; //if it's an integer that's the 'correct' number of splits otherwise it goes to the while loop
	print("Initial Frames/File",Remainder);
	RR=Math.round(Remainder);
	while(RR!=Remainder){//this is saying, while the remainder is NOT equal to the roudned value, increase the split number by 1 and retest
		S++;
		Remainder=F/S;
		RR=Math.round(Remainder);
	}
	print("Final splits",S);
	print("Final Frames/file",Remainder);
	print("Splits Calculated");
	run("Stack Splitter", "number=S");//run stack splitter based on the correct number of splits
	close("Com*");
	runMacro("Garbage");
	
	//Saving the split stacks to the hardrive
	for (g = 0; g < S; g++) {//for the number of splits, create a filename, select that filename, save it, then close it
	start="stk_";//Goofy nonesense for selecting each window 
	end="_Combined Stacks"; 
	gg=g+1;
	mid=String.pad(gg,4);
	wind=start+mid+end; //basically recreating each name individually and then joining them together
	selectWindow(wind);
	A=getInfo("window.title");
	A=substring(A, 5,8); //pull out the series split number
	print("Trimmed file name:",Z);
	Filename=Z+"_"+A; //create a filename based on the original and the series split number
	print("Path",Path);
	print("filename",Filename);
	output=Path+Filename;//where it's being saved and how it's being named
	saveAs("Tiff", output);
	close();
	}
	print("Run Finished");
	runMacro("Garbage");
}
