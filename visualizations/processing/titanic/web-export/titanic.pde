// Visualization Fall 2015
// Final Project: Titanic Passengers
// Steph Cleland & Rob Lasell
// Life expectancy data from http://ourworldindata.org/data/population-growth-vital-statistics/life-expectancy/

String birthFilename = "processing/titanic/data/birth.txt";
String deathFilename = "processing/titanic/data/death.txt";
String dataFilename  = "processing/titanic/data/titanic-data.tsv";

int DISASTER_YEAR = 1912;
int DISASTER_MONTH = 4;
int DISASTER_DAY = 15;

int earliestDay = 17;
int earliestMonth = 5;
int earliestYear = 1837;

// average life expectancy in 1912
HashMap<Integer, Integer> lifeExpectancies;
HashMap<String, Integer> months;
JSTable table;

void setup() {
  setupTable();
  setupMaps();
  inputData();
  
  size(1200, 500);
}

void draw() {
  fill(255, 0, 0);
  ellipse(width / 2, height / 2, 100, 100);
}

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
    //the line below 
    if (classChar.match(/[a-z]/i)) {
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

  return toReturn;
}
// missing an analog to loadTable
// also, functions that return multiple rows just return
// an ArrayList of rows instead of an iterator
// also missing matchRow(), matchRows(), removeTokens(), and trim()

class JSTable {
  ArrayList<JSTableRow> rowList;
  ArrayList<String> columnNames;
  
  JSTable() {
    rowList = new ArrayList<JSTableRow>();
    columnNames = new ArrayList<String>();
  }
  
  void addColumn(String columnName) {
    columnNames.add(columnName);
    for (JSTableRow row : rowList) {
      row.setString(columnName, "");
    }
  }
  
  void removeColumn(String columnName) {
    columnNames.remove(columnName);
    for (JSTableRow row : rowList) {
      row.row.remove(columnName);
    }
  }
  
  int getColumnCount() {
    return columnNames.size();
  }
  
  int getRowCount() {
    return rowList.size();
  }
  
  void clearRows() {
    rowList = new ArrayList<JSTableRow>();
  }
  
  JSTableRow addRow() {
    JSTableRow newRow = new JSTableRow(columnNames);
    rowList.add(newRow);
    
    return newRow;
  }
  
  void removeRow(int index) {
    rowList.remove(index);
  }
  
  JSTableRow getRow(int index) {
    return rowList.get(index);
  }
  
  ArrayList<JSTableRow> rows() {
    return rowList;
  }
  
  int getInt(int row, String columnName) {
    return rowList.get(row).getInt(columnName);
  }
  
  void setInt(int row, String columnName, int val) {
    rowList.get(row).setInt(columnName, val);
  }
  
  Float getFloat(int row, String columnName) {
    return rowList.get(row).getFloat(columnName);
  }
  
  void setFloat(int row, String columnName, float val) {
    rowList.get(row).setFloat(columnName, val);
  }
  
  String getString(int row, String columnName) {
    return rowList.get(row).getString(columnName);
  }
  
  void setString(int row, String columnName, String val) {
    rowList.get(row).setString(columnName, val);
  }

  String[] getStringColumn(String columnName) {
    int len = rowList.size();
    String[] toReturn = new String[len];

    for (int i = 0; i < len; i++) {
      toReturn[i] = rowList.get(i).getString(columnName);
    }
    
    return toReturn;
  }
  
  JSTableRow findRow(String value, String columnName) {
    for (JSTableRow row : rowList) {
      if ((row.getString(columnName)).equals(value)) {
        return row;
      }
    }
    
    return null;
  }
  
  ArrayList<JSTableRow> findRows(String value, String columnName) {
    ArrayList<JSTableRow> toReturn = new ArrayList<JSTableRow>();
    
    for (JSTableRow row : rowList) {
      if ((row.getString(columnName)).equals(value)) {
        toReturn.add(row);
      }
    }
    
    return toReturn;
  }
}
class JSTableRow {
  HashMap<String, String> row;
  
  JSTableRow(ArrayList<String> columnNames) {
    row = new HashMap<String, String>();
    for (int i = 0; i < columnNames.size(); i++) {
      row.put(columnNames.get(i), "");
    }
  }
  
  String getString(String columnName) {
    return row.get(columnName);
  }
  
  void setString(String columnName, String val) {
    row.put(columnName, val);
  }
  
  int getInt(String columnName) {
    return parseInt(getString(columnName));
  }
  
  void setInt(String columnName, int val) {
    row.put(columnName, str(val));
  }
  
  float getFloat(String columnName) {
    return parseFloat(getString(columnName));
  }
  
  void setFloat(String columnName, float val) {
    row.put(columnName, str(val));
  }
}

