// missing an analog to loadTable
// also, functions that return multiple rows just return
// an ArrayList of rows instead of an iterator
// also missing matchRow(), matchRows(), removeTokens(), and trim()

class JSTable {
  ArrayList<JSTableRow> rowList;
  ArrayList<String> columnNames;
  
  
  
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