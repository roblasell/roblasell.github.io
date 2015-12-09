color boxLineColor = color(0);
color boxColor = color(130, 190, 250);
color boxCheckedColor = color(20, 120, 175);
color boxHighlightColor = color(255, 210, 160);

class CheckBox {
  int id;
  float x;
  float y;
  float side;
  float textX;
  float textY;
  String text;
  String constant;
  boolean checked;

  CheckBox(int ID, String con, String t, float xPos, float yPos, float s) {
    id = ID;
    checked = false;
    x = xPos;
    y = yPos;
    side = s;
    text = t;
    constant = con;
    textX = x + side + 10;
    textY = y + side - 3;
  }
  
  void render() {
    stroke(boxLineColor);
    if (over()) {
      fill(boxHighlightColor);
    } else if (checked) {
      fill(boxCheckedColor);
    } else {
      fill(boxColor);
    }
    rectMode(CORNER);
    rect(x, y, side, side);
    
    textSize(14);
    fill(0);
    text(text, textX, textY);
  }
  
  boolean over() {
    if (mouseX > x && mouseX < x + side && mouseY > y && mouseY < y + side) {
      return true;
    } else {
      return false;
    }
  }
  
  void mapConstant() {
    if (checked) {
      constants.put(constant, 1.0);
    } else {
      constants.put(constant, 0.0);
    }
  }
}
