// node for use with the FlowGraph class
class FGNode {
  
  float x;
  float y;
  float diameter;
  float value;
  
  color c;
  color deptHighlightColor = masterHighlightColor;
  
  FGData parent;
  
  String disc;
  String name;
  
  ArrayList<FGNode> sponsoredDepts;
  
  FGNode(FGData p, String n, color col, String discipline) {
    c = col;
    parent = p;
    value = 0;
    name = n;
    
    disc = discipline;
    sponsoredDepts = new ArrayList<FGNode>();
    
    x = 100;
    y = 100;
  }
  
  void setPos(float xPos, float yPos, float d) {
    x = xPos;
    y = yPos;
    diameter = d;
  }
  
  void render() {
    noStroke();
    
    // render a white circle behind each node so that nodes
    // with alpha < 255 don't show the links behind them
    fill(255);
    ellipse(x, y, diameter - 2, diameter - 2);
    float newDiameter = diameter;
    
    fill(c);
    if (disc != null) {
      if (!parent.parent.over()) {
        if (highlightedDept != null || highlightedDisc != null) {
          if ((highlightedDisc != null && highlightedDisc.equals(disc)) || (highlightedDept != null && highlightedDept.equals(name))) {
            newDiameter *= 1.1;
            fill(deptHighlightColor);
          }
        }
      } else if (over()) {
        newDiameter *= 1.1;
        fill(deptHighlightColor);
        highlightSwitch = 2;
        highlightedDept = name;
      }
    }
    
    
    ellipse(x, y, newDiameter, newDiameter);
    
    if (over()) {
      textSize(12);
      String t = name + ", " + millionify(value);
      fill(textBoxColor);
      float rectWidth = textWidth(t) + 8;
      float rectHeight = 18;
      rect(mouseX - rectWidth, mouseY - rectHeight, rectWidth, rectHeight);
      
      fill(textBoxTextColor);
      text(t, (mouseX - rectWidth) + 4, mouseY - 4);
    }
  }
  
  boolean over() {
    float d = dist(mouseX, mouseY, x, y);
    
    if (d < diameter / 2) {
      return true;
    } else {
      return false;
    }
  }
}
