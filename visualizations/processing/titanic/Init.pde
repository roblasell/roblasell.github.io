int randomAgeRange = 15;

void setupTable() {
  table = new JSTable();
  table.addColumn("id");
  table.addColumn("age");
  table.addColumn("name");
  table.addColumn("sex");
  table.addColumn("birth_date");
  table.addColumn("death_date");
  table.addColumn("birth_int");
  table.addColumn("death_int");
  table.addColumn("class");
  table.addColumn("ticket");
  table.addColumn("survived");
  table.addColumn("job");
  table.addColumn("color");
  table.addColumn("x");
  table.addColumn("y");
  table.addColumn("radius");
  table.addColumn("filtered_out");
  table.addColumn("converted_name");
  table.addColumn("true_death_int");
}

void setupMaps() {
  months = new HashMap<String, Integer>();
  months.put("January", 1);
  months.put("February", 2);
  months.put("March", 3);
  months.put("April", 4);
  months.put("May", 5);
  months.put("June", 6);
  months.put("July", 7);
  months.put("August", 8);
  months.put("September", 9);
  months.put("October", 10);
  months.put("November", 11);
  months.put("December", 12);
  
  lifeExpectancies = new HashMap<Integer, Integer>();
  lifeExpectancies.put(0, 53);
  lifeExpectancies.put(1, 62);
  lifeExpectancies.put(2, 63);
  lifeExpectancies.put(3, 64);
  lifeExpectancies.put(4, 65);
  lifeExpectancies.put(5, 66);
  lifeExpectancies.put(6, 67);
  lifeExpectancies.put(7, 68);
  lifeExpectancies.put(8, 69);
  lifeExpectancies.put(9, 70);
  lifeExpectancies.put(10, 71);
  lifeExpectancies.put(11, 73);
  lifeExpectancies.put(12, 75);
  lifeExpectancies.put(13, 77);
  lifeExpectancies.put(14, 79);
  lifeExpectancies.put(15, 82);
  lifeExpectancies.put(16, 85);
  lifeExpectancies.put(17, 89);
  lifeExpectancies.put(18, 93);
}

void inputData() {
  HashMap<String,String> deaths = new HashMap<String,String>();
  HashMap<String,String> births = new HashMap<String,String>();
  
  String[] deathInput = loadStrings(deathFilename);
  for (int i = 0; i < deathInput.length; i++) {
    String[] line = split(deathInput[i], " - ");
    deaths.put(line[0], line[1]);
    //println(line[0] + " died on " + line[1]);
  }
  
  String[] birthInput = loadStrings(birthFilename);
  for (int i = 0; i < birthInput.length; i++) {
    String[] line = split(birthInput[i], " - ");
    births.put(line[0], line[1]);
  }
  
  String[] lines = loadStrings(dataFilename);
  int rowCounter = 0;
  
  for (int i = 1; i < lines.length; i++) {
    String[] line = split(lines[i], "\t");
    
    int age =  parseInt(line[1]);
    if (age > maxAgeAtDisaster) {
      maxAgeAtDisaster = age;
    }
    
    if (line[1].equals("")) {
      continue;
    }
    
    JSTableRow newRow = table.addRow();
    
    newRow.setInt("id", rowCounter++);
    newRow.setString("name", line[0]);
    newRow.setString("converted_name", convertName(line[0]));
    newRow.setString("sex", line[8]);
    newRow.setInt("survived", parseInt(line[7]));
    newRow.setString("job", line[5]);
    newRow.setInt("filtered_out", 0);
    
    String classString = line[2];
    int classInt;
    
    /* JAVASCRIPT */
    String classChar = classString.substring(0, 1);
    //the line below is JavaScript, not Java!
    if (classChar.match(/[A-Z]/i)) {
      classInt = 0;
    } else {
      classInt = parseInt(classChar);
    }
    
    /* NONJAVASCRIPT
    char classChar = (classString.toCharArray())[0];
    if (Character.isLetter(classChar)) {
      classInt = 0;
    } else {
      classInt = Character.getNumericValue(classChar);
    }
    */
    
    newRow.setInt("class", classInt);
    
    String[] ticketData = split(line[3], " ");
    newRow.setString("ticket", ticketData[0]);
    
    String birth_date = births.get(line[0]);
    String death_date = deaths.get(line[0]);
    
    if (birth_date == null) {
      birth_date = "1st January " + (DISASTER_YEAR - age);
    }
    
    if (death_date == null || line[7].equals("0")) {
      int randomness = (int)(Math.random() * randomAgeRange) - (int)(randomAgeRange / 2);
      int year = parseInt(birth_date.substring(birth_date.length() - 4, birth_date.length())) + lifeExpectancies.get((int)(age / 5)) + randomness;
      
      death_date = birth_date.substring(0, birth_date.length() - 4) + year;
    }
    
    newRow.setInt("age",age);
    
    int deathInt = computeDay(death_date);
    int birthInt = computeDay(birth_date);
    if (deathInt - birthInt > maxAgeInt) {
      maxAgeInt = deathInt - birthInt;
    }
    
    newRow.setInt("birth_int", birthInt);
    newRow.setInt("death_int", deathInt);
    
    newRow.setString("birth_date", birth_date);
    newRow.setString("death_date", death_date);
    
    int variation = 80;
    
    if (line[7].equals("0")) {
      int r = ((int)(Math.random() * variation) - (int)(variation / 2)) + victimRed;
      int g = ((int)(Math.random() * variation) - (int)(variation / 2)) + victimGreen;
      int b = ((int)(Math.random() * variation) - (int)(variation / 2)) + victimBlue;
      newRow.setInt("true_death_int", disasterNum);
      newRow.setInt("color", color(r, g, b));
    } else {
      int r = ((int)(Math.random() * variation) - (int)(variation / 2)) + survivorRed;
      int g = ((int)(Math.random() * variation) - (int)(variation / 2)) + survivorGreen;
      int b = ((int)(Math.random() * variation) - (int)(variation / 2)) + survivorBlue;
      newRow.setInt("true_death_int", deathInt);
      newRow.setInt("color", color(r, g, b));
    }
  }
  
  for (JSTableRow row : table.rows()) {
    //println(row.getString("name") + " " + row.getString("death_date"));
  }
}

