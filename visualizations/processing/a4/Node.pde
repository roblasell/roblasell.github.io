class Node {
  String name;
  float value;
  Node parent;
  ArrayList<Node> children;
  Canvas canvas;
  boolean isDept;
  
  Treemap treemap;
  
  Node(String ID, Treemap t, boolean _isDept) {
    children = new ArrayList<Node>();
    value = 0;
    name = ID;
    parent = null;
    canvas = null;
    isDept = _isDept;
    
    treemap = t;
  }
  
  void calculateValue() {
    float sum = 0;
    
    for (int i = 0; i < children.size(); i++) {
      Node child = children.get(i);
      
      if (child.value == 0) {
        child.calculateValue();
      }
      
      sum += child.value;
    }

    value = sum;
    
    sortChildren();
  }

  void sortChildren() {
    int currentIndex = 0;
    for (int i = 0; i < children.size(); i++) {
      Node temp = children.get(i);
      for (int j = i; j > 0; j--) {
        if (children.get(j).value > children.get(j - 1).value) {
          children.set(j, children.get(j - 1));
          children.set(j - 1, temp);
        }
      }
    }
  }
  
  void renderChildren() {    
    for (int i = 0; i < children.size(); i++) {
      children.get(i).canvas.render();
      children.get(i).renderChildren();
    }
  }
}
