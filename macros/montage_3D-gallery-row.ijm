//This code is adapted from macros written by Steve Rothery
//FILM - Facility for Imaging in Light Microscopy, Imperial College London
//http://www3.imperial.ac.uk/imagingfacility/


//adaptations are labelled with "#deleted:" or #changed:"


macro "3D Gallery from multichannel image (v2) Action Tool - C99gF1188 C777F9988 Cg99F1988 C9g9F9188 C000R11gg C000T3e123 Tae12D" 
{

//get info
fn=getTitle();

//create Duplicate
run("Make Composite");
run("Duplicate...", "duplicate");
rename("new");
getDimensions(width, height, channels, slices, frames);
getVoxelSize(px, py, pz, units);


if (slices>1 && frames>1){
	exit(Macro does not work on a timed Z stack);
}

totaldisplaychannels=channels+1;
steps=frames;
step="frames";
if (slices>1){
step="slices";
steps=slices;
}	

//work out columns
rows=1;
if ((channels+1)/3>1){
rows=floor((channels+1)/3)+1;
}
cols=floor((channels+1)/rows);
if (cols*rows<channels+1){
cols=cols+1;
}

//dialog
Dialog.create("3D Gallery");
  Dialog.addMessage("Select layout for the final images");
  Output = newArray("One row", "One column", "Multiple");
  //#changed:
  Dialog.addRadioButtonGroup("Arrangement Shape:", Output, 3, 2, "One row");
  Dialog.addNumber("If multiple select number of  rows:", rows);
  Dialog.addNumber("and number of columns:", cols);
  Dialog.addNumber("Image border width in pixels:", 4);
  Scale = newArray("Yes", "No");
  //#changed:
  Dialog.addRadioButtonGroup("Scale bar? (tick - 'Label all slices')", Scale, 1, 1, "Yes");
//#deleted:
//Dialog.show;
  
Arrangement=Dialog.getRadioButton();
rows=Dialog.getNumber();
cols=Dialog.getNumber();
bw=Dialog.getNumber(); 
ScaleBar = Dialog.getRadioButton();
if (bw==0){
borderwidth=1;
}
else if (bw>0){
borderwidth=bw;
}


setBatchMode(true);
//duplicate
run("Duplicate...", "title=[tempx] duplicate range=1-"+steps);


//split channels
selectWindow("tempx");
run("Split Channels");
for (i = 1; i<=channels; i++)
{
selectWindow("C"+i+"-tempx");
run("RGB Color");
rename(i);
}

//create overlay
selectWindow("new");
run("Stack to RGB", step);
if (steps>1){
selectWindow("new");
}
rename(totaldisplaychannels);


//output selection
if (Arrangement=="One row") {
	  format=totaldisplaychannels;
      MontRow();
   } else if (Arrangement=="Multiple"){
      MontBoth();
   }  else if (Arrangement=="One column"){
   	  format=totaldisplaychannels;
      MontCol();
   }  


//multi function
function MontBoth(){
totalwindows=rows*cols;
CurrentTotalWindows=totaldisplaychannels;

//add channels if necessary
v=totaldisplaychannels;
for (i=CurrentTotalWindows; i<totalwindows; i++){   
    AddChan(v);
    v=v+1;
}

//main part
w=1;
format=cols;
for (r=0; r<rows; r++) 
{
MontRow();
a="r"+w;
rename(a);
w=w+1;

if (rows>1){
	begin=cols+1;
	end=totalwindows-(cols*r);
renumber(begin,end);
}
}

for (v=1; v<=rows; v++){
selectWindow("r"+v);
rename(v);
}

for (j=1; j<rows; j++){
YCombine();
}
}


//renumber function
function renumber(begin,end){
renum=1;
for (i=begin; i<=end; i++){
selectWindow(i);
rename(renum);
renum=renum+1;
}
}

//row construct
function MontRow(){
for (j=1; j<format; j++){
selectWindow("1");
XCombine();
}
}

//column consruct
function MontCol(){
for (j=1; j<format; j++){
selectWindow("1");
YCombine();
}
}

//combine images in x
function XCombine(){
getDimensions(width, height, channels, slices, frames);
newImage("HyperStack", "8-bit grayscale-mode", borderwidth, height, 1, slices, frames);
if (bw>0){
run("Invert LUT");
}
run("RGB Color");
rename("border");
t="stack1=[1] stack2=["+(j+1)+"]";
tb="stack1=[1] stack2=[border]";
run("Combine...", tb);
rename("1");
run("Combine...", t);
rename("1");	
}

//combine images in y
function YCombine(){
getDimensions(width, height, channels, slices, frames);
newImage("HyperStack", "8-bit grayscale-mode", width, borderwidth, 1, slices, frames);
if (bw>0){
run("Invert LUT");
}
run("RGB Color");
rename("border");
t="stack1=[1] stack2=["+(j+1)+"] combine";
tb="stack1=[1] stack2=[border] combine";
run("Combine...", tb);
rename("1");
run("Combine...", t);
rename("1");	
}

//add blank channels
function AddChan(v){
selectWindow(v);
getDimensions(width, height, channels, slices, frames);
newImage("HyperStack", "8-bit grayscale-mode", width, height, 1, slices, frames);
run("RGB Color");
rename(v+1);	
}

setBatchMode(false);

//finish up
if (steps==frames){
	swap="order=xyczt(default) channels=1 slices=" + slices + " frames=" + frames +" display=Composite";
run("Stack to Hyperstack...", swap);
}

//scalr bar
if (ScaleBar=="Yes")
{
run("Scale Bar...", "width=50 height=8 font=10 color=White background=None location=[Lower Right] bold overlay hide");	
}
	
setVoxelSize(px, py, pz, units);
rename("3D_Montage_of_" + fn);
}



