class Rectangle {

  float xPercent;
  float yPercent;
  float wPercent;
  float hPercent;
  float x;
  float y;
  float wid;
  float hgt;
  
  color c;
  String text;
  
  Rectangle (float xp, float yp, color col, String t, float wp, float hp) {
     c = col;
     hPercent = hp;
     wPercent = wp;
     text = t;
     xPercent = xp;
     yPercent = yp;
     x = xPercent * canvasWidth;
     y = yPercent * height;
     wid = wPercent * canvasWidth;
     hgt = hPercent * height;
  }
  
  void render () {    
    noStroke();
    rectMode(CENTER);
    
    if (newState == text) {
      fill(color(120, 141, 150));
    } else {
      fill(c);
    }
    
    rect(x, y, wid, hgt);
    stroke(0);
  }
  
  boolean overRect() {
    if (mouseX >= x - wid / 2 && mouseX <= x + wid / 2 && mouseY >= y - hgt / 2 && mouseY <= y + hgt / 2) {
      return true;
    } else {
      return false;
    }
  }
}
