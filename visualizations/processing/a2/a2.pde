// Viz Assignment 2: Animated Transitions
// Rob Lasell & Steph Cleland

String path = "processing/a2/bananas.csv";
String [] names;
float [] values;
String xName;
String yName;
float maxY;
float canvasWidth;
String oldState;
String newState;
float pointSize = 6;
int transitionCounter;
float pieStrokeWeight = 4;
boolean pieShrinking = false;
boolean movingLines = false;
boolean rotating = false;
boolean makingArcs = false;
int pieTransitionFactor = 100;
int floopCounter = 0;
int floopSpeed = 10;
int axesFadeSteps = 100;
int highlightColor = color(247, 190, 171);
int buttonAreaColor = color(140, 197, 222);
int waitTime = 500;

float darkRed = 0;
float darkGreen = 103;
float darkBlue = 138;
float lightRed = 202;
float lightGreen = 231;
float lightBlue = 240;

float buttonAreaPercent = 0.8;
float canvasPercent = .8;
float spacingPercent = .011;

Rectangle [] bars;
Rectangle [] buttons;
Point [] points;
Rectangle [] transitionRects;
PieSlice [] slices;
PieSlice [] transitionSlices;

void setup() {
  size(1000, 600);
  canvasWidth = width * canvasPercent;
  oldState = "Bar";
  newState = "Bar";

  buttons = new Rectangle[3];
  buttons[0] = new Rectangle(1.125, .2, 255, "Bar", 0.2, 0.25);
  buttons[1] = new Rectangle(1.125, .5, 255, "Line", 0.2, 0.25);
  buttons[2] = new Rectangle(1.125, .8, 255, "Pie", 0.2, 0.25);
  
  loadStrings();
  getScale();
  
  bars = new Rectangle[values.length];
  transitionRects = new Rectangle[values.length];
  points =  new Point[values.length];
  slices = new PieSlice[values.length];

  float wPercent = (canvasPercent - (bars.length - 1) * spacingPercent) / bars.length;
  float sum = 0;
  float lastAngle = 0;
  
  for (float elem : values) {
    sum += elem;
  }
  
  float redFactor = (lightRed - darkRed) / values.length;
  float greenFactor = (lightGreen - darkGreen) / values.length;
  float blueFactor = (lightBlue - darkBlue) / values.length;
  
  for (int i = 0; i < values.length; i++) {
    float xPercent = ((i + .5) * wPercent) + (1.0 - canvasPercent) / 2 + i * spacingPercent;
    float hPercent = values[i] / maxY * canvasPercent;
    float yPercent = (hPercent + 1 - canvasPercent) / 2;
    
    color c = color(lightRed - (redFactor * i), lightGreen - (greenFactor * i), lightBlue - (blueFactor * i));
    
    bars[i] = new Rectangle(xPercent, 1 - yPercent, c, names[i] + ", " + values[i], wPercent, hPercent);
    transitionRects[i] = new Rectangle(xPercent, 1 - yPercent, c, names[i] + ", " + values[i], wPercent, hPercent);
    points[i] = new Point(bars[i].x, (bars[i].y - bars[i].hgt / 2) + (pointSize / 2), bars[i].text, bars[i].c);
    
    float diameter = min((height / 3) * 2, (width / 3) * (2 * canvasPercent));
    float angle = radians((values[i] / sum) * 360);
    slices[i] = new PieSlice((width / 2) * canvasPercent, height / 2, angle, lastAngle, diameter, bars[i].c);
    lastAngle += angle;
  }
  
}

void draw() {
  clear();
  background(255);
  
  determineTransition();

  // grey button area
  fill(buttonAreaColor);
  noStroke();
  rectMode(CORNER);
  rect(canvasWidth, 0, width * (1 - buttonAreaPercent), height);
  stroke(0);
  
  // draw buttons
  drawButtons();
}

void determineTransition() {
  if (!oldState.equals(newState)) {
      if (oldState == "Bar" && newState == "Line") {
        barToLine();
      } else if (oldState == "Line" && newState == "Bar") {
        lineToBar();
      } else if (oldState == "Bar" && newState == "Pie") {
        barToPie();
      } else if (oldState == "Line" && newState == "Pie") {
        lineToBar();
      } else if (oldState == "Pie" && newState == "Bar") {
        pieToBar();
      } else if (oldState == "Pie" && newState == "Line") {
        pieToBar();
      }
  } else {
    if (newState == "Bar") {
      drawBarChart();
      rectangleToolTips();
    } else if (newState == "Line") {
      drawLineChart();
    } else if (newState == "Pie") {
      drawPieChart();
      mouseOverSection();
    }
  }
}

