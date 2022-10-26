setBatchMode(true);
imgArray = newArray(nImages);
for (i=0; i<nImages; i++) {
selectImage(i+1);
imgArray[i] = getImageID();
}

//now we have a list of all open images, we can work on it:

for (i=0; i< imgArray.length; i++) {
selectImage(imgArray[i]);

// INSERT MACRO HERE

Stack.setDisplayMode("composite");
Stack.setActiveChannels("111");

target=round(nSlices*0.5);  
setSlice(target);

}