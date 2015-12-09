class PieSlice {
  float x;
  float y;
  float angle;
  float start;
  float diameter;
  float circ;
  color c;
  
  PieSlice(float xPos, float yPos, float a, float s,  float d, color col) {
    x = xPos;
    y = yPos;
    angle = a;
    start = s;
    c = col;
    diameter = d;
    circ = (angle * diameter) / 2;
  }
  
  void render() {
    fill(c);
    //stroke(255);
    noStroke();
    arc(x, y, diameter, diameter, start, start + angle, PIE);
    stroke(0);
  }
}
