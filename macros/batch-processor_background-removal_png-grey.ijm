Stack.setDisplayMode("color");
Stack.setChannel(1);
Property.set("CompositeProjection", "null");
Stack.setDisplayMode("grayscale");
run("Duplicate...", " ");
run("Subtract Background...", "rolling=50");
Stack.setChannel(1);