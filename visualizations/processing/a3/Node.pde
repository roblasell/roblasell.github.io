float squarePixelsPerKg = 250;

class Node {
  float x;
  float y;
  float vx;
  float vy;
  float fx;
  float fy;
  float mass;
  float diameter;
  int id;
  boolean fixed;
  
  Node(float xInit, float yInit, float m, int ID) {
    fixed = false;
    x = xInit;
    y = yInit;
    mass = m;
    id = ID;
    // resizing?
    diameter = 2 * sqrt((mass * squarePixelsPerKg) / PI);
    
    vx = 0;
    vy = 0;
    fx = 0;
    fy = 0;
  }
  
  void render(color c) {
    if (overNode()) {
      fill(highlightColor);
    } else if (fixed) {
      fill(fixedColor);
    } else {
      fill(c);
    }
    
    ellipse(x, y, diameter, diameter);
  }
  
  boolean overNode() {
    float dist = sqrt(pow((mouseX - x), 2) + pow((mouseY - y), 2));
    return dist <= diameter / 2;
  }
}
