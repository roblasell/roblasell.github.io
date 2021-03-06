// Visualization Fall 2015
// Final Project: Titanic Passengers
// Steph Cleland & Rob Lasell
// Life expectancy data from http://ourworldindata.org/data/population-growth-vital-statistics/life-expectancy/
// Titanic data from the Encyclopedia Titanica

/* JAVASCRIPT Version */
String birthFilename = "processing/titanic/data/birth.txt";
String deathFilename = "processing/titanic/data/death.txt";
String dataFilename  = "processing/titanic/data/titanic-data.tsv";
String sinkingPic = "processing/titanic/sinking.png";
String font  = "processing/titanic/data/Raleway-Regular.ttf";

String blurb = "Shortly before midnight on April 14, 1912, the RMS Titanic struck an iceberg roughly 400 miles off the coast of Newfoundland. Two and a half hours later, at 2:20 a.m., the ship sank with approximately 1500 people still on board.";

/* Java Version 
String birthFilename = "birth.txt";
String deathFilename = "death.txt";
String dataFilename  = "titanic-data.tsv";
String sinkingPic = "sinking.png";
*/

int DISASTER_YEAR = 1912;
int DISASTER_MONTH = 4;
int DISASTER_DAY = 15;
int disasterNum;

int earliestDay = 17;
int earliestMonth = 5;
int earliestYear = 1837;

int latestDay = 0;
int maxAgeAtDisaster = 0;
int maxAgeInt = 0;
float minArcAngle = 5;
float maxArcAngle = 150;

float widthPercent = 0.9;
float heightPercent = 0.4;
float axisX1;
float axisX2;
float axisY;
float storyY1;
float storyY2;

float pxPerDay;
float arcAngle = 5;
int arcWeight = 2;
int highlightCounter = 0;
int highlightCounterMax = 5;

/* // magenta and something
int survivorRed = 157;
int survivorGreen = 227;
int survivorBlue = 206;
float survivorAlpha = 0.1 * 255;

int victimRed = 217;
int victimGreen = 93;
int victimBlue = 138;
float victimAlpha = 0.15 * 255;

color survivorHighlightColor = color(survivorRed, 255, survivorBlue);
color victimHighlightColor = color(255, victimGreen, victimBlue);
*/

int survivorRed = 133;
int survivorGreen = 241;
int survivorBlue = 255;
float survivorAlpha = 0.1 * 255;

int victimRed = 250;
int victimGreen = 162;
int victimBlue = 85;
float victimAlpha = 0.15 * 255;

color survivorHighlightColor = color(survivorRed, survivorGreen, survivorBlue);
color victimHighlightColor = color(255, 119, 0);

float arcAlpha = 0.8 * 255;

color filterMenuColor = color(48, 69, 87);
color filterTextColor = 255;
color backgroundColor = color(16, 36, 54);
color toolTipColor = filterMenuColor;
color toolTipTextColor = color(255);
color titanicLineColor = color(237, 68, 17);
color axisColor = filterTextColor;
color filterHighlightColor = color(100, 153, 196);

// average life expectancy in 1912
HashMap<Integer, Integer> lifeExpectancies;
HashMap<String, Integer> months;
JSTable table;
FilterMenu filterMenu;
JSTableRow highlightedArc = null;
PImage sinkingImg;
PImage icebergImg;

boolean renderingBlurb;

int rowsFilteredIn = 2153;
int rowsFilteredOut = 0;
int survivorsFilteredIn = 699;
int victimsFilteredIn = 1454;

float canvasWidth = 1200;
float canvasHeight = 800;

int totalVictims = 0;
int totalSurvivors = 0;
int total;

StoryButton[] stories;

