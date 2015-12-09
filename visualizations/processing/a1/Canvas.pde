// Canvas class
// Rob Lasell & Steph Cleland

class Canvas {
  
  float x;
  float y;
  float w;
  float h;
  int depth;
  Node node;
  color col;
  
  Canvas(float xPos, float yPos, float wid, float hgt, Node n, int d) {
    x = xPos;
    y = yPos;
    w = wid;
    h = hgt;
    depth = d;
    float red = baseLightRed - (depth * ((baseLightRed - baseDarkRed) / treeDepth));
    float green = baseLightGreen - (depth * ((baseLightGreen - baseDarkGreen) / treeDepth));
    float blue = baseLightBlue - (depth * ((baseLightBlue - baseDarkBlue) / treeDepth));
    col = color(red, green, blue);
    
    node = n;
    if (node.canvas == null) {
      node.canvas = this;
    }
  }
  
  void render(color c) {
    noStroke();
    fill(c);
    rect(x, y, w, h);
  }
  
  void render() {
    noStroke();
    fill(col);
    rect(x, y, w, h);
  }
  
  boolean mouseOverCanvas() {
    if (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h) {
      return true;
    } else {
      return false;
    }
  }
}
