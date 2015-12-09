class FGLink {
 
  FGNode sponsor;
  FGNode dept;
 
  float value;
  FGData parent;
 
  FGLink(FGNode d, FGNode s, FGData p) {
    dept = d;
    sponsor = s;
    parent = p;
  }
 
  void render() {
    noFill();
    strokeWeight((sponsor.diameter * 0.5) * (value / sponsor.value));
    if (alpha(sponsor.c) == 255) {
      stroke(sponsor.c);
    } else {
      stroke(red(sponsor.c), green(sponsor.c), blue(sponsor.c), alpha(sponsor.c) * 0.6);
    }
    
    bezier(sponsor.x, sponsor.y, sponsor.x + ((dept.x - sponsor.x) / 2), sponsor.y, sponsor.x + ((dept.x - sponsor.x) / 2), dept.y, dept.x, dept.y);
    strokeWeight(1);
  }
}
