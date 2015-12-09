float menuWidthPercent = 0.2;
float sliderWidthPercent = 0.7;
float buttonHeight = 20;
color menuColor = color(200, 225, 250);
color buttonColor = color(130, 190, 250);
color buttonHighlightColor = color(255, 210, 160);

class Menu {
  float x;
  float y;
  float w;
  float h;
  float changeFactor;
  float maxHeight;
  boolean visible;
  Slider[] sliders;
  CheckBox centering;
  
  Menu() {
    x = width * (1 - menuWidthPercent);
    y = 0;
    w = width * menuWidthPercent;
    h = 0;
    visible = false;
    changeFactor = 6;
    
    sliders = new Slider[numConstants];
    float xPos = x + ((w * (1 - sliderWidthPercent)) / 2);
    
    sliders[0] = new Slider(0, "HOOKE", "Hooke's Constant", xPos, buttonHeight + 70, w * sliderWidthPercent, 20, maxHooke);
    sliders[1] = new Slider(1, "COULOMB", "Coulomb's Constant", xPos, buttonHeight + 140, w * sliderWidthPercent, 20, maxCoulomb);
    sliders[2] = new Slider(2, "DAMP", "Damping Constant", xPos, buttonHeight + 210, w * sliderWidthPercent, 20, maxDamp);
    sliders[3] = new Slider(3, "TIME", "Time", xPos, buttonHeight + 280, w * sliderWidthPercent, 20, maxTime);
    
    centering = new CheckBox(0, "CENTERING", "Centered", xPos, buttonHeight + 330, 17);
    
    maxHeight = buttonHeight + 395;
  }
  
  void render() {
    fill(menuColor);
    rectMode(CORNER);
    rect(x, y, w, h);
    
    if (overButton()) {
      fill(buttonHighlightColor);
    } else {
      fill(buttonColor);
    }
    rect(x, y, w, buttonHeight);
    
    textSize(12);
    fill(0);
    if (!visible && !closingMenu) {
      text("Show Menu", x + 3, y + 15);
    } else if (closingMenu) {
      text("Hide Menu", x + 3, y + 15);
    } else {
      text("Hide Menu", x + 3, y + 15);
      for (int i = 0; i < numConstants; i++) {
        sliders[i].render();
      }
      
      centering.render();
    }
    
    for (int i = 0; i < numConstants; i++) {
      sliders[i].mapConstant();
    }
    
    centering.mapConstant();
  }
  
  boolean overButton() {
    if (mouseX >= x && mouseX <= width && mouseY >= 0 && mouseY <= buttonHeight) {
      return true;
    } else {
      return false;
    }
  }
  
  void openMenu() {
    if (h < maxHeight) {
      h += maxHeight / changeFactor;
    } else {
      h = maxHeight;
      openingMenu = false;
      visible = true;
    }
  }
  
  void closeMenu() {
    if (h > 0) {
      visible = false;
      h -= maxHeight / changeFactor;
    } else {
      h = 0;
      closingMenu = false;
    }
  }
  
  boolean over() {
    if (mouseX >= x && mouseX <= width && mouseY >= 0 && mouseY <= h) {
      return true;
    } else {
      return false;
    }
  }
}
