//This code is adapted from macros written by Steve Rothery
//FILM - Facility for Imaging in Light Microscopy, Imperial College London
//http://www3.imperial.ac.uk/imagingfacility/


//adaptations are labelled with "#deleted:" or #changed:"


//duplicate image
fn=getTitle();
run("Duplicate...", "title=duplicate");
rename(fn);


macro "Annotated Gallery from multichannel image Action Tool -C00gF0088 C777F8888 Cg00F0888 C0c0F8088  Cggg T3708a Tc708b T3g08c Tcg08d L08h8 L808h C000R00gg" 
{

roiManager("Reset");
run("Colors...", "foreground=white background=black selection=white");
//get user dye names
path=getDirectory("luts");
dye_file=path+"Dyes.txt";
Dye = newArray("DAPI", "488", "546", "568", "594", "647", "GFP","RFP","mCherry","Brightfield","Phase Contrast", "DIC" );


if (File.exists(dye_file)==true){
	dyes=File.openAsString(dye_file); 
	dye_names=split(dyes, "\n");
	Dye = Array.concat(dye_names,Dye); 
}


//get info
fn=getTitle();
rename("new");

setBatchMode(true);

// convert RGB
if (bitDepth()==24){
run("Split Channels");
run("Merge Channels...", "c1=[new (red)] c2=[new (green)] c3=[new (blue)] create");
	rename("new");
}

// check for RGB stack error
getDimensions(ImageWidth, ImageHeight, ImageChannels, ImageSlices, ImageFrames);
rename("new");
run("Split Channels");
seq="";
for (chan=1;chan<=ImageChannels;chan++){
nextImage="c"+chan+"=[C"+chan+"-new] ";
seq=seq+nextImage;
}
seq=seq+"create";
run("Merge Channels...", seq);


setBatchMode("exit and display");

getVoxelSize(px, py, pz, units);

run("Channels Tool...");
//#deleted:
//waitForUser("Select Channels to be included in overlay image");



textfactor=(ImageWidth/325);
totaldisplaychannels=ImageChannels+1;

if(ImageSlices>1 || ImageFrames>1){
	exit("This macro does not work on a Z-Stack ot time series, use 3D Gallery tool");
};


//get format
rows=1;
if ((totaldisplaychannels)/3>1){
rows=floor((totaldisplaychannels)/3)+1;
}
cols=floor((totaldisplaychannels)/rows);
if (cols*rows<totaldisplaychannels){
cols=cols+1;
}


//get output info
Dialog.create("Select Output Options");
  Output = newArray("Colour", "Grayscale");
  Dialog.addRadioButtonGroup("Output of the individual images in colour or grayscale?:", Output, 1, 2, "Colour");
  Dialog.addNumber("Number of Columns",cols );
  Dialog.addNumber("Number of Rows", rows);
  Dialog.addNumber("Border Width", 5);
  Dialog.addCheckbox("Get help with this macro? ", false);
//#deleted:
//Dialog.show;
//inputs  
Col = Dialog.getRadioButton(); 
cols=Dialog.getNumber();
rows=Dialog.getNumber();
Bord=Dialog.getNumber();
hlp=Dialog.getCheckbox();
titletext=newArray(totaldisplaychannels);

	
if (hlp==true){
title = "Help";
msg = "Select the desired format options \n \n Channel names can be loaded automatically from a text file. \n  \n Create a channel list using notepad, pressing enter after each entry \n \n then save the text file as Dyes.txt into FIJI's LUT directory \n \n This will be loaded as part of the macro if you select 'Add Title'.\n \n After completion the Overlay can be edited using the RoiManager \n";
waitForUser(title, msg);	
}


xtitle=floor(7*textfactor);
ytitle=floor(7*textfactor);

xtext=floor(7*textfactor);
ytext=ImageHeight-floor(7*textfactor);


//get overlay options
Dialog.create("Overlay options");
yesno=newArray("Yes", "No");
title=newArray("Yes", "No");
Option = newArray("Uppercase - ABC", "Lowercase - abc", "Numbers - 123", "No");
//#changed:
Dialog.addRadioButtonGroup("Insert image titles? ", title, 1, 2, "Yes");
Dialog.setInsets(0, 20, 0);
Dialog.addMessage("NOTE: A user-defined 'title' list can be added to the drop down lists. This will be loaded automatically when the macro runs.");
Dialog.setInsets(-5, 20, 0);
Dialog.addMessage("To create the list, use Notepad to add one dye per line of text, then save the file as 'Dyes.txt' into the LUT directory of FIJI.");
Dialog.setInsets(5, 20, 0);
//#changed:
Dialog.addNumber("Title Text size:", 60);
Dialog.addCheckbox("Check box to select the position of the title on the image or enter/use the co-ordinates below", false);
Dialog.addNumber("Position of top left of title text from left", xtitle);
Dialog.addNumber("Position of top left of title text from top", ytitle);
//#changed:
Dialog.addRadioButtonGroup("Insert figure letter/numbers?", Option, 1, 4, "Uppercase - ABC");
//#changed:
Dialog.addNumber("Text size: ", 60);
Dialog.addCheckbox("Check box to select position of the figue number on the image or enter/use the co-ordinates below", false);
Dialog.addNumber("Position of bottom left of figure text from left", xtext);
Dialog.addNumber("Position of bottom left of figure text from top", ytext);
//#changed:
Dialog.addRadioButtonGroup("Add a scale bar?", yesno, 1, 2, "Yes");
//deleted:
//Dialog.show(); 

//get response
AddTitle=Dialog.getRadioButton();
titleheight=Dialog.getNumber();
marktitle=Dialog.getCheckbox();
xtitle=Dialog.getNumber();
ytitle=Dialog.getNumber();
AddFigNum=Dialog.getRadioButton();
numberheight=Dialog.getNumber();
marktext=Dialog.getCheckbox();
xtext=Dialog.getNumber();
ytext=Dialog.getNumber();
AddScaleBar = Dialog.getRadioButton();

if (AddTitle=="Yes"){
Dialog.create("Overlay options 2");
Dialog.addMessage("Select text names for image titles");
for (i=1; i<totaldisplaychannels; i++) {
Dialog.addChoice("Channel " + i, Dye, Dye[i-1]);
Dialog.addString("or Antibody name: ", "");
}
Dialog.addMessage("Select title name for merged image");
over=newArray("Merged", "Overlay", "Combined", "All Channels", "Blank");
Dialog.addChoice("Select from list ", over, "Merged");
Dialog.addString("or insert your own: ", "");
Dialog.show(); 


for (j=0; j<ImageChannels; j++){
titletext[j] = Dialog.getChoice();
AlternateText=Dialog.getString();
if (AlternateText!=""){
    	titletext[j]=AlternateText;
}	
}
}
merged=Dialog.getChoice();
mergedAlternText=Dialog.getString();
if (merged=="Blank"){
	merged="";
}
if (mergedAlternText!=""){
	merged=mergedAlternText;
}

totalwindows=rows*cols;

//figure number format
if (AddFigNum=="Uppercase - ABC"){
Textformat=newArray("A","B","C","D","E","F","G","H","I","J","K","L");
}
if (AddFigNum=="Lowercase - abc"){
Textformat=newArray("a","b","c","d","e","f","g","h","i","j","k","l");	
}
if (AddFigNum=="Numbers - 123"){
Textformat=newArray(1,2,3,4,5,6,7,8,9,10,11,12);
}




setTool("point");

//select position for title
if (AddTitle=="Yes"){
	titletext[ImageChannels]=merged;	
if (marktitle==true){ 
title = "Get info";
msg = "Mark top left of text for position for figure titles \n then select OK to continue";
waitForUser(title, msg);
getSelectionBounds(xtitle, ytitle, wtitle, htitle);
}
}


//select position for figurenum
if (AddFigNum!="No"){
	if (marktext==true){	
title = "Get info";
msg = "Mark bottom left or text for position for figure numbers \n then select OK to continue";
waitForUser(title, msg);
getSelectionBounds(xtext, ytext, wtext, htext);
}
}



setBatchMode(true);

//main process
selectWindow("new");
run("Duplicate...", "duplicate");
rename("tempx");


selectImage("tempx");     
 if (Col=="Grayscale"){
      Stack.setDisplayMode("grayscale");  
} 
   
run("Split Channels");

selectWindow("new");
rename("C" + totaldisplaychannels + "-tempx");



for (i=1;i<=totaldisplaychannels;i++){
	selectWindow("C"+i+"-tempx");
	run("RGB Color");
	rename(i);
}


//add channels if necessary
v=totaldisplaychannels;
for (i=totaldisplaychannels; i<totalwindows; i++){   
    AddChan2(v);
    v=v+1;
}


//output selection 
if (rows==1 &&   cols>1) {
	format=totaldisplaychannels;
	cols=totaldisplaychannels;
      MontRow2();
   } else if (cols==1 && rows>1){
  	format=totaldisplaychannels;
  	rows=totaldisplaychannels;
  	MontCol2();
   }  else{
      MontBoth2();
   }  



//functions


//row construct
function MontRow2(){
for (j=1; j<format; j++){
selectWindow("1");
XCombine2();
}
}

//combine images in x
function XCombine2(){
newImage("border", "8-bit white", Bord, ImageHeight, 1);
run("RGB Color");
tb="stack1=[1] stack2=[border]";
t="stack1=[1] stack2=["+(j+1)+"]";
run("Combine...", tb);
rename("1");
run("Combine...", t);
rename("1");	
}


//column consruct
function MontCol2(){
for (j=1; j<format; j++){
selectWindow("1");
YCombine2();
}
}

//combine images in y
function YCombine2(){
newImage("border", "8-bit white",ImageWidth, Bord, 1);
run("RGB Color");
tb="stack1=[1] stack2=[border] combine";
t="stack1=[1] stack2=["+(j+1)+"] combine";
run("Combine...", tb);
rename("1");
run("Combine...", t);
rename("1");	
}


//multi function
function MontBoth2(){
totalwindows=rows*cols;
CurrentTotalWindows=totaldisplaychannels;

//combine images into rows and rename
w=1;
format=cols;
for (r=0; r<rows; r++) 
{
MontRow2();
a="r"+w;
rename(a);
w=w+1;
if (rows>1){
	begin=cols+1;
	end=totalwindows-(cols*r);
renumber(begin,end);
}
}

//rename rows and combine rows
for (v=1; v<=rows; v++){
selectWindow("r"+v);
rename(v);
}

for (j=1; j<rows; j++){
selectWindow("1");
getDimensions(ImageWidth, ImageHeight, ImageChannels, ImageSlices, ImageFrames);
YCombine2();
}
}
//end of montboth2


//renumber function
function renumber(begin,end){
renum=1;
for (i=begin; i<=end; i++){
selectWindow(i);
rename(renum);
renum=renum+1;
}
}

//add blank channels
function AddChan2(v){
selectWindow(v);
getDimensions(width, height, channels, slices, frames);
newImage("HyperStack", "8-bit grayscale-mode", width, height, 1, slices, frames);
run("RGB Color");
rename(v+1);	
}
///end of functions

//finish up
//#changed:
rename("3D_Montage_of_" + fn);
selectWindow("3D_Montage_of_" + fn);
setVoxelSize(px, py, pz, units);

//add overlay
p=0;
for (rws=0;rws<rows;rws++){
for (cls=0;cls<cols;cls++){
if (p<totaldisplaychannels){
if (AddFigNum!="No"){	
setFont("Arial", numberheight, " antialiased");
Overlay.drawString(Textformat[p], ImageWidth*cls+xtext+(Bord*cls), ImageHeight*rws+ytext+(Bord*rws));
}
if (AddTitle=="Yes" || AddTitle=="Load from file"){
setFont("Arial", titleheight, " antialiased");
Overlay.drawString(titletext[p], ImageWidth*cls+xtitle+(Bord*cls), ImageHeight*rws+ytitle+titleheight+(Bord*rws));
}
p=p+1;
}
}
}

//disply overlay and add to roi manager
Overlay.show();
roiManager("Deselect");
setBatchMode("exit and display");

//scale bar	
if (AddScaleBar=="Yes"){
title = "Get info";
msg = "Adjust scale, check to <Overlay> option and \n mark top left position (optional) \n then select OK to continue";
//#deleted:
//waitForUser(title, msg);
scalex=(cols-1)*(ImageWidth+Bord) +(floor(ImageWidth*0.8));
scaley=(rows-1)*(ImageHeight+Bord) + (floor(ImageHeight*0.925));
makePoint(scalex, scaley);
//#changed:
run("Scale Bar...", "width=50 height=8 font=10 color=White background=None location=[Lower Right] bold overlay hide");	
}
if (getInfo("overlay")!=""){
run("To ROI Manager");
roiManager("Show All without labels");
}

//tidy up
run("Select None");
setTool("rectangle");
title = "Get info";
msg = "If you have added graphics you will need to flatten the image for export or saving \n In ROI Manager select Flatten \n then select OK to continue";
//#deleted:
//waitForUser(title, msg);


selectWindow("C" + totaldisplaychannels + "-tempx");
rename(fn);


}