requires("1.53");
run("Close All");
macro "FLAIR T2 Workflow" {

    parent = getDirectory("Choose parent folder");
    if (parent=="")
        exit("No folder selected.");

    labels   = newArray("A","B","C","D","E","F","G");
    suffixes = newArray("a","b","c","d","e","f","g");
    wants    = newArray(true, true, false, false, true, true, false);

    Dialog.create("Choose series");
 
    // debugging step 
    list = getFileList(parent);
    for (j=0; j<list.length; j++) {
        print("ftw Parent contains: " + list[j]);
    }  // end debug step

    for (k=0; k<labels.length; k++)
    Dialog.addCheckbox(labels[k], wants[k]);
    Dialog.addChoice("Timepoint", newArray("1","2","3","4"), "1");
    Dialog.addChoice("Which e-f datasets from Results folders to load in also?", newArray("None","Results_Timepoint1","Results_Timepoint2","Results_Timepoint3"), "Results_Timepoint1");
    Dialog.addChoice("Display layout", newArray("Single-screen laptop", "Three monitors"), "Three monitors");
    Dialog.addNumber("Contrast saturation (%)", 0.35, 2, 6, "%");
    Dialog.show();
    
    
timepoint = Dialog.getChoice();
selected = newArray(labels.length);
    
    
for (i=0; i<labels.length; i++)
    selected[i] = Dialog.getCheckbox();

resultsChoice = Dialog.getChoice();
displayLayout = Dialog.getChoice();
sat = Dialog.getNumber();

    openedTitles = newArray();
    openedKinds  = newArray();

    if (resultsChoice!="None") {
        resultsPath = parent + resultsChoice + File.separator;
        if (File.exists(resultsPath)) {
            title = openSeriesFolder(resultsPath, "R", sat, 300);
            if (title!="") {
                openedTitles = Array.concat(openedTitles, title);
                openedKinds  = Array.concat(openedKinds, "R");
            }
        } else {
            print("Missing results folder: " + resultsPath);
        }
    }

    for (i=0; i<labels.length; i++) {
        if (!selected[i])
            continue;

seriesKey = timepoint + suffixes[i];
seriesPath = findSeriesFolder(parent, seriesKey);
        if (seriesPath=="") {
            print("Missing folder for " + labels[i]);
        } else {
            zoomPct = 200;
            if (labels[i]=="E" || labels[i]=="F")
                zoomPct = 300;

            title = openSeriesFolder(seriesPath, labels[i], sat, zoomPct);
            if (title!="") {
                openedTitles = Array.concat(openedTitles, title);
                openedKinds  = Array.concat(openedKinds, labels[i]);
            }
        }
    }

    arrangeWindows(openedTitles, openedKinds, displayLayout);
}

function findSeriesFolder(parent, seriesKey) {
    list = getFileList(parent);

    for (i=0; i<list.length; i++) {
        name = list[i];
        full = parent + name;

        if (!File.isDirectory(full))
            continue;

        trimmed = stripTrailingSlash(name);
        lower = toLowerCase(trimmed);

        print("Checking: " + lower + " for seriesKey " + seriesKey);

        if (startsWith(lower, seriesKey + "_")
        ||  startsWith(lower, seriesKey)
        ||  indexOf(lower, "_" + seriesKey + "_") >= 0
        ||  indexOf(lower, "_" + seriesKey) >= 0) {
            return full;
        }
    }

    return "";
}

function openSeriesFolder(path, label, sat, zoomPct) {
    if (!File.exists(path))
        return "";

    File.openSequence(path);
    title = getTitle();

    getDimensions(w, h, c, z, t);
    n = z;
    if (n<1)
        n = nSlices;
    if (n<1)
        n = 1;

    mid = floor(n/2);
    if (mid<1)
        mid = 1;

    setSlice(mid);
    run("Enhance Contrast", "saturated="+sat);

    getDimensions(w, h, c, z, t);
    cx = floor(w/2);
    cy = floor(h/2);

    run("Set... ", "zoom="+zoomPct+" x="+cx+" y="+cy);

    rename(label + " | " + title);
    return getTitle();
}

function arrangeWindows(titles, kinds, displayLayout) {

    if (displayLayout=="Three monitors") {
        baseX = 3020;
        baseY = 13;
    } else {
        baseX = 20;
        baseY = 40;
    }

    for (i=0; i<titles.length; i++) {
        selectWindow(titles[i]);
        k = kinds[i];

        x = baseX;
        y = baseY;

        if (k=="A") { x = baseX;        y = baseY;       }
        if (k=="B") { x = baseX + 540;  y = baseY;       }
        if (k=="E") { x = baseX;        y = baseY + 610; }
        if (k=="F") { x = baseX + 540;  y = baseY + 610; }
        if (k=="R") { x = baseX + 1080; y = baseY + 610; }
        if (k=="C") { x = baseX;        y = baseY + 1220; }
        if (k=="D") { x = baseX + 540;  y = baseY + 1220; }
        if (k=="G") { x = baseX + 1080; y = baseY;       }

        setLocation(x, y);
    }
}

function stripTrailingSlash(s) {
    if (endsWith(s, "/"))
        return substring(s, 0, lengthOf(s)-1);
    if (endsWith(s, "\\"))
        return substring(s, 0, lengthOf(s)-1);
    return s;
}