void drawBarChart() {
  buildAxes(0);
  
  for (int i = 0; i < bars.length; i++) {
    bars[i].render();
    if (bars[i].overRect()) {
      noStroke();
      fill(highlightColor);
      rect(bars[i].x, bars[i].y, bars[i].wid, bars[i].hgt);
      stroke(0);
    }
  }
}

void buildAxes(color c) {
  strokeWeight(1);
  stroke(c);
  line(.09 * canvasWidth, .07 * height, .09 * canvasWidth, .9 * height);
  line(.09 * canvasWidth, .9 * height, .92 * canvasWidth, .9 * height);
  
  textAlign(CENTER, CENTER);
  fill(c);
  float yTextX = .045 * canvasWidth;
  float yTextY = .5 * height;
  text(xName, .5 * canvasWidth, .95 * height);
  pushMatrix();
  translate(yTextX, yTextY);
  rotate(-HALF_PI);
  translate((-1 * yTextX), (-1 * yTextY));
  text(yName, yTextX, yTextY);
  popMatrix();
}

void drawLineChart() {
  buildAxes(0);
  
  for (int i = 0; i < points.length; i++) {
    if (i < points.length - 1) {
      stroke(points[i].c);
      line(points[i].x, points[i].y, points[i + 1].x, points[i + 1].y);
    }
    points[i].render();
  }
}

void drawPieChart() {
  for (int i = 0; i < slices.length; i++) {
    strokeWeight(2);
    slices[i].render();
  }
}

void loadStrings() {
  String [] lines = loadStrings(path);
  String [] firstLine = split(lines[0], ",");
  xName = firstLine[0];
  yName = firstLine[1];
  names = new String [lines.length - 1];
  values = new float [lines.length - 1];
  
  for (int i = 1; i < lines.length; i++) {
    String [] row = split(lines[i], ",");
    names[i - 1] = row[0];
    values[i - 1] = parseFloat(row[1]);
  }
}

void getScale() {
  maxY = 0;
  
  for (int i = 0; i < values.length; i++) {
    if (maxY < values[i]) {
      maxY = values[i];
    }
  }
}

void drawButtons() {
  for (int i = 0; i < buttons.length; i++) {
    buttons[i].render();
    if (buttons[i].overRect() && newState == oldState && newState != buttons[i].text) {
      noStroke();
      fill(highlightColor);
      rect(buttons[i].x, buttons[i].y, buttons[i].wid, buttons[i].hgt);
      stroke(0);
    }
    textAlign(CENTER, CENTER);
    textSize(20);
    if (newState == buttons[i].text) {
      fill(255);
    } else {
      fill(0);
    }
    text(buttons[i].text, buttons[i].x, buttons[i].y);
  }
}

void mouseClicked() {
  for (int i = 0; i < buttons.length; i++) {
    if (buttons[i].overRect() && oldState == newState) {
      newState = buttons[i].text;
    }
  }
}

void barToLine() {
  buildAxes(0);
  boolean finishedShrinking = true;
  
  for (int i = 0; i < transitionRects.length; i++) {
    float shrinkFactor = (bars[i].hgt - pointSize) / 100;
    if (transitionRects[i].hgt - shrinkFactor < pointSize) {
      transitionRects[i].hgt = pointSize;
      transitionRects[i].y = points[i].y;
    } else {
      transitionRects[i].hgt -= shrinkFactor;
      transitionRects[i].y -= shrinkFactor / 2;
      finishedShrinking = false;
    }
    transitionRects[i].render();
  }
  
  if (finishedShrinking) {
    boolean horizontalShrinkingDone = true;
    for (int i = 0; i < transitionRects.length; i++) {
      float shrinkFactor = (bars[i].wid - pointSize) / 100;
      if (transitionRects[i].wid - shrinkFactor < pointSize) {
        transitionRects[i].wid = pointSize;
        transitionRects[i].x = points[i].x;
      } else {
        transitionRects[i].wid -= shrinkFactor;
        horizontalShrinkingDone = false;
      }
      transitionRects[i].render();
    }
    
    if (horizontalShrinkingDone) {
      for (int i = 0; i < points.length - 1; i++) {
        float xGrowthFactor = (points[i + 1].x - points[i].x) / 100;
        float yGrowthFactor = (points[i + 1].y - points[i].y) / 100;
        float x = points[i].x + (transitionCounter * xGrowthFactor);
        float y = points[i].y + (transitionCounter * yGrowthFactor);
       
        stroke(points[i].c);      
        line(points[i].x, points[i].y, x, y);
      }
      
      transitionCounter++;
      if (transitionCounter == 100) {
        oldState = "Line";
        transitionCounter = 0;
      }
    }
  }
}

