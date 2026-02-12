class SpellOrb {
  PImage sprite;
  char letter;

  float x, y;
  float speed;
  boolean destroyed = false;

  float size = 96;

  SpellOrb(PImage sprite, char letter, float x, float y, float speed) {
    this.sprite = sprite;
    this.letter = letter;
    this.x = x;
    this.y = y;
    this.speed = speed;
  }

  void update() {
    x -= speed;
  }

  void display() {
    imageMode(CENTER);

    if (sprite != null) {
      image(sprite, x, y, size, size);
    } else {
      noStroke();
      fill(120, 0, 200, 200);
      ellipse(x, y, size, size);
    }

    // letter on top
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(34);
    text(letter, x, y + 2);
  }

  boolean hits(float tx, float ty) {
    float hitRadius = 70;
    return dist(x, y, tx, ty) < hitRadius;
  }
}
