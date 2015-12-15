class StoryButton {
  float x, y, w, h;
  String label;
  float percent;
  ArrayList<Filter> filters;
  color c;
  
  StoryButton(float _x, float _y, float _w, float _h, float _percent, String _label, color _c) {
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    
    percent = _percent;
    label = _label;
    c = _c;
    
    filters = new ArrayList<Filter>();
  }
  
  void render() {
    strokeWeight(1.5);
    noStroke();
    
    if (isOver()) {
      fill(c);
      rect(x, y, w, h, 10);
    } else {
      fill(c, 0.6 * 255);
      rect(x, y, w, h, 10);
    }
    
    fill(255);
    text(label, x + 5, y + 5, w - 10, h - 10);
    
    stroke(0);
  }
  
  boolean isOver() {
    return (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h);
  }
  
  void clicked() {
    for (Filter f : filterMenu.filters) {
      f.selected = false;
    }
    
    for (Filter f : filters) {
      f.selected = true;
    }
    
    filterTable();
  }
}