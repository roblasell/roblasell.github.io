class FGData {
  
  ArrayList<FGLink> links;
  ArrayList<FGNode> sponsors;
  ArrayList<FGNode> departments;
  
  String year;
  
  int highlightedSponsor;
  
  FlowGraph parent;
  
  FGData(String y, FlowGraph p) {
    year = y;
    parent = p;
    
    highlightedSponsor = -1;
    
    links = new ArrayList<FGLink>();
    sponsors = new ArrayList<FGNode>();
    departments = new ArrayList<FGNode>();
    
    buildData();
  }
  
  void buildData() {
    StringList tempDepts = new StringList();
    StringList tempSponsors = new StringList();
    StringList tempLinks = new StringList();
    
    for (TableRow row : data.findRows(year, "Year")) {
      String d = row.getString("PI Department");
      String s = row.getString("Sponsor");
      String l = d + "$" + s;
      
      // dept stuff
      
      int dIndex = indexOfNode(tempDepts, d);
      
      if (dIndex == -1) {
        dIndex = tempDepts.size();
        tempDepts.append(d);
        FGNode n = new FGNode(this, d, 150, row.getString("Discipline"));
        departments.add(n);
      }
      
      departments.get(dIndex).value += row.getFloat("Total");
      
      // sponsor stuff
      
      int sIndex = indexOfNode(tempSponsors, s);
      
      if (sIndex == -1) {
        sIndex = tempSponsors.size();
        tempSponsors.append(s);
        FGNode n = new FGNode(this, s, 0, null);
        sponsors.add(n);
      }
      
      sponsors.get(sIndex).value += row.getFloat("Total");
      
      // link stuff
      
      int lIndex = indexOfNode(tempLinks, l);
      
      if (lIndex == -1) {
        lIndex = tempLinks.size();
        tempLinks.append(l);
        FGLink link = new FGLink(departments.get(dIndex), sponsors.get(sIndex), this);
        sponsors.get(sIndex).sponsoredDepts.add(departments.get(dIndex));
        links.add(link);
      }
      
      links.get(lIndex).value += row.getFloat("Total");
    }
   
    // sort sponsors    
    for (int i = 0; i < sponsors.size(); i++) {
      for (int j = 0; j < sponsors.size() - 1; j++) {
        FGNode temp = sponsors.get(j);
        if (sponsors.get(j).value < sponsors.get(j + 1).value) {
          sponsors.set(j, sponsors.get(j + 1));
          sponsors.set(j + 1, temp);
        }
      }
    }
    
    for (int i = 0; i < sponsors.size(); i++) {
      sponsors.get(i).c = colors[i % colors.length];
    }
  }
  
  int indexOfNode(StringList sl, String name) {
    for(int i = 0; i < sl.size(); i++) {
      if (sl.get(i).equals(name)) {
        return i;
      }
    }
    
    return -1;
  }
}
