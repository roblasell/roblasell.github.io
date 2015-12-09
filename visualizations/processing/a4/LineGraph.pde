class LineGraph {
  
  float x;
  float y;
  float w;
  float h;
  
  float graphX;
  float graphY;
  float graphW;
  float graphH;
  
  String textX;
  String textY;
  
  float xSpacing;
  
  ArrayList<Trend> trends;
  float currentMax;
  boolean dealingWithMouseClick;
  
  color yearHighlightColor = color(245);//255, 254, 179);
  color yearSelectionColor = color(205, 240, 255);
  color trendHighlightColor = masterHighlightColor;
  
  int hoverIndex;
  
  int highlightedTrend;
  
  LineGraph(float xPos, float yPos, float wid, float hgt) {
    x = xPos;
    y = yPos;
    w = wid;
    h = hgt;
    
    graphX = x + (0.08 * w);
    graphY = y + (0.07 * h);
    graphW = w - graphX;//(2 * (0.07 * w));
    graphH = y + h - ((x + (0.07 * w)) + graphY);
    
    textX = "Year";
    textY = "Funding (dollars)";
    
    highlightedTrend = -1;
    
    trends = new ArrayList<Trend>();
    buildTrends();
    dealingWithMouseClick = false;
    
    xSpacing = graphW / years.size();
  }
  
  void buildTrends() {
    for (int i = 0; i < depts.size(); i++) {
      String discipline = data.findRow(depts.get(i), "PI Department").getString("Discipline");
      Trend t = new Trend(depts.get(i), discipline, this, color(100));
      trends.add(t);
    }
  }
  
  void run() {
    computeMax();
    render();
    renderAxes();
    
    highlightedTrend = -1;
    
    for (int i = 0; i < trends.size(); i++) {
      if (trends.get(i).visible()) {
        if (trends.get(i).dept.equals(highlightedDept)) {
          highlightedTrend = i;
        }
        trends.get(i).render();
      }
    }
    
    if (highlightedTrend != -1) {
      trends.get(highlightedTrend).render();
    }
    
    dealingWithMouseClick = false;
  }
  
  void renderAxes() {
    stroke(230);
    for (int i = 1; i < years.size(); i++) {
      line(graphX + (i * xSpacing), graphY, graphX + (i * xSpacing), graphY + graphH);
    }

    line(graphX, graphY, graphX + graphW, graphY); // top
    line(graphX + graphW, graphY, graphX + graphW, graphY + graphH); // right
    stroke(0);
    line(graphX, graphY, graphX, graphY + graphH); // left
    line(graphX, graphY + graphH, graphX + graphW, graphY + graphH); // bottom
    
    // print tick marks
    textSize(11);
    fill(0);
    float yTick = graphY + (graphH / 11);
    line(graphX - 4, yTick, graphX + 4, yTick);
    String t = "" + millionify(currentMax * 10 / 11);
    text(t, graphX - (textWidth(t) + 6), yTick + 2);
    
    textSize(12);
    float pos = graphX + (xSpacing / 2);
    for (int i = 0; i < years.size(); i++) {
      line(pos, graphY + graphH - 4, pos, graphY + graphH + 4);
      float wid = textWidth(years.get(i));
      text(years.get(i), pos - (wid / 2), graphY + graphH + 16);
      pos += xSpacing;
    }
    
    textSize(16);
    float yTextX = graphX - 10;
    float yTextY = graphY + (graphH / 2) + (textWidth(textY) / 2);
    float xTextX = graphX + (graphW / 2) - (textWidth(textX) / 2);
    float xTextY = graphY + graphH + 40;
    
    text(textX, xTextX, xTextY);
    
    pushMatrix();
    translate(yTextX, yTextY);
    rotate(-HALF_PI);
    translate((-1 * yTextX), (-1 * yTextY));
    text(textY, yTextX, yTextY);
    popMatrix();
  }
  
  void render() {
    int yearIndex = 0;
    hoverIndex = -1;
    for (int i = 0; i < years.size(); i++) {
      if (years.get(i).equals(currentYear)) {
        yearIndex = i;
      }
    }
    
    computeHoverIndex();
    
    if (hoverIndex != -1) {
      fill(yearHighlightColor);
      noStroke();
      rect((hoverIndex * xSpacing) + graphX, graphY, xSpacing, graphH + 22);
      stroke(0);
    }
    
    fill(yearSelectionColor);
    noStroke();
    rect((yearIndex * xSpacing) + graphX, graphY, xSpacing, graphH + 22);
    stroke(0);
  }
  
  boolean over() {
    if (mouseX > graphX && mouseX < graphX + graphW && mouseY > graphY && mouseY < graphY + graphH + 22) {
      return true;
    } else {
      return false;
    }
  }
  
  void computeHoverIndex() {
    for (int i = 0; i < years.size(); i++) {
      if (mouseX > (i * xSpacing) + graphX && mouseX < ((i + 1) * xSpacing) + graphX && mouseY <= graphY + graphH + 22 && mouseY > graphY && clickableYear(i)) {
        hoverIndex = i;
      }
    }
  }
  
  boolean clickableYear(int index) {
    for (int i = 0; i < trends.size(); i++) {
      if (trends.get(i).visible() && trends.get(i).values.get(index) > 0) {
        return true;
      }
    }
    
    return false;
  }
  
  void computeMax() {
    currentMax = 0;
    for (int i = 0; i < trends.size(); i++) {
      if (trends.get(i).max > currentMax && trends.get(i).visible()) {
        currentMax = trends.get(i).max;
      }
    }
    
    currentMax *= 1.10;
  }
}