void lineToBar() {
  buildAxes(0);
  
  if (transitionCounter < 100) {
    for (int i = 0; i < points.length - 1; i++) {
      points[i].render();
      float xShrinkFactor = (points[i].x - points[i + 1].x) / 100;
      float yShrinkFactor = (points[i].y - points[i + 1].y) / 100;
      float x = points[i + 1].x + (transitionCounter * xShrinkFactor);
      float y = points[i + 1].y + (transitionCounter * yShrinkFactor);
         
      stroke(points[i].c);      
      line(points[i].x, points[i].y, x, y);
    }
    points[points.length - 1].render();
    transitionCounter++;
  } else {
    boolean horizontalGrowthDone = true;
    
    for (int i = 0; i < transitionRects.length; i++) {
      float growthFactor = (bars[i].wid - pointSize) / 100;
      if (transitionRects[i].wid + growthFactor >= bars[i].wid) {
        transitionRects[i].wid = bars[i].wid;
        transitionRects[i].x = bars[i].x;
      } else {
        transitionRects[i].wid += growthFactor;
        horizontalGrowthDone = false;
      }
      transitionRects[i].render();
    }
    
    if (horizontalGrowthDone) {
      boolean finishedGrowing = true;
      for (int i = 0; i < transitionRects.length; i++) {
        float growthFactor = (bars[i].hgt - pointSize) / 100;
        if (transitionRects[i].hgt + growthFactor >= bars[i].hgt) {
          transitionRects[i].hgt = bars[i].hgt;
          transitionRects[i].y = bars[i].y;
        } else {
          transitionRects[i].hgt += growthFactor;
          transitionRects[i].y += growthFactor / 2;
          finishedGrowing = false;
        }
        transitionRects[i].render();
      }
      
      if (finishedGrowing) {
        oldState = "Bar";
        transitionCounter = 0;
        if (newState == "Pie") {
          wait(waitTime);
        }
      }
    }
  }
}

