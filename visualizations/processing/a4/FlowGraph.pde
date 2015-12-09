class FlowGraph {
  
  float x;
  float y;
  float w;
  float h;
  
  float deptNodeDiameter = 50;
  
  HashMap<String,FGData> fgdata;
  FGData currentData;
  
  FlowGraph(float xPos, float yPos, float wid, float hgt) {
    x = xPos;
    y = yPos;
    w = wid;
    h = hgt;
    
    fgdata = new HashMap<String,FGData>();
    
    for (int i = 0; i < years.size(); i++) {
      FGData fgd = new FGData(years.get(i), this);
      fgdata.put(years.get(i), fgd);
    }
  }
  
  void run() {
    stroke(230);
    line(x + (w * 1.0 / 6.0), y, x + (w * 1.0 / 6.0), y + h);
    line(x + (w * 5.0 / 6.0), y, x + (w * 5.0 / 6.0), y + h);
    stroke(0);
    
    currentData = fgdata.get(currentYear);
    
    if (highlightSwitch == 2) {
      highlightedDept = null;
    }
   
    float visibleDepts = 0;
    for (int i = 0; i < currentData.departments.size(); i++) {
      if (isDeptVisible(currentData.departments.get(i))) {
        visibleDepts++;
      }
    }
    
    float deptX = x + (w * 5 / 6);
    float deptYSpacing = h / visibleDepts;
    int displayedDepts = 0;
    
    for (int i = 0; i < currentData.departments.size(); i++) {
      if (isDeptVisible(currentData.departments.get(i))) {
        currentData.departments.get(i).setPos(deptX, y + ((displayedDepts + 0.5) * deptYSpacing), deptNodeDiameter);
        displayedDepts++;
      }
    }
    
    computeSponsorData(100);
    
    for (int i = 0; i < currentData.links.size(); i++) {
      if (isLinkVisible(currentData.links.get(i))) {
        currentData.links.get(i).render();
      }
    }
    
    for (int i = 0; i < currentData.sponsors.size(); i++) {
      if (isSponsorVisible(currentData.sponsors.get(i))) {
        currentData.sponsors.get(i).render();
      }
    }
    
    for (int i = 0; i < currentData.departments.size(); i++) {
      if (isDeptVisible(currentData.departments.get(i))) {
        currentData.departments.get(i).render();
      }
    }
    
    // render graph label
    fill(170);
    textSize(16);
    text("Sponsor", x + (w * (1.0 / 6.0)) - (textWidth("Sponsor") / 2), y + h + 15);
    text("Department", x + (w * (5.0 / 6.0)) - (textWidth("Department") / 2), y + h + 15);
    fill(100);
    text(currentYear, x + (w * 0.5) - (textWidth(currentYear) / 2), y + h + 15);
    fill(0);
  }
  
  boolean isDeptVisible(FGNode dept) {
    return ((currentDisc == null && currentDept == null)
            || (currentDisc != null && currentDisc.equals(dept.disc))
            || (currentDept != null && currentDept.equals(dept.name)));
  }
  
  boolean isSponsorVisible(FGNode sponsor) {
    if (currentDisc == null && currentDept == null) {
      return true;
    }
    
    for (int i = 0; i < sponsor.sponsoredDepts.size(); i++) {
      if ((currentDisc != null && currentDisc.equals(sponsor.sponsoredDepts.get(i).disc))
          || (currentDept != null && currentDept.equals(sponsor.sponsoredDepts.get(i).name))) {
        return true;    
      }
    }
    
    return false;
  }
  
  boolean isLinkVisible(FGLink link) {
    return ((currentDisc == null && currentDept == null)
            || (currentDisc != null && currentDisc.equals(link.dept.disc))
            || (currentDept != null && currentDept.equals(link.dept.name)));
  }
  
  void computeSponsorData(float maxDiameter) {
    float sponsorX = x + (w * 1 / 6);
    float sum = 0;
    float root = -1;
    for (int i = 0; i < currentData.sponsors.size(); i++) {
      if (isSponsorVisible(currentData.sponsors.get(i))) {
        root = log(currentData.sponsors.get(0).value) / log(maxDiameter);
        break;
      }
    }
    
    if (root == -1) {
      println("HELP!");
      exit();
    }
    
    for (int i = 0; i < currentData.sponsors.size(); i++) {
      if (isSponsorVisible(currentData.sponsors.get(i))) {
        float scaledValue = pow(currentData.sponsors.get(i).value, 1 / root);
        sum += scaledValue + FGpadding;
      }
    }
    
    sum -= FGpadding;
    
    if (sum > h) {
      computeSponsorData(maxDiameter - 10);
      return;
    }
    
    float ySum = y + ((h - sum) / 2);
    
    for (int i = 0; i < currentData.sponsors.size(); i++) {
      if (isSponsorVisible(currentData.sponsors.get(i))) {
        float d = pow(currentData.sponsors.get(i).value, 1 / root);

        currentData.sponsors.get(i).setPos(sponsorX, ySum + (d / 2), d);
      
        ySum += d + FGpadding;
        
        color c = currentData.sponsors.get(i).c;
        // set highlighted sponsor
        if (currentData.sponsors.get(i).over()) {
          currentData.highlightedSponsor = i;
          currentData.sponsors.get(i).c = color(red(c), green(c), blue(c), 255); 
          
        // highlighted sponsor got unhighlighted
        } else if (currentData.highlightedSponsor == i && !currentData.sponsors.get(i).over()) {
          currentData.highlightedSponsor = -1;
          currentData.sponsors.get(i).c = color(red(c), green(c), blue(c), 254);
          
        // nobody highlighted
        } else if (currentData.highlightedSponsor == -1) {
          currentData.sponsors.get(i).c = color(red(c), green(c), blue(c), 254);
          
        // somebody's highlighted and it's not me
        } else {
          currentData.sponsors.get(i).c = color(red(c), green(c), blue(c), 70);
        }
      }
    }
  }
  
  boolean over() {
    if (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h) {
      return true;
    } else {
      return false;
    }
  }
  
  // vestigial debugging function
  void printData() {
    for (int i = 0; i < fgdata.size(); i++) {
      println("YEAR: " + years.get(i));
      println("DEPTS:");
      for (int j = 0; j < fgdata.get(i).departments.size(); j++) {
        print(fgdata.get(i).departments.get(j).name + ":" + fgdata.get(i).departments.get(j).value + " ");
      }
      
      println("SPONSORS:");
      for (int j = 0; j < fgdata.get(i).sponsors.size(); j++) {
        print(fgdata.get(i).sponsors.get(j).name + ":" + fgdata.get(i).sponsors.get(j).value + " ");
      }
      
      println("LINKS:");
      for (int j = 0; j < fgdata.get(i).links.size(); j++) {
        println(fgdata.get(i).links.get(j).sponsor.name + " -- " + fgdata.get(i).links.get(j).value + " --> " + fgdata.get(i).links.get(j).dept.name);
      }
    }
  }
}
