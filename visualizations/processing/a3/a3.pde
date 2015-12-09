// Viz Assignment 3: Force-Directed Node-Link Diagram
// Rob Lasell

// physical constants and variables
HashMap<String,Float> constants;
int numConstants = 4;
Menu menu;
float HOOKE = 0.3;
float COULOMB = 20000;
float DAMP = 0.5;
float TIME = 0.4;
float CENTERING = 0.007;
float maxHooke = 1;
float maxCoulomb = 25000;
float maxDamp = 2;
float maxTime = 1;
float baseE = 0.01;
float totalE = baseE + 1;
float minParticleDistance = 0.5;
boolean paused = false;
boolean centering = false;

// data stuff
int numNodes;
int numEdges;
Node[] nodes;
Edge[] edges;
String filePath = "processing/a3/data/data1.csv";

boolean dragging = false;
boolean draggingSlider = false;
int currentSlider = 0;
int currentNode = 1;
boolean openingMenu = false;
boolean closingMenu = false;
float draggingVy = 0;
float draggingVx = 0;

color backgroundColor = color(250, 250, 255);
color nodeColor = color(180, 225, 255);
color edgeColor = color(10, 50, 80);
color highlightColor = color(250, 200, 130);
color fixedColor = color(20, 120, 175);

void setup() {
  size(1200, 700);
  loadFromFile();

  constants = new HashMap<String,Float>();
  constants.put("HOOKE", HOOKE);
  constants.put("COULOMB", COULOMB);
  constants.put("DAMP", DAMP);
  constants.put("TIME", TIME);
  constants.put("CENTERING", 0.0);
  menu = new Menu();
}

void draw() {
  clear();
  background(backgroundColor);
  
  fill(0);
  text("ENERGY: " + totalE, 5, height - 5);
  if (paused) {
    text("PAUSED", 5, 15);
  }

  if (!paused) {
    calculateForces();
    calculateMovement();
    computeEnergy();
  }
  
  renderGraph();
  
  if (openingMenu) {
    menu.openMenu();
  } else if (closingMenu) {
    menu.closeMenu();
  }
  
  menu.render();
  getConstants();
}

void loadFromFile() {
  String[] lines = loadStrings(filePath);
  numNodes = parseInt(lines[0]);
  numEdges = parseInt(lines[numNodes + 1]);
  nodes = new Node[numNodes + 1];
  edges = new Edge[numEdges];
    
  getNodes(lines);
  getEdges(lines);
}
  
void getNodes(String[] lines) {
  // nodes[0] is empty so that ids map to indices
  nodes[0] = null;
    
  for (int i = 1; i < numNodes + 1; i++) {
    String[] line = split(lines[i], ",");
    int id = parseInt(line[0]);
    float mass = parseFloat(line[1]);
      
    float newX = random(0, width);
    float newY = random(0, height);

    nodes[id] = new Node(newX, newY, mass, id);
  }
}
  
void getEdges(String[] lines) {
  for (int i = numNodes + 2; i < lines.length; i++) {
    String[] line = split(lines[i], ",");
    int n1 = parseInt(line[0]);
    int n2 = parseInt(line[1]);
    float initial = parseFloat(line[2]);
      
    edges[i - (numNodes + 2)] = new Edge(n1, n2, initial);
  }
}

void calculateForces() {
  for (int i = 1; i < nodes.length; i++) {
    if (nodes[i].fixed) {
      continue;
    }
    float fCx = 0;
    float fCy = 0;
    float fHx = 0;
    float fHy = 0;
    
    // electrostatic forces
    for (int j = 1; j < nodes.length; j++) {
      if (i == j) {
        continue;
      }
      
      float d = sqrt(pow((nodes[i].x - nodes[j].x), 2) + pow((nodes[i].y - nodes[j].y), 2));
      if (d < 0 && d > -minParticleDistance) {
        d = -minParticleDistance;
      } else if (d > 0 && d < minParticleDistance) {
        d = minParticleDistance;
      }
      
      float f = COULOMB / (d * d);
      float xPercent = (nodes[i].x - nodes[j].x) / d;
      float yPercent = (nodes[i].y - nodes[j].y) / d;
      
      fCx += f * xPercent;
      fCy += f * yPercent;
    }
    
    // spring forces
    for (int j = 0; j < edges.length; j++) {
      int neighbor;
      if (edges[j].n1 == i) {
        neighbor = edges[j].n2;
      } else if (edges[j].n2 == i) {
        neighbor = edges[j].n1;
      } else {
        continue;
      }
      
      float dx = edges[j].current - edges[j].initial; // positive for stretched out, -> neighbor - me
      float fH = HOOKE * dx;
      float xComponent = (nodes[neighbor].x - nodes[i].x) / edges[j].current;
      float yComponent = (nodes[neighbor].y - nodes[i].y) / edges[j].current;

      fHx += fH * xComponent;
      fHy += fH * yComponent;
    }
    
    float fCenterX = 0;
    float fCenterY = 0;
    
    // centering force
    if (centering) {
      float dX = (width / 2) - nodes[i].x;
      float dy = (height / 2) - nodes[i].y;
      fCenterX = CENTERING * dX;
      fCenterY = CENTERING * dy;
    }
    // damping - method 1
    float v = sqrt((nodes[i].vx * nodes[i].vx) + (nodes[i].vy * nodes[i].vy));
    float fDx = 0;
    float fDy = 0;
    if (v != 0) {
      float xC = nodes[i].vx / v;
      println("v = " + v);
      float yC = nodes[i].vy / v;
      float fDamp = DAMP * v;
      fDx = fDamp * xC * -1;
      fDy = fDamp * yC * -1;
    }
    
    nodes[i].fx = fCx + fHx + fDx + fCenterX;
    nodes[i].fy = fCy + fHy + fDy + fCenterY;
  }
  
}