void setup() {
  
  setupTable();
  setupMaps();
  
  disasterNum = computeDay("15th April 1912");
  
  inputData();
  makeFilters();
  
  table.sort("death_int");
  
  latestDay += 1000;
  pxPerDay = filterMenu.x * widthPercent / latestDay;
  
  axisX1 = filterMenu.x * ((1 - widthPercent) / 2);
  axisX2 = axisX1 + (filterMenu.x * widthPercent);
  axisY = canvasHeight * heightPercent;
  
  storyY1 = 0.8 * canvasHeight;
  storyY2 = canvasHeight - axisX1;
  
  //console.log("axisX1: " + axisX1 + " axisX2: " + axisX2 + " axisY: " + axisY);
  
  calculateArcs();
  
  size(canvasWidth, canvasHeight);
  
  sinkingImg = loadImage(sinkingPic);
  //icebergImg = loadImage(icebergPic);
  
  renderingBlurb = false;
  
  setupStoryButtons();
  
  background(backgroundColor);
  drawArcs();
  drawAxis();
  filterMenu.render();
  drawImages();
  renderStory();
}

void draw() {
  filterMenu.render();
  drawImages();
  renderBlurb();
  
  checkMouseHover();
  renderStory();
  strokeWeight(0);
}

void drawImages() {
  image(sinkingImg, filterMenu.x + 3, canvasHeight - 132, 150, 150);
  //image(icebergImg, (disasterNum * pxPerDay) + axisX1 - 25, height * 0.1, 50, 50);
}

void drawAxis() {
  strokeWeight(1.5);
  stroke(axisColor);
  line(axisX1, axisY, axisX2, axisY);
  fill(axisColor);
  textSize(8);
  text("1840", (axisX1 - 3) - textWidth("1840"), axisY + 3);
  text("2009", axisX2 + 3, axisY + 3);
  
  // titanic line
  strokeWeight(1.5);
  stroke(titanicLineColor);
  fill(titanicLineColor);
  float top = 70;
  float x = axisX1 + (pxPerDay * disasterNum);
  line(x, storyY1, axisX1 + (pxPerDay * disasterNum), top);
  line(x - 48, top, x + 48, top);
  textSize(14);
  text("15th April 1912", x - 48, top - 7);
  strokeWeight(0);
}

void drawArcs() {
  strokeWeight(arcWeight);
  
  for (int i = table.rows().size() - 1; i >= 0; i--) {
    JSTableRow row = table.getRow(i);
    float angle = getAngle(row);
    if (row.getInt("survived") == 0) {
      stroke(row.getInt("color"), victimAlpha);
      drawArc(row, angle, true);
    } else {
      stroke(row.getInt("color"), survivorAlpha);
      drawArc(row, angle, false);
    }
  }
  
  strokeWeight(0);
}

void drawArc(JSTableRow row, float angle, boolean victim) {
  int birthInt = row.getInt("birth_int");
  
  // logic for 2PI
  float w = pxPerDay * (row.getInt("death_int") - birthInt);
  float midX = (w / 2) + (pxPerDay * birthInt);
  float lifeLength = (disasterNum * pxPerDay) - midX;
  
  // look for the sign of the AngleToad...
  //float sinOfAngleToAdd = (2 * lifeLength) / w;
  //float a = acos(sinOfAngleToAdd);
  // 2PI logic ends
  
  float extraY = 0;
  float d = w;
  
  if (tan(angle / 2) != 0) {
    extraY = w / (2 * tan(angle / 2));
  }
  
  if (sin(angle / 2) != 0) {
    d = w / sin(angle / 2);
  }
  
  float start = (3 * PI / 2) - (angle / 2);
  float end;
  if (victim) {
    end = (3 * PI / 2) + (asin(lifeLength / (d / 2)));
  } else {
    end = (3 * PI / 2) + (angle / 2);
  }
  
  float xLoc = midX + axisX1;
  float yLoc = axisY + extraY;
  
  // flip logic
  if (row.getInt("filtered_out") == 1) {
    yLoc = axisY - extraY;
    float temp = start;
    start = TWO_PI - end;
    end = TWO_PI - temp;
  }
  
  noFill();
  arc(xLoc, yLoc, d, d, start, end);
}

