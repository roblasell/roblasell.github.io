class Edge {
  int n1;
  int n2;
  float initial;
  float current;
  
  Edge(int node1, int node2, float i) {
    println("new edge with n1 = " + node1 + " and n2 = " + node2);
    n1 = node1;
    n2 = node2;
    initial = i;
    calculateLength();
  }
  
  void render(color c) {
    stroke(c);
    line(nodes[n1].x, nodes[n1].y, nodes[n2].x, nodes[n2].y);
  }
  
  void calculateLength() {
    current = sqrt(pow((nodes[n1].x - nodes[n2].x), 2) + pow((nodes[n1].y - nodes[n2].y), 2));
    if (current < minParticleDistance) {
      current = minParticleDistance;
    }
  }
}
