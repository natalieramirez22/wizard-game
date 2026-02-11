// Wizard class for Hackathon Wizard game

class Wizard {
  String name;

  PImage sprite;
  float x, y;
  float targetHeight;

  // player stats (for later gameplay)
  int mana = 100;
  int maxMana = 100;

  Wizard(String name, PImage sprite, float x, float y, float targetHeight) {
    this.name = name;
    this.sprite = sprite;
    this.x = x;
    this.y = y;
    this.targetHeight = targetHeight;
  }

  void display() {
    if (sprite == null) return;

    imageMode(CENTER);

    float scaleFactor = targetHeight / sprite.height;
    float drawW = sprite.width * scaleFactor;
    float drawH = sprite.height * scaleFactor;

    image(sprite, x, y, drawW, drawH);
  }

  void drawStatusPanel() {
    float pad = 24;
    float panelW = 320;
    float panelH = 100;
    float panelX = width - panelW - pad;
    float panelY = pad;

    fill(0, 0, 0, 170);
    stroke(255);
    strokeWeight(2);
    rect(panelX, panelY, panelW, panelH, 10);

    fill(255);
    textAlign(LEFT, TOP);
    textSize(22);
    text("Apprentice Status", panelX + 16, panelY + 14);

    // mana bar
    float barX = panelX + 16;
    float barY = panelY + 50;
    float barW = panelW - 32;
    float barH = 18;

    noStroke();
    fill(255, 255, 255, 70);
    rect(barX, barY, barW, barH, 6);

    float pct = (maxMana == 0) ? 0 : (mana / (float)maxMana);
    pct = constrain(pct, 0, 1);

    fill(255, 255, 255, 180);
    rect(barX, barY, barW * pct, barH, 6);

    fill(255);
    textSize(20);
    text("Mana: " + mana + "/" + maxMana, barX, barY + 26);
  }
}
