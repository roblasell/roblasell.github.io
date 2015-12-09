class Trend {
  
  IntList values;
  String dept;
  String disc;
  
  LineGraph parent;
  float max;
  float prevX;
  float prevY;
  
  color c;
  boolean highlighted;
  int highlightedIndex;
  
  Trend(String department, String discipline, LineGraph lg, color col) {
    dept = department;
    disc = discipline;
    values = new IntList();
    parent = lg;
    c = col;
    highlighted = false;
    
    getValues();
    
    max = values.max();
  }
  
  void getValues() {
    for (int i = 0; i < years.size(); i++) {
      int sum = 0;
      
      for (TableRow row : data.findRows(years.get(i), "Year")) {
        String department = row.getString("PI Department");
        if (department.equals(dept)) {
          sum += row.getInt("Total");
        }
      }
      
      values.append(sum);
    }
  }
  
  void render() {
    for (int i = 0; i < values.size(); i++) {
      float x = parent.graphX + ((i + 0.5) * parent.xSpacing);
      float y = parent.graphY + (parent.graphH * (1 - ((float)values.get(i) / parent.currentMax)));
      color fillColor = c;
      boolean hovering = false;
      
      if ((highlightedDisc != null && disc.equals(highlightedDisc)) || (highlightedDept != null && dept.equals(highlightedDept))) {
        fillColor = parent.trendHighlightColor;
      } else if (highlightedDisc != null || highlightedDept != null) {
        fillColor = color(200);
      }
      
      if (i != 0) {
        fill(color(red(fillColor), green(fillColor), blue(fillColor), alpha(fillColor) * 0.4));
        stroke(color(red(fillColor), green(fillColor), blue(fillColor), alpha(fillColor) * 0.4));
        line(prevX, prevY, x, y);
      }
      
      prevX = x;
      prevY = y;
      
      if (dist(mouseX, mouseY, x, y) <= 4 && (highlightedDept == null || highlightedDept.equals(dept))) {
        if (parent.dealingWithMouseClick && values.get(i) > 0) {
          currentDept = dept;
          currentDisc = null;
        }
        
        hovering = true;
        
        highlightedDept = dept;
        highlighted = true;
        highlightedIndex = i;
        highlightSwitch = 1;
      } else if (highlighted && i == highlightedIndex) {
        highlightedDept = null;
        highlightedDisc = null;
        highlighted = false;
      }
      
      fill(fillColor);
      stroke(fillColor);
      strokeWeight(8);
      point(x, y);
      strokeWeight(1);
      
      if (hovering) {
        textSize(12);
        noStroke();
        String t = dept + ", " + millionify(values.get(i));
        fill(textBoxColor);
        float rectWidth = textWidth(t) + 8;
        float rectHeight = 18;
        rect(mouseX, mouseY - rectHeight, rectWidth, rectHeight);
        
        fill(textBoxTextColor);
        text(t, mouseX + 4, mouseY - 4);
        stroke(0);
      }
    }
  }
  
  boolean visible() {
    return ((currentDisc == null && currentDept == null) || 
            (currentDisc != null && disc.equals(currentDisc)) || 
            (currentDept != null && dept.equals(currentDept)));
  }
}
