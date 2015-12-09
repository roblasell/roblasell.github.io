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
String filePath = "data1.csv";

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
color boxLineColor = color(0);
color boxColor = color(130, 190, 250);
color boxCheckedColor = color(20, 120, 175);
color boxHighlightColor = color(255, 210, 160);

class CheckBox {
  int id;
  float x;
  float y;
  float side;
  float textX;
  float textY;
  String text;
  String constant;
  boolean checked;

  CheckBox(int ID, String con, String t, float xPos, float yPos, float s) {
    id = ID;
    checked = false;
    x = xPos;
    y = yPos;
    side = s;
    text = t;
    constant = con;
    textX = x + side + 10;
    textY = y + side - 3;
  }
  
  void render() {
    stroke(boxLineColor);
    if (over()) {
      fill(boxHighlightColor);
    } else if (checked) {
      fill(boxCheckedColor);
    } else {
      fill(boxColor);
    }
    rectMode(CORNER);
    rect(x, y, side, side);
    
    textSize(14);
    fill(0);
    text(text, textX, textY);
  }
  
  boolean over() {
    if (mouseX > x && mouseX < x + side && mouseY > y && mouseY < y + side) {
      return true;
    } else {
      return false;
    }
  }
  
  void mapConstant() {
    if (checked) {
      constants.put(constant, 1.0);
    } else {
      constants.put(constant, 0.0);
    }
  }
}
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
float menuWidthPercent = 0.2;
float sliderWidthPercent = 0.7;
float buttonHeight = 20;
color menuColor = color(200, 225, 250);
color buttonColor = color(130, 190, 250);
color buttonHighlightColor = color(255, 210, 160);

class Menu {
  float x;
  float y;
  float w;
  float h;
  float changeFactor;
  float maxHeight;
  boolean visible;
  Slider[] sliders;
  CheckBox centering;
  
  Menu() {
    x = width * (1 - menuWidthPercent);
    y = 0;
    w = width * menuWidthPercent;
    h = 0;
    visible = false;
    changeFactor = 6;
    
    sliders = new Slider[numConstants];
    float xPos = x + ((w * (1 - sliderWidthPercent)) / 2);
    
    sliders[0] = new Slider(0, "HOOKE", "Hooke's Constant", xPos, buttonHeight + 70, w * sliderWidthPercent, 20, maxHooke);
    sliders[1] = new Slider(1, "COULOMB", "Coulomb's Constant", xPos, buttonHeight + 140, w * sliderWidthPercent, 20, maxCoulomb);
    sliders[2] = new Slider(2, "DAMP", "Damping Constant", xPos, buttonHeight + 210, w * sliderWidthPercent, 20, maxDamp);
    sliders[3] = new Slider(3, "TIME", "Time", xPos, buttonHeight + 280, w * sliderWidthPercent, 20, maxTime);
    
    centering = new CheckBox(0, "CENTERING", "Centered", xPos, buttonHeight + 330, 17);
    
    maxHeight = buttonHeight + 395;
  }
  
  void render() {
    fill(menuColor);
    rectMode(CORNER);
    rect(x, y, w, h);
    
    if (overButton()) {
      fill(buttonHighlightColor);
    } else {
      fill(buttonColor);
    }
    rect(x, y, w, buttonHeight);
    
    textSize(12);
    fill(0);
    if (!visible && !closingMenu) {
      text("Show Menu", x + 3, y + 15);
    } else if (closingMenu) {
      text("Hide Menu", x + 3, y + 15);
    } else {
      text("Hide Menu", x + 3, y + 15);
      for (int i = 0; i < numConstants; i++) {
        sliders[i].render();
      }
      
      centering.render();
    }
    
    for (int i = 0; i < numConstants; i++) {
      sliders[i].mapConstant();
    }
    
    centering.mapConstant();
  }
  
  boolean overButton() {
    if (mouseX >= x && mouseX <= width && mouseY >= 0 && mouseY <= buttonHeight) {
      return true;
    } else {
      return false;
    }
  }
  
  void openMenu() {
    if (h < maxHeight) {
      h += maxHeight / changeFactor;
    } else {
      h = maxHeight;
      openingMenu = false;
      visible = true;
    }
  }
  
  void closeMenu() {
    if (h > 0) {
      visible = false;
      h -= maxHeight / changeFactor;
    } else {
      h = 0;
      closingMenu = false;
    }
  }
  
  boolean over() {
    if (mouseX >= x && mouseX <= width && mouseY >= 0 && mouseY <= h) {
      return true;
    } else {
      return false;
    }
  }
}
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


