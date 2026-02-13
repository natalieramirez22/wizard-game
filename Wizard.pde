// Wizard class for Hackathon Wizard game

class Wizard {
  String name;
  PImage sprite;
  float x, y;
  float spriteHeight;

  Wizard(String name, PImage sprite, float x, float y, float spriteHeight) {
    this.name = name;
    this.sprite = sprite;
    this.x = x;
    this.y = y;
    this.spriteHeight = spriteHeight;
  }

  void display() {
    if (sprite == null) return;

    imageMode(CENTER);

    float scaleFactor = spriteHeight / sprite.height;
    float drawW = sprite.width * scaleFactor;
    float drawH = sprite.height * scaleFactor;

    image(sprite, x, y, drawW, drawH);
  }
}
