// Viz Assignment 1: Squarified Treemap
// Steph Cleland & Rob Lasell
// 19 September 2015

boolean usingColonSeparatedData = false;
String path = "processing/a1/hierarchy3.shf";
Node root = null;
Node currentRoot = null;
Node[] nodes = null;
Canvas currentCanvas = null;
int currentNodes;
int numLeaves;
int numNodes;
boolean dealingWithMouseClick = false;
float basePadding;
float paddingFactor = 0.02;
float depthFactor = 0.8;
float numChildrenFactor = 0.997;
float treeDepth;
float baseLightRed = 205;
float baseLightGreen = 240;
float baseLightBlue = 255;
float baseDarkRed = 0;
float baseDarkGreen = 124;
float baseDarkBlue = 169;
int highlightColor = color(255, 254, 179);

void setup() {
  size(900, 500);
  //700,600 seems ideal
  
  //if (frame != null) {
  //  frame.setResizable(true);
  //}
  
  setupTree();
}

void draw() {
  background(color(baseLightRed, baseLightGreen, baseLightBlue));
  treeDepth = calculateTreeDepth(currentRoot);
  
  currentCanvas = new Canvas(0, 0, width, height, currentRoot, 0);
  
  basePadding = min(width, height) * paddingFactor;
  
  squarify(currentRoot.canvas, 0);
  
  checkMouseHover(currentRoot);
  
  if (dealingWithMouseClick) {
    dealingWithMouseClick = false;
  }

  nullifyCanvases(root);
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
          newCanvas = new Canvas(c.x + oldSide, c.y, c.w - oldSide, c.h, c.node, c.depth);
        } else {
          newCanvas = new Canvas(c.x, c.y + oldSide, c.w, c.h - oldSide, c.node, c.depth);
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
      currentRoot = n;
    } else if (currentRoot.parent != null) {
      currentRoot = currentRoot.parent;
    }
  } else {
    n.canvas.render(highlightColor);
    n.renderChildren();
    fill(0);

    // temporary fix to Processing.js lacking String.format
    float a = n.value * 100;
    int b = a;
    float c = b;
    c = c / 100;

    String t = n.id + ": " + c; //+ String.format("%.1f", n.value);
    text(t, mouseX, mouseY);
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
                         childNode, c.depth + 1);
    } else {
      child = new Canvas(c.x + spaceUsed + (padding / 2),
                         c.y + (padding / 2),
                         spaceNeeded - (padding),
                         side - (padding),
                         childNode, c.depth + 1);
    }
    spaceUsed += spaceNeeded;
    child.render();
    squarify(child, 0);
  }
}

void setupTree() {  
  String[] lines = loadStrings(path);
  numLeaves = parseInt(lines[0]);
  numNodes = parseInt(lines[numLeaves + 1]) + 1;
  nodes = new Node[numNodes];
  currentNodes = 0;
  
  buildTree(lines);
  
  setLeafValues(lines);
  
  // find root
  for (int i = 0; i < currentNodes; i++) {
    if (nodes[i].parent == null) {
      root = nodes[i];
    }
  }
  
  // recursively assign parents their values
  root.calculateValue();
  currentRoot = root;
}

void buildTree(String[] lines) {
  for (int i = numLeaves + 2; i < lines.length; i++) {
    String[] line;
    if (usingColonSeparatedData) {
      line = split(lines[i], ": ");
    } else {
      line = split(lines[i], " ");
    }
    String parent = line[0];
    String child = line[1];

    int parentIndex = indexOfNode(parent);
    int childIndex = indexOfNode(child);
    
    if (parentIndex == -1) {
      nodes[currentNodes] = new Node(parent);
      parentIndex = currentNodes;
      currentNodes++;
    }
    if (childIndex == -1) {
      nodes[currentNodes] = new Node(child);
      childIndex = currentNodes;
      currentNodes++;
    }
    
    nodes[childIndex].parent = nodes[parentIndex];
    nodes[parentIndex].children.add(nodes[childIndex]);
  }
}

void setLeafValues(String[] lines) {
  for (int i = 1; i <= numLeaves; i++) {
    String[] line;
    if (usingColonSeparatedData) {
      line = split(lines[i], ": ");
    } else {
      line = split(lines[i], " ");
    }
    String id = line[0];
    float value = parseFloat(line[1]);
    int index = indexOfNode(id);
    
    //println(id);
    nodes[index].value = value;
  }
}

int indexOfNode(String id) {
  for (int i = 0; i < currentNodes; i++) {
    if (nodes[i].id.equals(id)) {
      return i;
    }
  }
  return -1;
}

void mouseClicked() {
  dealingWithMouseClick = true;
}

void printTree(Node n) {
  print(n.id + ":" + n.value + " [");
  
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