float getAngle(JSTableRow row) {
  int ageInt = row.getInt("death_int") - row.getInt("birth_int");
  float agePercent = (float)ageInt / (float)maxAgeInt;
  
  float angle = ((maxArcAngle - minArcAngle) * agePercent) + minArcAngle;
  
  return radians(angle);
}

void checkMouseHover() {
  for (JSTableRow row : table.rows()) {
    float y = row.getFloat("y");
    float x = row.getFloat("x");
    float d = dist(x, y, mouseX, mouseY);
    float d2 = dist(x, (2 * axisY) - y, mouseX, mouseY);
    float r = row.getFloat("radius");
    if (((int)d >= (int)r - 1 && (int)d <= (int)r + 1 && mouseY <= axisY && (row.getInt("survived") == 1 || mouseX < (axisX1 +(disasterNum * pxPerDay))) && row.getInt("filtered_out") == 0) ||
        ((int)d2 >= (int)r - 1 && (int)d2 <= (int)r + 1 && mouseY > axisY && (row.getInt("survived") == 1 || mouseX < (axisX1 +(disasterNum * pxPerDay))) && row.getInt("filtered_out") == 1)) {
      if (highlightedArc == null) {
        highlightedArc = row;
      } else if (highlightedArc != row) {
        highlightCounter = 0;
        highlightedArc = row;
      } else if (highlightedArc == row) {
        if (highlightCounter == highlightCounterMax) {
          background(backgroundColor);
          filterMenu.render();
          drawArcs();
          drawAxis();
          drawImages();
          //renderStats();
          renderStory();
        }
        highlightCounter++;
        
        if (highlightCounter == highlightCounterMax + 1) {
          strokeWeight(arcWeight);
          
          float angle = getAngle(row);
          if (row.getInt("survived") == 1) {
            stroke(survivorHighlightColor);
            drawArc(row, angle, false);
          } else if (mouseX < (disasterNum * pxPerDay) + axisX1) {
            stroke(victimHighlightColor);
            drawArc(row, angle, true);
          }
          
          drawDateLines(row);
          strokeWeight(0);
          noStroke();
          tooltip(highlightedArc);
        }
      }
      
      return;
    }
  }
  
  if (highlightedArc != null) {
    highlightedArc = null;
    highlightCounter = 0;
    background(backgroundColor);
    filterMenu.render();
    drawArcs();
    drawAxis();
    drawImages();
    //renderStats();
    renderStory();
  }
}

void tooltip(JSTableRow row) {
  String t = "";
  t += row.getString("converted_name");
  
  // profession
  String job = row.getString("job");
  if (!job.equals("")) {
    t += ", a " + job + ",";
  }
  
  t += " was " + row.getString("age") + " when ";
  
  // sex
  if (row.getString("sex").equals("M")) {
    t += "he ";
  } else {
    t += "she ";
  }
  
  // survived
  if (row.getInt("survived") == 1) {
    t += "survived ";
  } else {
    t += "died during ";
  }
  
  t += "the Titanic disaster. ";
  
  if (row.getString("sex").equals("M")) {
    t += "He ";
  } else {
    t += "She ";
  }
  
  int classNum = row.getInt("class");
  if (classNum == 0) {
    t += "was a member of the crew.";
  } else {
    t += "was travelling ";
    
    ArrayList companions = getCompanions(row);
    if (companions.isEmpty()) {
      t += "alone ";
    } else {
      t += "with ";
      int len = companions.size();
      for (int i = 0; i < companions.size(); i++) {
        t += companions.get(i);
        if (i == len - 2) {
          t += " and ";
        } else if (i == len - 1) {
          t += " ";
        } else {
          t += ", ";
        }
      }
    }
    
    if (classNum == 1) {
      t += "in 1st class.";
    } else if (classNum == 2) {
      t += "in 2nd class.";
    } else if (classNum == 3) {
      t += "in 3rd class.";
    }
  }
  
  float boxW = 250;
  float textW = boxW - 14;
  float boxH = ((textWidth(t) / textW) * 20) + 15;
  float textH = boxH - 14;
  
  float boxX = mouseX - (boxW / 2);
  float boxY = mouseY - boxH;
  
  if (row.getInt("filtered_out") == 1) {
    boxY = mouseY + 10;
  }
  
  if (boxX < 0) {
    boxX = 0;
  } else if (boxX > (0.85 * canvasWidth) - boxW) {
    boxX = (0.85 * canvasWidth) - boxW;
  }
  
  fill(toolTipColor, 0.8 * 255);
  rect(boxX, boxY, boxW, boxH, 10);
  
  textSize(12);
  fill(toolTipTextColor);
  text(t, boxX + 7, boxY + 7, textW, textH);
}