void barToPie() {
  if (!pieShrinking) {
    for (int i = 0; i < transitionRects.length; i++) {
      float shrinkFactor = (bars[i].wid - pieStrokeWeight) / 100;
      if (transitionRects[i].wid - shrinkFactor < pieStrokeWeight) {
        transitionRects[i].wid = pieStrokeWeight;
        transitionRects[i].x = points[i].x;
        pieShrinking = true;
      } else {
        transitionRects[i].wid -= shrinkFactor;
        pieShrinking = false;
      }
      transitionRects[i].render();
    }
  }
  
  if (pieShrinking && !movingLines) {
    for (int i = 0; i < transitionRects.length; i++) {
      float z = slices[i].start + (slices[i].angle / 2); // angle of the line through the circle's center, bisecting the final rect
      float finalX = (canvasWidth / 2) + (cos(z) * (slices[i].diameter / 2));
      float finalY = (height / 2) + (sin(z) * (slices[i].diameter / 2));
      
      transitionRects[i].x = (((finalX - bars[i].x) / pieTransitionFactor) * transitionCounter) + bars[i].x;
      transitionRects[i].y = (((finalY - bars[i].y) / pieTransitionFactor) * transitionCounter) + bars[i].y;
      transitionRects[i].hgt = (((slices[i].circ - bars[i].hgt) / pieTransitionFactor) * transitionCounter) + bars[i].hgt;
      
      transitionRects[i].render();
    }
    transitionCounter++;
    if (transitionCounter == pieTransitionFactor) {
      movingLines = true;
      transitionCounter = 0;
    }
  }
  
  if (movingLines && !rotating) {
    for (int i = 0; i < transitionRects.length; i++) {
      float z = slices[i].start + (slices[i].angle / 2); // angle of the line through the circle's center, bisecting the final rect
      float finalAngle = (z + (PI / 2)) % (2 * PI);
      
      if (finalAngle > PI && finalAngle < 3 * (PI / 2)) {
        finalAngle -= PI;
      } else if (finalAngle < 2 * PI && finalAngle > 3 * (PI / 2)) {
        finalAngle -= PI;
      }
      
      float rotation = (finalAngle - (PI / 2)) / pieTransitionFactor;
      float angle = (rotation * transitionCounter);
      
      if (i == 10) {
        println(degrees(angle));
      }
      
      pushMatrix();
      translate(transitionRects[i].x, transitionRects[i].y);
      rotate(angle);
      translate(-transitionRects[i].x, -transitionRects[i].y);
      
      transitionRects[i].render();
      
      popMatrix();
    }
    transitionCounter++;
    if (transitionCounter == pieTransitionFactor) {
      rotating = true;
      transitionCounter = 0;
    }
  }
  
  if (rotating && !makingArcs) {
    for (int i = 0; i < slices.length; i++) {
      float increment = slices[i].angle / pieTransitionFactor;
      float currentRadius = slices[i].circ / (increment * transitionCounter);
      float R = currentRadius - (slices[i].diameter / 2);
      float currentStart = slices[i].start + (((pieTransitionFactor - transitionCounter) * increment) / 2);
      float currentAngle = increment * transitionCounter;
      
      float z = currentStart + (currentAngle / 2); // angle of the line through the circle's center, bisecting the final rect
      float finalX = (canvasWidth / 2) - (cos(z) * R);
      float finalY = (height / 2) - (sin(z) * R);
      
      stroke(slices[i].c);
      strokeWeight(pieStrokeWeight);
      noFill();
      arc(finalX, finalY, currentRadius * 2, currentRadius * 2, currentStart, currentStart + currentAngle, OPEN);
    }
    transitionCounter++;
    if (transitionCounter == pieTransitionFactor) {
      makingArcs = true;
      transitionCounter = 1;
    }
  }
  
  if (makingArcs) {    
    drawPieChart();
    floopIn();
    
    transitionCounter++;
    
    if (transitionCounter == floopSpeed) {
      transitionCounter = 0;
      floopCounter++;
    }
    
    if (floopCounter == slices.length) {
      transitionCounter = floopSpeed - 1;
      floopCounter--;
      oldState = "Pie";
      pieShrinking = false;
      movingLines = false;
      rotating = false;
      makingArcs = false;
    }
  }
}

void floopIn() {
  float currentDiameter = (slices[floopCounter].diameter / floopSpeed) * (floopSpeed - transitionCounter);
  
  float coveredAngleStart = slices[floopCounter].start + slices[floopCounter].angle;
  float coveredDiameter = slices[0].diameter - (pieStrokeWeight * 2);
  
  fill(255);
  noStroke();
  arc(canvasWidth / 2, height / 2, coveredDiameter, coveredDiameter, coveredAngleStart, 2 * PI);
  arc(canvasWidth / 2, height / 2, currentDiameter, currentDiameter, slices[floopCounter].start, coveredAngleStart);
}

