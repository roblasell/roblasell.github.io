class Filter {
  float x;
  float y;
  float w;
  float h;
  
  boolean selected;
  String t;
  String value;
  String category;
  
  Filter(float _x, float _y, float _w, float _h, String _t, String _value, String _category) {
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    
    value = _value;
    selected = false;
    t = _t;
    category = _category;
  }
  
  void render() {
    if (isOver()) {
      fill(filterHighlightColor);
    } else {
      noFill();
    }
    
    stroke(filterTextColor);
    strokeWeight(1.5);
    rect(x, y, w, h);
    strokeWeight(2);
    fill(filterTextColor);
    textSize(13);
    text(t, x + w + 10, y + 12);
    
    int checkSpace = 5;
    
    if (selected) {
      line(x + checkSpace, y + checkSpace, x + w - checkSpace, y + h - checkSpace);
      line(x + w - checkSpace, y + checkSpace, x + checkSpace, y + h - checkSpace);
    }
    
    strokeWeight(0);
  }
  
  boolean isOver() {
    return (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h);
  }
}