ArrayList<String> getCompanions(JSTableRow row) {
  ArrayList<String> companions = new ArrayList<String>();
  
  for (JSTableRow r : table.rows()) {
    String ticket = r.getString("ticket");
    if (ticket.equals(row.getString("ticket"))) {
      String name = r.getString("name");
      String convertedName = r.getString("converted_name");
      
      if (!name.equals(row.getString("name"))) {
        companions.add(convertedName);
      }
    }
  }
  
  return companions;
}

void mouseClicked() {
  if (filterMenu.isOverButton()) {
    for (Filter f : filterMenu.filters) {
      f.selected = false;
    }
    filterTable();
    return;
  }
  
  for (StoryButton sb : stories) {
    if (sb.isOver()) {
      sb.clicked();
      return;
    }
  }
  
  for (Filter f : filterMenu.filters) {
    if (f.isOver()) {
      f.selected = !f.selected;
      filterTable();
    }
  }
}

void filterTable() {
  rowsFilteredIn = 0;
  rowsFilteredOut = 0;
  victimsFilteredIn = 0;
  survivorsFilteredIn = 0;
  
  for (JSTableRow row : table.rows()) {
    String currentCategory = "";
    boolean filtered = false;
    boolean categoryChecked = false;
    boolean standardsMet = false;
    
    for (Filter f : filterMenu.filters) {
      if (!(f.category.equals(currentCategory))) {
        if (categoryChecked && !standardsMet) {
          break;
        }
        categoryChecked = false;
        standardsMet = false;
        currentCategory = f.category;
      }
      
      if (f.selected) {
        categoryChecked = true;
        String rowCategory = row.getString(f.category);
        if ((currentCategory.equals("age") && checkAgeRange(row, f.value)) || rowCategory.equals(f.value)) {
          standardsMet = true;
        }
      }
    }
    
    if (categoryChecked && !standardsMet) {
      rowsFilteredOut++;
      row.setInt("filtered_out", 1);
      filtered = true;
    }
    
    if (!filtered) {
      rowsFilteredIn++;
      row.setInt("filtered_out", 0);
      if (row.getInt("survived") == 1) {
        survivorsFilteredIn++;
      } else {
        victimsFilteredIn++;
      }
    }
  }
  
  background(backgroundColor);
  filterMenu.render();
  drawArcs();
  drawAxis();
  drawImages();
  //renderStats();
  renderStory();
}

boolean checkAgeRange(JSTableRow row, String value) {
  int age = row.getInt("age");
  boolean isInRange;
  if (value.length() == 3) { // "40+"
    isInRange = parseInt(value.substring(0, value.length() - 1)) <= age;
  } else {
    String[] range = split(value, " - ");
    isInRange = (parseInt(range[0]) <= age && parseInt(range[1]) >= age);
  }
  return isInRange; 
}

String convertName(String name) {
  String[] firstAndLast = split(name, ", ");
  String toReturn = firstAndLast[1];
  String[] lastName = split(firstAndLast[0], " ");
  for (String word : lastName) {
    String lower = (word.substring(1, word.length())).toLowerCase();
    toReturn += " " + word.substring(0, 1) + lower;
  }
  return toReturn;
}

