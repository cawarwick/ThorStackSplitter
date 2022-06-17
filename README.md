# ThorStackSplitter
This is an ImageJ macro which takes in the OME Tiffs output from ThorImageLS and does a variety of things to get them ready for image stabilization and processing. 
NOTE: This splitter is specific for ThorImageLS output files. ThorImageLS writes Tiffs as XYZTC rather than the typical XYCZT which messes up most TIFF importers (e.g. Suite2p) as they expect Tiffs in XYCZT.
_____________________________________________________________________________________
To do before using the macro:

1. Install the garbage.ijm macro into the macro folder in your fiji installation (e.g. fiji-win64\Fiji.app\macros)

The garbage.ijm macro clears unused but occupied RAM use. ImageJ has some bad memory management and it leaks RAM. For some reason running the garbage collection from inside the macro doesn't always work so launching an external macro seems to more consistently clear RAM 

2. Disable the Bio-Formats Plugin importer. Go to Bio-Formats Plugin Importer Configuration, go to Formats tab, find TIFF (tagged image file format) and uncheck enable. 

If this is turned on, it will launch each time the macro tries to open a file and will pause until there is user input to confirm how to import it, for fully autonomous processing leave this turned off, but you can always just keep a stock copy of Fiji if you use this function.
________________________________________________________________________________________
User provided information for running the macro (Located at the top of the macro when opened in FIJI)

Input=”C:/path/to/where/the tiffs are/”

Path=”C:/path/to/where/you/want the tiffs saved”

Zstacks= number of z-stacks in the source file

Channels= number of channels in the source file

RemoveZplanes=1 or 0      ///set to 0 to keep all z-planes, set to 1 to enable the z-plane remover

KeepStackStart=number   ////this the first plane that it keeps

KeepStackEnd=number   ///this is the last plane that it keeps

________________________________________________________________________________________
Basic operations of this macro
1.	Open the tiff
2.	 Rearrange the stacks from XYZTC into a more common XYCZT
3.	Remove blank frames from end of recording and round to the nearest volume
4.	Remove any bad z-planes e.g. a flyback frame. (optional, and needs to be turned on or off)
5.	Break the files into pieces smaller than 4 gb. This is necessary for Suite2p as it wants files in a MultiPage TIFF format and if the files are >4gb ImageJ saves them as a SinglePage format. If the files are not <4gb suite2p will not ‘see’ them.
6.	Save the split files as _001, 002, 003, etc.
