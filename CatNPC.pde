// Cat (NPC) class for Hackathon Wizard game

class CatNPC {
  PImage sprite;

  float x, y;
  float vx, vy;

  int nextWanderTime = 0;
  int nextMeowTime = 0;

  int reactionStartTime = -99999;
  String reactionText = "";

  CatNPC(PImage sprite, float x, float y) {
    this.sprite = sprite;
    this.x = x;
    this.y = y;

    pickNewVelocity();
    scheduleWander();
    scheduleMeow();
  }

  void update() {
    if (millis() > nextWanderTime) {
      pickNewVelocity();
      scheduleWander();
    }

    x += vx;
    y += vy;

    float margin = 60;
    if (x < margin || x > width - margin) vx *= -1;
    if (y < margin || y > height - margin) vy *= -1;

    if (millis() > nextMeowTime) {
      reactionText = random(1) < 0.5 ? "meow." : "mrrp!";
      reactionStartTime = millis();
      scheduleMeow();
    }
  }

  void display() {
    if (sprite != null) {
      imageMode(CENTER);

      float bob = map(noise(frameCount * 0.03), 0, 1, -4, 4);
      float targetH = height * 0.16;
      float s = targetH / sprite.height;

      image(sprite, x, y + bob, sprite.width * s, sprite.height * s);
    }

    if (millis() - reactionStartTime < 900) {
      fill(255);
      textAlign(CENTER, BOTTOM);
      textSize(22);
      text(reactionText, x, y - 30);
    }
  }

  void reactToClick() {
    reactionText = random(1) < 0.5 ? "purr..." : "mew!";
    reactionStartTime = millis();

    x += random(-20, 20);
    y += random(-10, 10);
  }

  boolean isMouseOver() {
    return dist(mouseX, mouseY, x, y) < 70;
  }

  void pickNewVelocity() {
    float speed = random(0.6, 2.2);
    float angle = random(TWO_PI);
    vx = cos(angle) * speed;
    vy = sin(angle) * speed;
  }

  void scheduleWander() {
    nextWanderTime = millis() + int(random(600, 1600));
  }

  void scheduleMeow() {
    nextMeowTime = millis() + int(random(1800, 4200));
  }
}