int computeDay(String date) {
  int toReturn = 0;
  String[] parts = split(date, " ");
  
  if (parts.length == 2) {
    String m = parts[0];
    String y = parts[1];
    parts = new String[3];
    parts[2] = y;
    parts[1] = m;
    parts[0] = "1st";
  }
  
  int day = parseInt(parts[0].substring(0, parts[0].length() - 2));
  int month = months.get(parts[1]);
  int year = parseInt(parts[2]);
  
  toReturn += 365 * (year - earliestYear);
  toReturn += 31 * (month - earliestMonth);
  toReturn += day - earliestDay;

  if (toReturn > latestDay) {
    latestDay = toReturn;
  }

  return toReturn;
}

void calculateArcs() {
  for (int i = table.rows().size() - 1; i >= 0; i--) {
    JSTableRow row = table.getRow(i);
    float angle = getAngle(row);
    calculateArc(row, angle);
  }
}

void calculateArc(JSTableRow row, float angle) {
  int birthInt = row.getInt("birth_int");
  
  float w = pxPerDay * (row.getInt("death_int") - birthInt);
  float midX = (w / 2) + (pxPerDay * birthInt);
  
  float extraY = 0;
  float d = w;
  
  if (tan(angle / 2) != 0) {
    extraY = w / (2 * tan(angle / 2));
  }
  
  if (sin(angle / 2) != 0) {
    d = w / sin(angle / 2);
  }
  
  row.setFloat("x", midX + axisX1);
  row.setFloat("y", axisY + extraY);
  row.setFloat("radius", d / 2);
}

float menuPadding = 15;

void makeFilters() {
  filterMenu = new FilterMenu(canvasWidth * 0.85, 0 + menuPadding, canvasWidth * 0.15 - menuPadding, canvasHeight - (menuPadding * 2));
  
  float currentHeight = 0.1 * (canvasHeight * 0.9);
  float filterHeight = 15;
  float filterX = 0.865 * canvasWidth;
  int i = 0;
  
  i++; // sex
  filterMenu.addFilter(filterX, currentHeight + (filterHeight * 2 * i++), filterHeight, filterHeight, "Male", "M", "sex");
  filterMenu.addFilter(filterX, currentHeight + (filterHeight * 2 * i++), filterHeight, filterHeight, "Female", "F", "sex");
  i++; // class
  filterMenu.addFilter(filterX, currentHeight + (filterHeight * 2 * i++), filterHeight, filterHeight, "1st Class", "1", "class");
  filterMenu.addFilter(filterX, currentHeight + (filterHeight * 2 * i++), filterHeight, filterHeight, "2nd Class", "2", "class");
  filterMenu.addFilter(filterX, currentHeight + (filterHeight * 2 * i++), filterHeight, filterHeight, "3rd Class", "3", "class");
  filterMenu.addFilter(filterX, currentHeight + (filterHeight * 2 * i++), filterHeight, filterHeight, "Crew", "0", "class");
  i++; // age
  filterMenu.addFilter(filterX, currentHeight + (filterHeight * 2 * i++), filterHeight, filterHeight, "0 - 18", "0 - 18", "age");
  filterMenu.addFilter(filterX, currentHeight + (filterHeight * 2 * i++), filterHeight, filterHeight, "19 - 39", "19 - 39", "age");
  filterMenu.addFilter(filterX, currentHeight + (filterHeight * 2 * i++), filterHeight, filterHeight, "40+", "40+", "age");
  i++; // survived
  filterMenu.addFilter(filterX, currentHeight + (filterHeight * 2 * i++), filterHeight, filterHeight, "Yes", "1", "survived");
  filterMenu.addFilter(filterX, currentHeight + (filterHeight * 2 * i++), filterHeight, filterHeight, "No", "0", "survived");
}

void setupStoryButtons() {
  stories = new StoryButton[6];
  
  float storyBoxHeight = storyY2 - storyY1;
  float margin = 20;
  float w = ((axisX2 - axisX1) - (7 * margin)) / 6;
  float currentX = axisX1 + margin;
  
  stories[0] = new StoryButton(currentX, storyY1 + margin, w, storyBoxHeight - (margin * 2), "a label", victimHighlightColor);
  currentX += w + margin;
  stories[1] = new StoryButton(currentX, storyY1 + margin, w, storyBoxHeight - (margin * 2), "a label", victimHighlightColor);
  currentX += w + margin;
  stories[2] = new StoryButton(currentX, storyY1 + margin, w, storyBoxHeight - (margin * 2), "a label", victimHighlightColor);
  currentX += w + margin;
  stories[3] = new StoryButton(currentX, storyY1 + margin, w, storyBoxHeight - (margin * 2), "a label", survivorHighlightColor);
  currentX += w + margin;
  stories[4] = new StoryButton(currentX, storyY1 + margin, w, storyBoxHeight - (margin * 2), "a label", survivorHighlightColor);
  currentX += w + margin;
  stories[5] = new StoryButton(currentX, storyY1 + margin, w, storyBoxHeight - (margin * 2), "a label", survivorHighlightColor);

  // SET FILTERS HERE
}