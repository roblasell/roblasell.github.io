float sliderDiameter = 20;
color sliderColor = buttonColor;
color sliderLineColor = 0;
color sliderHighlightColor = buttonHighlightColor;

class Slider {
  int id;
  float x;
  float y;
  float w;
  float h;
  float textX;
  float textY;
  float vMax;
  float v;
  String text;
  String constant;

  Slider(int ID, String con, String t, float xPos, float yPos, float wid, float hgt, float vM) {
    id = ID;
    x = xPos;
    y = yPos;
    w = wid;
    h = hgt;
    text = t;
    constant = con;
    textX = x;
    textY = y - 20;
    vMax = vM;
    v = x + ((constants.get(constant) / vMax) * w);
  }
  
  void render() {
    stroke(sliderLineColor);
    if (over() || (draggingSlider && currentSlider == id)) {
      fill(sliderHighlightColor);
    } else {
      fill(sliderColor);
    }
    line(x, y, x + w, y);
    ellipse(v, y, sliderDiameter, sliderDiameter);
    
    textSize(14);
    rectMode(CORNER);
    fill(0);
    float val = ((v - x) / w) * vMax;
    String vs = String.format("%." + 2 + "f", val);
    text(text + ": " + vs, textX, textY);
  }
  
  boolean over() {
    float d = sqrt(pow((mouseX - v), 2) + pow((mouseY - y), 2));
    if (d <= sliderDiameter / 2) {
      return true;
    } else {
      return false;
    }
  }
  
  void mapConstant() {
    float val = ((v - x) / w) * vMax;
    constants.put(constant, val);
  }
}

