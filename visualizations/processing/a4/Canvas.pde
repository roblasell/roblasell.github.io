class Canvas {
  
  float x;
  float y;
  float w;
  float h;
  int depth;
  Node node;
  color col;
  
  Treemap treemap;
  
  Canvas(float xPos, float yPos, float wid, float hgt, Node n, int d, Treemap t) {
    x = xPos;
    y = yPos;
    w = wid;
    h = hgt;
    depth = d;
    
    treemap = t;
    
    float red = treemap.baseLightRed - (depth * ((treemap.baseLightRed - treemap.baseDarkRed) / treemap.treeDepth));
    float green = treemap.baseLightGreen - (depth * ((treemap.baseLightGreen - treemap.baseDarkGreen) / treemap.treeDepth));
    float blue = treemap.baseLightBlue - (depth * ((treemap.baseLightBlue - treemap.baseDarkBlue) / treemap.treeDepth));
    col = color(red, green, blue);
    
    node = n;
    if (node.canvas == null) {
      node.canvas = this;
    }
  }
  
  void render(color c) {
    if (depth == 0) {
      stroke(200);
    } else {
      stroke(c);
    }
    fill(c);
    rect(x, y, w, h);
  }
  
  void render() {
    if (depth == 0) {
      stroke(200);
    } else {
      stroke(col);
    }
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
