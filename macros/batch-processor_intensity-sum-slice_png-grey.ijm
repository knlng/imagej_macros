Stack.setChannel(1);
Property.set("CompositeProjection", "null");
Stack.setDisplayMode("grayscale");
run("Grouped Z Project...", "projection=[Sum Slices]");
Stack.setChannel(1);