class Point {
  
  float x;
  float y;
  String text;
  color c;
  
  Point(float xLocation, float yLocation, String t, color col) {
    x = xLocation;
    y = yLocation;
    text = t;
    c = col;
  }
  
  void render() {
    noStroke();
    rectMode(CENTER);
    fill(c);
    rect(x, y, pointSize, pointSize);
    stroke(0);
  }
  
}
