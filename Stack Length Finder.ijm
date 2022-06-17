//Before using make sure to copy the Garbage.ijm macro into the macro folder in order to remove the memory leaks
//Also before using, go to Bio-Foramts Plugin Configuration, go to Formats tab, find TIFF (tagged image file format) and uncheck enable
//save location. Need to change this depending on the computer and intention
input="E:/ImageJ Macro Output/" //where the files to process are located
zstacks=4; //user input required 
channels=2; //user input required

Table.create("LengthOfRecordings");

list=getFileList(input);
print(list.length);

for (i=0; i<list.length; i++) {
	print(list[i]);
	print(i);
	file=list[i];
	npath=input+file;
	print(npath);
	Vpath="open=["+input+file+"]";
	print(Vpath);
	run("TIFF Virtual Stack...", Vpath);
	Y=getInfo("window.title");
	print(Y);
	eos=lengthOf(Y);
	sos=eos-4;
	Z=substring(Y, 0,sos);
	print("VarZ",Z);
	OG_filename=File.name;
	Stack.getDimensions(Wd,Ht,Ch,Sl,F);
	print("Sl",Sl);
	print("F",F);
	Sl=Sl*F*Ch;
	print(Sl);
	Sl=Sl/zstacks/channels;
	Table.set("NameofRecording",i,Z);
	Table.set("LengthOfRecordings", i, Sl);
	close("*");
}
	