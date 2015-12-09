ArrayList<Node> nodes;

class Treemap {
  
  float x;
  float y;
  float w;
  float h;
  
  float baseLightRed;
  float baseLightGreen;
  float baseLightBlue;
  float baseDarkRed;
  float baseDarkGreen;
  float baseDarkBlue;
  color highlightColor;
  
  int currentNodes;
  int numLeaves;
  int numNodes;
  boolean dealingWithMouseClick = false;
  float basePadding;
  float paddingFactor;
  float depthFactor;
  float numChildrenFactor;
  float treeDepth;
  
  HashMap<String,Node> trees;
  Node currentRoot;
  Canvas currentCanvas;
  
  Treemap(float xPos, float yPos, float wid, float hgt) {
    trees = new HashMap<String,Node>();
    setupTrees();
    currentRoot = null;
    currentCanvas = null;
    treeDepth = 3;
     
    x = xPos;
    y = yPos;
    w = wid;
    h = hgt;
    
    baseLightRed = 205;
    baseLightGreen = 240;
    baseLightBlue = 255;
    baseDarkRed = 52;
    baseDarkGreen = 152;
    baseDarkBlue = 219;
    highlightColor = masterHighlightColor;

    paddingFactor = 0.02;
    depthFactor = 0.8;
    numChildrenFactor = 0.997;
  }
  
  void setupTrees() {
    for (int i = 0; i < years.size(); i++) {
      Node root = new Node("Total", this, false);
      trees.put(years.get(i), root);
      nodes = new ArrayList<Node>();
      
      for (TableRow row : data.findRows(years.get(i), "Year")) {
        String disc = row.getString("Discipline");
        String dept = row.getString("PI Department");

        int discIndex = indexOfNode(disc);        
        int deptIndex = indexOfNode(dept);
        
        if (discIndex == -1) {
          Node d = new Node(disc, this, false);
          discIndex = nodes.size();
          nodes.add(d);
          root.children.add(d);
          d.parent = root;
        }
        
        if (deptIndex == -1) {
          Node d = new Node(dept, this, true);
          d.value = row.getInt("Total");
          deptIndex = nodes.size();
          nodes.add(d);
          d.parent = nodes.get(discIndex);
          nodes.get(discIndex).children.add(d);
        } else {
          nodes.get(deptIndex).value += row.getInt("Total");
        }
      }
      
      root.calculateValue();
    }
  }
  
  int indexOfNode(String name) {
    for (int i = 0; i < nodes.size(); i++) {
      if (nodes.get(i).name.equals(name)) {
        return i;
      }
    }
    
    return -1;
  }
  
  void run() {
    if (over()) {
      highlightedDept = null;
      highlightedDisc = null;
    }
    
    stroke(200);
    fill(color(baseLightRed, baseLightGreen, baseLightBlue));
    rect(x, y, w, h);
    
    findCurrentRoot();
    
    treeDepth = calculateTreeDepth(currentRoot);
  
    currentCanvas = new Canvas(x, y, w, h, currentRoot, 0, this);
    
    basePadding = min(w, h) * paddingFactor;
    
    squarify(currentRoot.canvas, 0);
    
    checkMouseHover(currentRoot);
    
    if (dealingWithMouseClick) {
      dealingWithMouseClick = false;
    }
    
    if (currentRoot.children.size() == 0) {
      textSize(12);
      noStroke();
      String t = currentRoot.name + ", " + millionify(currentRoot.value);
      if (highlightedDept != null && highlightedDept.equals(currentRoot.name)) {
        fill(color(baseLightRed, baseLightGreen, baseLightBlue));
      } else {
        fill(textBoxTextColor);
      }
      text(t, x + 14, y + 24);
      t = ((float)round((currentRoot.value / trees.get(currentYear).value) * 1000) / 10.0) + "% of Total " + currentYear + " Funding";
      text(t, x + 14, y + 40);
      stroke(0);
    }
    
    nullifyCanvases(trees.get(currentYear));
  }
  
  void findCurrentRoot() {
    Node root = trees.get(currentYear);
    
    if (currentDisc == null && currentDept == null) {
      currentRoot = root;
    } else {
      for (int i = 0; i < root.children.size(); i++) {
        Node disc = root.children.get(i);
        if (currentDept != null) {
          for (int j = 0; j < disc.children.size(); j++) {
            Node dept = disc.children.get(j); 
            if (currentDept.equals(dept.name)) {
              currentRoot = dept;
            }
          }
        } else if (currentDisc.equals(disc.name)) {
          currentRoot = disc;
        }
      }
    }
  }
  