void drawDateLines(JSTableRow row) {
  float xBirth = (row.getInt("birth_int") * pxPerDay) + axisX1;
  float y = 220;
  float textY;
  int survived = row.getInt("survived");
  float textAlpha = 0.8 * 255;
  float lineAlpha = 0.5 * 255;
  if (row.getInt("filtered_out") == 0) {
    y = axisY - y;
    textY = y - 5;
  } else {
    y = axisY + y;
    textY = y + 15;
  }
  
  strokeWeight(1.5);
  String birthText = "born " + row.getString("birth_date");
  textSize(12);
  
  if (survived == 1) {
    stroke(survivorHighlightColor, lineAlpha);
    fill(survivorHighlightColor, textAlpha);
    line(xBirth, axisY, xBirth, y);
    line(xBirth - 5, y, xBirth + 5, y);
    text(birthText, xBirth - (textWidth(birthText) / 2) + 2, textY);
    
    String deathText = "died " + row.getString("death_date");
    float xDeath = (row.getInt("death_int") * pxPerDay) + axisX1;
    line(xDeath, axisY, xDeath, y);
    line(xDeath - 5, y, xDeath + 5, y);
    text(deathText, xDeath - (textWidth(deathText) / 2) + 2, textY);
  } else {
    stroke(victimHighlightColor, lineAlpha);
    fill(victimHighlightColor, textAlpha);
    line(xBirth, axisY, xBirth, y);
    line(xBirth - 5, y, xBirth + 5, y);
    text(birthText, xBirth - (textWidth(birthText) / 2) + 2, textY);
    textSize(14);
    float xDeath = axisX1 + (pxPerDay * disasterNum);
    text("died", xDeath - 80, 63);
  }
}

void renderBlurb() {
  float hoverX = axisX1 + (pxPerDay * disasterNum);
  
  float w = 350;
  float h = 60;
  float x = hoverX + 80;
  float y = 70 - (h / 2);
  
  if (mouseX <= hoverX + 53 && mouseX >= hoverX - 53 && mouseY <= 70 && mouseY >= 50) {
    renderingBlurb = true;
    textSize(11);
    fill(toolTipColor);
    noStroke();
    rect(x, y, w, h, 10);
    triangle(x, y + (h / 3), x, y + (h * 2 / 3), x - 20, y + (h / 2));
    fill(toolTipTextColor);
    text(blurb, x + 5, y + 5, w - 10, h - 10);
  } else if (renderingBlurb) {
    renderingBlurb = false;
    fill(backgroundColor);
    noStroke();
    rect(x - 22, y - 2, w + 24, h + 4);
  }
}

void renderStats() {
  if (!(rowsFilteredIn == 0 || rowsFilteredOut == 0)) {
    //float percentIn = (float)rowsFilteredIn * 100 / (float)total;
    //float percentOut = (float)rowsFilteredOut * 100 / (float)total;
    
    float x = canvasWidth * 0.05;
    float y = axisY - 250;
    
    fill(toolTipTextColor);
    textSize(32);
    //text(percentIn + "%", x, y);
    text(rowsFilteredIn + " out of " + totalVictims + " victims and " + totalSurvivors + " survivors", x, y);
  }
}

void renderStory() {
  textSize(20);
  String t1 = "Who were the victims?";
  String t2 = "Who were the survivors?";
  fill(backgroundColor);
  noStroke();
  rect(axisX1 - 2, storyY1 - 50, textWidth(t1) + 4, 49);
  rect(axisX2 - (textWidth(t2) + 2), storyY1 - 50, textWidth(t2) + 4, 49);
  strokeWeight(1.5);
  
  stroke(titanicLineColor);
  fill(backgroundColor);
  rect(axisX1, storyY1, axisX2 - axisX1, storyY2 - storyY1);
  
  textSize(20);
  float h = storyY1 - 10;
  
  fill(victimHighlightColor);
  text(t1, axisX1, h);
  
  fill(survivorHighlightColor);
  text(t2, axisX2 - textWidth(t2), h);
  
  for (StoryButton sb : stories) {
    sb.render();
  }
}