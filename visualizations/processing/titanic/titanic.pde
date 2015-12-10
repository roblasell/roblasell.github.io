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

int latestDay = 0;
float widthPercent = 0.9;
float heightPercent = 0.5;

// average life expectancy in 1912
HashMap<Integer, Integer> lifeExpectancies;
HashMap<String, Integer> months;
JSTable table;

void setup() {
  setupTable();
  setupMaps();
  inputData();
  
  size(1200, 400);
}

void draw() {
  background(50);
  fill(255, 0, 0);
  ellipse(width / 2, height / 2, 100, 100);
}

void drawAxis() {
  stroke(200);
  line((width * ((1 - widthPercent) / 2)), height * heightPercent, (width * (widthPercent / 2)), height * heightPercent);
  
}