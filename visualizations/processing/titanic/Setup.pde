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
    
    if (line[1].equals("")) {
      continue;
    }
    
    JSTableRow newRow = table.addRow();
    
    newRow.setInt("id", rowCounter++);
    newRow.setString("name", line[0]);
    newRow.setString("sex", line[8]);
    newRow.setInt("survived", parseInt(line[7]));
    newRow.setString("job", line[5]);
    
    String classString = line[2];
    String classChar = classString.substring(0, 1);
    //char classChar = (classString.toCharArray())[0];
    int classInt;
    //if (Character.isLetter(classChar)) {
    //the line below is JavaScript, not Java!
    if (classChar.match(/[A-Z]/i)) {
      classInt = 0;
    } else {
      //classInt = Character.getNumericValue(classChar);
      classInt = parseInt(classChar);
    }
    newRow.setInt("class", classInt);
    
    String[] ticketData = split(line[3], " ");
    newRow.setString("ticket", ticketData[0]);
    
    String birth_date = births.get(line[0]);
    String death_date = deaths.get(line[0]);
    
    if (birth_date == null) {
      birth_date = "1st January " + (DISASTER_YEAR - age);
    }
    
    if (death_date == null || line[7].equals("0")) {
      int year = parseInt(birth_date.substring(birth_date.length() - 4, birth_date.length())) + lifeExpectancies.get(age / 5);
      
      death_date = birth_date.substring(0, birth_date.length() - 4) + year;
    }
    
    newRow.setInt("age",age);
    
    newRow.setInt("birth_int", computeDay(birth_date));
    newRow.setInt("death_int", computeDay(death_date));
    
    newRow.setString("birth_date", birth_date);
    newRow.setString("death_date", death_date);
  }
  
  for (JSTableRow row : table.rows()) {
    println(row.getString("name") + " " + row.getString("death_date"));
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