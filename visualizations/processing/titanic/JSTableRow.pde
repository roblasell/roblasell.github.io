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