class FilterMenu {
  float x;
  float y;
  float w;
  float h;
  
  float buttonX;
  float buttonY;
  float buttonW;
  float buttonH;
  
  ArrayList<Filter> filters;
  
  FilterMenu(float _x, float _y, float _w, float _h) {
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    
    buttonX = 0.865 * canvasWidth;
    buttonY = h * 0.7;
    buttonW = w * 0.45;
    buttonH = 20;
    
    filters = new ArrayList<Filter>();
  }
  
  void render() {
    noStroke();
    fill(filterMenuColor);
    rect(x, y, w, h);
    
    textSize(16);
    fill(filterTextColor);
    text("Filter by:", x + (0.1 * w), 40);
    strokeWeight(1.5);
    stroke(filterTextColor);
    line(x + 0.1 * w, 0.075 * h, x + 0.9 * w, 0.075 * h);
    
    stroke(0);
    String category = "";
    for (Filter f : filters) {
      if (!(category.equals(f.category))) {
        category = f.category;
        textSize(15);
        fill(filterTextColor);
        text((category.substring(0, 1)).toUpperCase() + category.substring(1, category.length()) + ":", f.x, f.y - f.w);
      }
      
      f.render();
    }
    
    if (isOverButton()) {
      fill(filterHighlightColor);
    } else {
      noFill();
    }
    
    stroke(filterTextColor);
    strokeWeight(1.5);
    rect(buttonX, buttonY, buttonW, buttonH);
    strokeWeight(2);
    fill(filterTextColor);
    textSize(13);
    text("Clear All", buttonX + 10, buttonY + 15);
  }
  
  void addFilter(float _x, float _y, float _w, float _h, String _text, String _value, String _category) {
    Filter newFilter = new Filter(_x, _y, _w, _h, _text, _value, _category);
    filters.add(newFilter);
  }
  
  boolean isOverButton() {
    return (mouseX <= buttonX + buttonW && mouseX >= buttonX && mouseY <= buttonY + buttonH && mouseY >= buttonY);
  }
}