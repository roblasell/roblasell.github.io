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
  /*
  public void sort(String columnName) {
    ArrayList<JSTableRow> temp = new ArrayList<JSTableRow>();
    for (int i = 0; i < rowList.size(); i++) {
      temp.add(null);
    }
    mergesort(0, rowList.size() - 1, temp, columnName);
  }
*//*
  void mergesort(int low, int high, ArrayList<JSTableRow> temp, String columnName) {
    // check if low is smaller then high, if not then the array is sorted
    if (low < high) {
      // Get the index of the element which is in the middle
      int middle = low + (high - low) / 2;
      // Sort the left side of the array
      mergesort(low, middle, temp, columnName);
      // Sort the right side of the array
      mergesort(middle + 1, high, temp, columnName);
      // Combine them both
      merge(low, middle, high, temp, columnName);
    }
  }
  *//*
  void merge(int low, int middle, int high, ArrayList<JSTableRow> temp, String columnName) {
    // Copy both parts into the helper array
    for (int i = low; i <= high; i++) {
      temp.set(i, rowList.get(i));
    }

    int i = low;
    int j = middle + 1;
    int k = low;
    // Copy the smallest values from either the left or the right side back
    // to the original array
    while (i <= middle && j <= high) {
      if (temp.get(i).getInt(columnName) <= temp.get(j).getInt(columnName)) {
        rowList.set(k, temp.get(i));
        i++;
      } else {
        rowList.set(k, temp.get(j));
        j++;
      }
      k++;
    }
    
    // Copy the rest of the left side of the array into the target array
    while (i <= middle) {
      rowList.set(k, temp.get(i));
      k++;
      i++;
    }

  }
  */
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