  void squarify(Canvas c, int currentChild) {
    float canvas_area = c.w * c.h;
    float total_value = 0;
    for (int i = currentChild; i < c.node.children.size(); i++) {
      total_value += c.node.children.get(i).value;
    }
    float VA_ratio = total_value / canvas_area;
  
    float area = 0;
    float aspectRatio1;
    float aspectRatio2;
    float newSide;
    float oldSide;
    Node n1;  
    
    float short_side = min(c.w, c.h);
    if (c.node.children != null && c.node.children.size() > 0) {
      n1 = c.node.children.get(currentChild);
      
      float myArea = n1.value / VA_ratio;
      area += myArea;
      oldSide = area / short_side;
      float myShortSide = myArea / oldSide;
      aspectRatio1 = max(myShortSide / oldSide, oldSide / myShortSide);
      
      if (currentChild == c.node.children.size() - 1) {
        fixRow(c, currentChild, currentChild, oldSide, VA_ratio); 
      }
      
      for (int i = currentChild + 1; i < c.node.children.size(); i++) {
        Node n2 = c.node.children.get(i);
        myArea = n2.value / VA_ratio;
        area += myArea;
        newSide = area / short_side;
        myShortSide = myArea / newSide;
        aspectRatio2 = max(myShortSide / newSide, newSide / myShortSide);
  
        if (aspectRatio1 < aspectRatio2) {
          Canvas newCanvas;
          if (c.w > c.h) {
            newCanvas = new Canvas(c.x + oldSide, c.y, c.w - oldSide, c.h, c.node, c.depth, this);
          } else {
            newCanvas = new Canvas(c.x, c.y + oldSide, c.w, c.h - oldSide, c.node, c.depth, this);
          }
          fixRow(c, i - 1, currentChild, oldSide, VA_ratio);
          squarify(newCanvas, i);
          break;
        } else {
          n1 = n2;
          aspectRatio1 = aspectRatio2;
          oldSide = newSide;
        }
      }
    }
  }
  
  boolean checkMouseHover(Node n) {
    if (dealingWithMouseClick && mouseButton == RIGHT) {
      if (currentRoot.parent != null) {
        if (currentDept != null) {
          currentDisc = currentRoot.parent.name;
          currentDept = null;
        } else {
          currentDisc = null;
        }
      }
      
      return n.canvas.mouseOverCanvas();
    }
    
    if (((highlightedDept != null && highlightedDept.equals(n.name)) 
         || (highlightedDisc != null && highlightedDisc.equals(n.name)))
        && !over()) {
      n.canvas.render(highlightColor);
      n.renderChildren();
      return true;
    } else if (highlightedDept != null || highlightedDisc != null) {
      for (int i = 0; i < n.children.size(); i++) {
        checkMouseHover(n.children.get(i));
      }
    }
    
    if (!n.canvas.mouseOverCanvas()) {
      return false;
    }
  
    for (int i = 0; i < n.children.size(); i++) {
      if (checkMouseHover(n.children.get(i))) {
        return true;
      }
    }
    
    if (dealingWithMouseClick) {
      if (mouseButton == LEFT) {
        if (n.parent != null) {
          if (n.parent.parent == null) {
            currentDisc = n.name;
          } else {
            currentDept = n.name;
            currentDisc = null;
          }
        }
      }
    } else {
      n.canvas.render(highlightColor);
      
      if (!n.name.equals("Total")) {
        if (n.isDept) {
          highlightedDept = n.name;
        } else {
          highlightedDisc = n.name;
        }
        
        highlightSwitch = 0;
      }
      
      n.renderChildren();

      if (currentRoot.children.size() != 0) {
        textSize(12);
        noStroke();
        String t = n.name + ", " + millionify(n.value);
        fill(textBoxColor);
        float rectWidth = textWidth(t) + 8;
        float rectHeight = 18;
        rect(mouseX - rectWidth, mouseY - rectHeight, rectWidth, rectHeight);
        
        fill(textBoxTextColor);
        text(t, (mouseX - rectWidth) + 4, mouseY - 4);
        stroke(0);
      }
    }
    
    return true;
  }
  
  void fixRow(Canvas c, int childReached, int startingChild, float side, float VA_ratio) {
    float spaceUsed = 0;
    float padding = basePadding * pow(depthFactor, c.depth) * pow(numChildrenFactor, c.node.children.size());
    
    for (int i = startingChild; i <= childReached; i++) {
      Canvas child;
      Node childNode = c.node.children.get(i);
      float spaceNeeded = (childNode.value / VA_ratio) / side;
      
      if (c.w >= c.h) {
        child = new Canvas(c.x + (padding / 2),
                           c.y + spaceUsed + (padding / 2),
                           side - (padding),
                           spaceNeeded - (padding),
                           childNode, c.depth + 1, this);
      } else {
        child = new Canvas(c.x + spaceUsed + (padding / 2),
                           c.y + (padding / 2),
                           spaceNeeded - (padding),
                           side - (padding),
                           childNode, c.depth + 1, this);
      }
      spaceUsed += spaceNeeded;
      child.render();
      squarify(child, 0);
    }
  }
  
  void printTree(Node n) {
    print(n.name + ":" + n.value + " [");
    
    for (int i = 0; i < n.children.size(); i++) {
      printTree(n.children.get(i));
      
      if (i < n.children.size() - 1) {
        print(", ");
      }
    }
    
    print("]");
  }
  
  void nullifyCanvases(Node n) {
    n.canvas = null;
    for (int i = 0; i < n.children.size(); i++) {
      nullifyCanvases(n.children.get(i));
    }
  }
  
  int calculateTreeDepth(Node n) {
    int deepestDepth;
    
    if (n.children == null || n.children.size() == 0) {
      return 1;
    } else {
      deepestDepth = calculateTreeDepth(n.children.get(0));
      
      for (int i = 0; i  < n.children.size(); i++) {
        if (calculateTreeDepth(n.children.get(i)) > deepestDepth) {
          deepestDepth = calculateTreeDepth(n.children.get(i));
        }
      }
      
      return deepestDepth + 1;
    }
  }
  
  boolean over() {
    if (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h) {
      return true;
    } else {
      return false;
    }
  }
}