void pieToBar() {
  if (!makingArcs) {
    drawPieChart();
    floopIn();
    
    transitionCounter--;
    
    if (transitionCounter == 0) {
      transitionCounter = floopSpeed - 1;
      floopCounter--;
    }
    
    if (floopCounter < 0) {
      makingArcs = true;
      floopCounter = 0;
      transitionCounter = pieTransitionFactor - 1;
    }
  }
  
  if (makingArcs && !rotating) {
    for (int i = 0; i < slices.length; i++) {
      float increment = slices[i].angle / pieTransitionFactor;
      float currentRadius = slices[i].circ / (increment * transitionCounter);
      float R = currentRadius - (slices[i].diameter / 2);
      float currentStart = slices[i].start + (((pieTransitionFactor - transitionCounter) * increment) / 2);
      float currentAngle = increment * transitionCounter;
      
      float z = currentStart + (currentAngle / 2); // angle of the line through the circle's center, bisecting the final rect
      float finalX = (canvasWidth / 2) - (cos(z) * R);
      float finalY = (height / 2) - (sin(z) * R);
      
      stroke(slices[i].c);
      strokeWeight(pieStrokeWeight);
      noFill();
      arc(finalX, finalY, currentRadius * 2, currentRadius * 2, currentStart, currentStart + currentAngle, OPEN);
    }
    transitionCounter--;
    if (transitionCounter == 0) {
      rotating = true;
      transitionCounter = pieTransitionFactor - 1;
    }
  }
  
  if (rotating && !movingLines) {
    for (int i = 0; i < transitionRects.length; i++) {
      float z = slices[i].start + (slices[i].angle / 2); // angle of the line through the circle's center, bisecting the final rect
      float finalAngle = (z + (PI / 2)) % (2 * PI);
      
      if (finalAngle > PI && finalAngle < 3 * (PI / 2)) {
        finalAngle -= PI;
      } else if (finalAngle < 2 * PI && finalAngle > 3 * (PI / 2)) {
        finalAngle -= PI;
      }
      
      float rotation = (finalAngle - (PI / 2)) / pieTransitionFactor;
      float angle = (rotation * transitionCounter);
      
      pushMatrix();
      translate(transitionRects[i].x, transitionRects[i].y);
      rotate(angle);
      translate(-transitionRects[i].x, -transitionRects[i].y);
      
      transitionRects[i].render();
      
      popMatrix();
    }
    transitionCounter--;
    if (transitionCounter == 0) {
      movingLines = true;
      transitionCounter = pieTransitionFactor - 1;
    }
  }
  
  if (movingLines && !pieShrinking) {
    for (int i = 0; i < transitionRects.length; i++) {
      float z = slices[i].start + (slices[i].angle / 2); // angle of the line through the circle's center, bisecting the final rect
      float finalX = (canvasWidth / 2) + (cos(z) * (slices[i].diameter / 2));
      float finalY = (height / 2) + (sin(z) * (slices[i].diameter / 2));
      
      transitionRects[i].x = (((finalX - bars[i].x) / pieTransitionFactor) * transitionCounter) + bars[i].x;
      transitionRects[i].y = (((finalY - bars[i].y) / pieTransitionFactor) * transitionCounter) + bars[i].y;
      transitionRects[i].hgt = (((slices[i].circ - bars[i].hgt) / pieTransitionFactor) * transitionCounter) + bars[i].hgt;
      
      transitionRects[i].render();
    }
    transitionCounter--;
    if (transitionCounter == 0) {
      pieShrinking = true;
    }
  }
  
  if (pieShrinking) {
    boolean doneMakingBar = true;
    for (int i = 0; i < transitionRects.length; i++) {
      float growthFactor = (bars[i].wid - pieStrokeWeight) / 100;
      if (transitionRects[i].wid + growthFactor > bars[i].wid) {
        transitionRects[i].wid = bars[i].wid;
        transitionRects[i].x = bars[i].x;
        doneMakingBar = true;
      } else {
        transitionRects[i].wid += growthFactor;
        doneMakingBar = false;
      }
      transitionRects[i].render();
    }
    
    if (doneMakingBar) {
      oldState = "Bar";
      pieShrinking = false;
      movingLines = false;
      rotating = false;
      makingArcs = false;
      if (newState == "Line") {
        drawBarChart();
        wait(waitTime);
      }
    }
  }
}

void mouseOverSection() {
  float mouseAngle = calculateMouseAngle();
  
  for (int i = 0; i < slices.length; i++) {
    float distFromCenter = sqrt(pow(abs(mouseX - (canvasWidth / 2)), 2) + pow(abs(mouseY - (height / 2)), 2));
    if (mouseAngle > slices[i].start && mouseAngle < slices[i].start + slices[i].angle && distFromCenter <= slices[i].diameter / 2) {
      fill(highlightColor);
      noStroke();
      arc(canvasWidth / 2, height / 2, slices[i].diameter, slices[i].diameter, slices[i].start, slices[i].start + slices[i].angle, PIE);
      
      fill(0);
      textSize(12);
      textAlign(CORNER, CORNER);
      text(names[i] + ", " + values[i], mouseX, mouseY);
    }
  }
}

float calculateMouseAngle() {
  float angle = atan2(mouseY - (height / 2), mouseX - (canvasWidth / 2));
  if (angle < 0) {
    angle = (2 * PI) + angle;
  }
  
  return angle;
}

void rectangleToolTips() {
  for (int i = 0; i < bars.length; i++) {
    if (bars[i].overRect()) {
      fill(0);
      textSize(12);
      textAlign(CORNER, CORNER);
      text(names[i] + ", " + values[i], mouseX, mouseY);
    }
  }
}

void wait(int delay)
{
  int time = millis();
  while(millis() - time <= delay);
}
