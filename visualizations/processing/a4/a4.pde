// Visualization Assignment 4: Coordinated-Multiple Views (CMV)
// Rob Lasell

Table data;
String filePath = "processing/a4/data/soe-funding.csv";
Treemap treemap;
LineGraph linegraph;
FlowGraph flowgraph;
StringList years;
StringList depts;

String currentYear;
String currentDisc = null;
String currentDept = null;
String highlightedDept = null;
String highlightedDisc = null;

int highlightSwitch;
color masterHighlightColor = #2980B9;
color textBoxColor = color(218, 219, 240, 200);
color textBoxTextColor = color(3, 78, 123);

// FlowGraph globals
color[] colors = {#74E4D2, #10ABC2, #3498DB, #0071AC, #114771, #2C3E50, #574460, #9B59B6, #722143, color(170, 16, 19), #BF3D1D, color(239, 160, 166), #F37F0B, #FFCD17, #D7EF65, #7FB957, color(39, 174, 97), #297B6A, color(1, 50, 32)};
float FGpadding = 10;

void setup() {
  data = loadTable(filePath, "header");
  years = new StringList();
  depts = new StringList();
  
  highlightSwitch = -1;
  
  for (TableRow row : data.rows()) {
    String year = row.getString("Year");
    String dept = row.getString("PI Department");
    
    if (!years.hasValue(year)) {
      years.append(year);
    }
    
    if (!depts.hasValue(dept)) {
      depts.append(dept);
    }
  }
  
  years.sort();  
  currentYear = "2012";
  
  size(1200, 700);
  
  //treemap = new Treemap(.61 * width, .01 * height, .38 * width, .98 * height);
  //linegraph = new LineGraph(0, 0.5 * height, 0.6 * width, 0.5 * height);
  //flowgraph = new FlowGraph(0, 0, 0.6 * width, 0.5 * height);
  
  treemap = new Treemap(0.01 * height, 0.51 * height, (0.55 * width) - (0.01 * height), 0.48 * height);
  
  linegraph = new LineGraph(0, 0, 0.55 * width, 0.5 * height);
  
  flowgraph = new FlowGraph(.55 * width, 0.05 * height, .45 * width, height * 0.9);
}

void draw() {
  if ((highlightSwitch == 0 && !treemap.over()) || (highlightSwitch == 1 && !linegraph.over()) || (highlightSwitch == 2 && !flowgraph.over())) {
    highlightSwitch = -1;
    highlightedDept = null;
    highlightedDisc = null;
  }
  
  clear();
  background(255);
  
  treemap.run();
  linegraph.run();
  flowgraph.run();
}

void mouseClicked() {
  treemap.dealingWithMouseClick = true;
  
  if (mouseButton == LEFT) {
    if (linegraph.over()) {
      linegraph.computeHoverIndex();
      
      linegraph.dealingWithMouseClick = true;
      
      if (linegraph.hoverIndex != -1) {
        String year = currentYear;
        currentYear = years.get(linegraph.hoverIndex);
        linegraph.computeMax();
        if (linegraph.currentMax == 0) {
          currentYear = year;
        }
      }
    }
    
    if (flowgraph.over()) {
      for (int i = 0; i < flowgraph.currentData.departments.size(); i++) {
        if (flowgraph.currentData.departments.get(i).over()) {
          currentDept = flowgraph.currentData.departments.get(i).name;
          currentDisc = null;
        }
      }
    }
  }
}

String millionify(float val) {
  float newVal = val / 1000000.0;
  String toReturn;
  
  if (newVal < 1) {
    
    toReturn = ((float)(round(newVal * 10000)) / 10) + "K";
  } else {
    toReturn = ((float)(round(newVal * 10)) / 10) + "M";
  }
  
  return toReturn;
}