void calculateMovement() {
  for (int i = 1; i < nodes.length; i++) {
    if (nodes[i].fixed) {
      continue;
    }
    if (i == currentNode && mousePressed && dragging) {
      nodes[i].x = mouseX;
      nodes[i].y = mouseY;
      nodes[i].vx = draggingVx;
      nodes[i].vy = draggingVy;
    } else {
      float ax = nodes[i].fx / nodes[i].mass;
      float ay = nodes[i].fy / nodes[i].mass;
      
      nodes[i].vx += (ax * TIME);
      nodes[i].vy += (ay * TIME);
      
      isAtEdge(i);
    }
  }
  
  computeEnergy();
  
  for (int i = 1; i < nodes.length; i++) {
    if (nodes[i].fixed) {
      continue;
    }
    if (totalE < baseE) {
      nodes[i].vx = 0;
      nodes[i].vy = 0;
    } else {
      nodes[i].x += (nodes[i].vx * TIME);
      nodes[i].y += (nodes[i].vy * TIME);
    }
  }
}

void renderGraph() {
  for (int i = 0; i < edges.length; i++) {
    edges[i].calculateLength();
  }
  
  for (int i = 0; i < edges.length; i++) {
    edges[i].render(edgeColor);
  }
  
  for (int i = 1; i < nodes.length; i++) {
    nodes[i].render(nodeColor);
  }
}

void isAtEdge(int n) {
  if (nodes[n].x + (nodes[n].diameter / 2) > width) {
    nodes[n].x = width - (nodes[n].diameter / 2);
    nodes[n].vx = 0;
  }
  if (nodes[n].x - (nodes[n].diameter / 2) < 0) {
    nodes[n].x = (nodes[n].diameter / 2);
    nodes[n].vx = 0;
  }
  
  if (nodes[n].y + (nodes[n].diameter / 2) > height) {
    nodes[n].y = height - (nodes[n].diameter / 2);
    nodes[n].vy = 0;
  }
  if (nodes[n].y - (nodes[n].diameter / 2) < 0) {
    nodes[n].y = (nodes[n].diameter / 2);
    nodes[n].vy = 0;
  }
}

void mousePressed() {
  if (menu.over()) {
    for (int i = 0; i < numConstants; i++) {
      if (menu.sliders[i].over()) {
        draggingSlider = true;
        currentSlider = i;
      }
    }
  } else {
    for (int i = 1; i < nodes.length; i++) {
      if (nodes[i].overNode()) {
        dragging = true;
        currentNode = i;
        computeEnergy();
      }
    }
  }
}

void mouseDragged() {
  if (draggingSlider) {
    if (mouseX < menu.sliders[currentSlider].x) {
      menu.sliders[currentSlider].v = menu.sliders[currentSlider].x;
    } else if (mouseX > menu.sliders[currentSlider].x + menu.sliders[currentSlider].w) {
      menu.sliders[currentSlider].v = menu.sliders[currentSlider].x + menu.sliders[currentSlider].w;
    } else {
      menu.sliders[currentSlider].v = mouseX;
    }
    
    if (totalE <= baseE) {
      totalE = baseE + 1;
    }
  } else if (dragging) {
    nodes[currentNode].x = mouseX;
    nodes[currentNode].y = mouseY;
    if (!paused) {
      calculateForces();
      calculateMovement();
      computeEnergy();
    }
  }
}

void mouseReleased() {
  if (draggingSlider) {
    draggingSlider = false;
  } else if (dragging) {
    dragging = false;
    if (!paused) {
      calculateForces();
      calculateMovement();
      computeEnergy();
    }
  }
}

void computeEnergy() {
  totalE = 0;
  
  for (int i = 1; i < nodes.length; i++) {
    float vel = sqrt(pow(nodes[i].vx, 2) + pow(nodes[i].vy, 2));
    totalE += (nodes[i].mass * pow(vel, 2)) / 2;
  }
}

void getConstants() {
  HOOKE = constants.get("HOOKE");
  COULOMB = constants.get("COULOMB");
  DAMP = constants.get("DAMP");
  TIME = constants.get("TIME");
  if (constants.get("CENTERING") == 0) {
    centering = false;
  } else {
    centering = true;
  }
}

void mouseClicked() {
  if (mouseButton == RIGHT) {
    for (int i = 1; i < nodes.length; i++) {
      if (nodes[i].overNode()) {
        if (nodes[i].fixed) {
          nodes[i].fixed = false;
        } else {
          nodes[i].fixed = true;
          nodes[i].vx = 0;
          nodes[i].vy = 0;
        }
      }
    }
  } else if (menu.overButton()) {
    if (menu.visible) {
      closingMenu = true;
    } else {
      if (!closingMenu && !openingMenu) {
        openingMenu = true;
      }
    }
  } else if(menu.centering.over() && menu.visible) {
    menu.centering.checked = !menu.centering.checked;
  }
    
}

void keyPressed() {
  if (paused) {
    paused = false;
  } else {
    paused = true;
  }
}
