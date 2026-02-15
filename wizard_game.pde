// Wizard Video Game for Processing Hackathon

// images
PImage schoolBg, spellBg, battleBg;
PImage profSprite, studentSprite, catSprite, orbSprite;

// story vars
int storyState = 0;
int flashStartTime = 0;

// dialogue vars
String currText = "";
int displayIndex = 0;
long lastUpdateTime = 0;
int typingSpeed = 55;
int dialogueIndex = 0;

// cat hover interaction
boolean mouseWasOverCat = false;
int catHoverCooldownMs = 600;
int lastCatHoverReactTime = -99999;

// spell test (storyState 1)
boolean spellStarted = false;
boolean spellFinished = false;
boolean spellPassed = false;
ArrayList<PVector> runePoints = new ArrayList<PVector>(); // target path
ArrayList<PVector> playerTrace = new ArrayList<PVector>(); // what player drew
int runeIndex = 0;
float traceTolerance = 50;
int spellTimeLimitMs = 12000;
int spellStartTime = 0;
int traceHits = 0;
int traceChecks = 0;
float passPercent = 0.72; // 72% accuracy to pass

// battle (storyState 3)
ArrayList<SpellOrb> orbs = new ArrayList<SpellOrb>();
int health = 5;
int maxHealth = 5;
int destroyedOrbs = 0;
int destroyGoal = 50;
int lastSpawnTime = 0;
int spawnIntervalMs = 420;
int minSpawnIntervalMs = 140;
char lastOrbLetter = '?';
boolean battleStarted = false;
boolean battlePassed = false;

// red hit flash
int hitFlashStart = 0;
int hitFlashDuration = 220;

String[] introLines = {
  "Welcome to the wizarding school!",
  "I am the Professor, and you are my new apprentice.",
  "Today, your magic will be truly tested...",
  "We will begin with a spell casting test!"
};

String[] levelUpLines = {
  "You're on the right path, apprentice...",
  "Let's test your strength in a final test."
};

// flash vars
int flashDuration = 900;

// characters (classes)
Wizard professor;
Wizard apprentice;
CatNPC cat;

// setup
void setup() {
  fullScreen();
  textFont(createFont("Arial", 32));

  // load + resize backgrounds once
  schoolBg = loadImage("wizard_school.png");
  spellBg  = loadImage("scroll_room.png");
  battleBg = loadImage("battle_room.png");

  if (schoolBg != null) schoolBg.resize(width, height);
  if (spellBg  != null) spellBg.resize(width, height);
  if (battleBg != null) battleBg.resize(width, height);

  // sprites
  profSprite = loadImage("wizard_professor.png");
  studentSprite = loadImage("apprentice.png");
  catSprite = loadImage("cat.png");
  orbSprite = loadImage("dark_orb.png");

  // create class objects
  professor = new Wizard(
    "Professor",
    profSprite,
    width/2 + 225,
    height * 0.62,
    height/3
    );

  apprentice = new Wizard(
    "Apprentice",
    studentSprite,
    225,
    height * 0.62,
    height/2
    );

  cat = new CatNPC(catSprite, width * 0.55, height * 0.72);

  buildRune();
}

// draw
void draw() {
  drawSceneBackground();
  drawNoiseFlashIfActive();

  // storyState 0: school, all characters, intro dialogue
  if (storyState == 0) {
    professor.display();
    apprentice.display();

    cat.update();
    cat.display();
    handleCatHoverReaction();

    initialScene();
  }

  // storyState 1: spell test scene (apprentice only + stats)
  else if (storyState == 1) {
    apprentice.display();
    
    if (!spellStarted) {
      drawDialogue("Spell Test: Trace the rune and get over 72% accuracy.\nHold the mouse to draw before the timer runs out."); 
    } else {
      runSpellTest(); 
    }
  }

  // storyState 2: back to school, all characters, level up dialogue
  else if (storyState == 2) {
    professor.display();
    apprentice.display();

    cat.update();
    cat.display();
    handleCatHoverReaction();

    if (spellPassed) {
      levelUpScene();
    } else {
      drawDialogue("Try again...\nYou must master spells before advancing."); 
      return;
    }
  }

  // storyState 3: battle scene (apprentice only + stats)
  else if (storyState == 3) {
    apprentice.display();
    drawHealthBar();
    
    if (!battleStarted) {
      drawDialogue("Final Test: Chamber of Judgment.\nType the letter on each orb before it reaches you.");
    } else {
      runBattleGame();
      drawBattleOverlay();
      drawHitFlash();
    }
  }

  // storyState 4: final school scene (all characters, ending message)
  else if (storyState == 4) {
    professor.display();
    apprentice.display();

    cat.update();
    cat.display();
    handleCatHoverReaction();

    endingScene();
  }
}

// background draw
void drawSceneBackground() {
  imageMode(CORNER);

  if (storyState == 1) {
    if (spellBg != null) image(spellBg, 0, 0, width, height);
    else background(30);
  } else if (storyState == 3) {
    if (battleBg != null) image(battleBg, 0, 0, width, height);
    else background(20);
  } else {
    if (schoolBg != null) image(schoolBg, 0, 0, width, height);
    else background(10);
  }
}

// story helpers
void initialScene() {
  if (dialogueIndex < introLines.length) {
    drawDialogue(introLines[dialogueIndex]);
  }
}

void levelUpScene() {
  if (dialogueIndex < levelUpLines.length) {
    drawDialogue(levelUpLines[dialogueIndex]);
  }
}

void endingScene() {
  if (battlePassed) {
    drawDialogue("You did it.\nYou are a worthy wizard."); 
  } else {
    drawDialogue("The chamber rejects you...\nTry again."); 
  }
}

// dialogue box
void drawDialogue(String message) {
  if (!message.equals(currText)) {
    currText = message;
    displayIndex = 0;
    lastUpdateTime = millis();
  }

  if (displayIndex < currText.length()) {
    long elapsed = millis() - lastUpdateTime;
    displayIndex = (int)(elapsed / typingSpeed);
    if (displayIndex > currText.length()) displayIndex = currText.length();
  }

  float margin = 40;
  float boxWidth = width - (margin * 2);
  float boxHeight = 150;
  float x = margin;
  float y = height - boxHeight - margin;

  fill(0, 0, 0, 220);
  stroke(255);
  strokeWeight(3);
  rect(x, y, boxWidth, boxHeight, 8);

  fill(255);
  textSize(32);
  textAlign(LEFT, TOP);

  String visiblePart = currText.substring(0, displayIndex);
  text(visiblePart, x + 30, y + 30, boxWidth - 60, boxHeight - 60);
}

// flash overlay
void triggerFlash() {
  flashStartTime = millis();
}

void drawNoiseFlashIfActive() {
  if (flashStartTime == 0) return;

  int elapsed = millis() - flashStartTime;
  if (elapsed > flashDuration) {
    flashStartTime = 0;
    return;
  }

  float half = flashDuration / 2.0;
  float intensity = (elapsed < half) ? (elapsed / half) : ((flashDuration - elapsed) / half);

  float n = noise(millis() * 0.003);
  float brightness = 200 + 55 * n;
  float alpha = intensity * 220;

  noStroke();
  fill(brightness, alpha);
  rect(0, 0, width, height);
}

// input
void mousePressed() {
  // dialogue click-to-advance
  if (displayIndex < currText.length()) {
    skipTyping();
    return;
  }

  if (storyState == 0) {
    dialogueIndex++;
    if (dialogueIndex >= introLines.length) {
      storyState = 1;
      triggerFlash();
      dialogueIndex = 0;
    }
  } else if (storyState == 1) {
    if (!spellStarted) {
      startSpellTest();
      return;
    }
    if (spellFinished) {
      storyState = 2;
      triggerFlash();
      dialogueIndex = 0;
      return;
    }
    return;
  } else if (storyState == 2) {
    if (!spellPassed) {
      return;
    }
    dialogueIndex++;
    if (dialogueIndex >= levelUpLines.length) {
      storyState = 3;
      triggerFlash();
      dialogueIndex = 0;
      battleStarted = false;
    }
  } else if (storyState == 3) {
    if (!battleStarted) {
      if (displayIndex < currText.length()) {
        skipTyping(); 
      } else {
        startBattle(); 
      }
    }
    return;
  }
}

void keyPressed() {
  if (storyState != 3 || !battleStarted) return;

  char typed = Character.toUpperCase(key);

  int bestIndex = -1;
  float bestDist = Float.MAX_VALUE;

  for (int i = 0; i < orbs.size(); i++) {
    SpellOrb o = orbs.get(i);
    if (o.letter != typed) continue;

    float d = dist(o.x, o.y, apprentice.x, apprentice.y);
    if (d < bestDist) {
      bestDist = d;
      bestIndex = i;
    }
  }

  if (bestIndex != -1) {
    orbs.get(bestIndex).destroyed = true;
  }
}

void mouseDragged() {
  if (storyState != 1 || !spellStarted || spellFinished) return;

  if (playerTrace.size() == 0 || dist(mouseX, mouseY, playerTrace.get(playerTrace.size()-1).x, playerTrace.get(playerTrace.size()-1).y) > 6) {
    playerTrace.add(new PVector(mouseX, mouseY));
  }

  // prevent random scribbling during the test
  PVector target = runePoints.get(constrain(runeIndex, 0, runePoints.size()-1));
  float d = dist(mouseX, mouseY, target.x, target.y);

  traceChecks++;
  if (d <= traceTolerance) {
    traceHits++;
    // progress forward only when you're close enough
    runeIndex++;
  } else {
    // allow a bit of backtracking so it feels responsive
    runeIndex = max(0, runeIndex - 1);
  }
}

// more helpers
void skipTyping() {
  displayIndex = currText.length();
  lastUpdateTime = millis() - (currText.length() * typingSpeed);
}

void handleCatHoverReaction() {
  if (!(storyState == 0 || storyState == 2 || storyState == 4)) return;

  boolean mouseOverCat = cat.isMouseOver();
  boolean mouseJustEntered = mouseOverCat && !mouseWasOverCat;
  boolean cooldownDone = (millis() - lastCatHoverReactTime) > catHoverCooldownMs;

  if (mouseJustEntered && cooldownDone) {
    cat.reactToHover();
    lastCatHoverReactTime = millis();
  }

  mouseWasOverCat = mouseOverCat;
}

void startBattle() {
  orbs.clear();
  destroyedOrbs = 0;

  health = maxHealth;
  battlePassed = false;
  battleStarted = true;

  lastSpawnTime = millis();
  spawnIntervalMs = 420;
}

void runBattleGame() {
  // spawn
  if (millis() - lastSpawnTime > spawnIntervalMs) {
    spawnOrb();
    lastSpawnTime = millis();
    spawnIntervalMs = max(minSpawnIntervalMs, spawnIntervalMs - 50); // ramp difficulty
  }

  // update/draw orbs
  for (int i = orbs.size() - 1; i >= 0; i--) {
    SpellOrb o = orbs.get(i);
    o.update();
    o.display();

    if (o.hits(apprentice.x, apprentice.y)) {
      takeDamage();
      orbs.remove(i);
      continue;
    }

    if (o.destroyed) {
      destroyedOrbs++;
      orbs.remove(i);
    }
  }

  // win/lose
  if (health <= 0) {
    battlePassed = false;
    battleStarted = false;
    storyState = 4;
    triggerFlash();
  } else if (destroyedOrbs >= destroyGoal) {
    battlePassed = true;
    battleStarted = false;
    storyState = 4;
    triggerFlash();
  }
}

void spawnOrb() {
  char c = char(int(random(26)) + 'A'); // A-Z
  while (c == lastOrbLetter) { // prevent A spam
    c = char(int(random(26)) + 'A'); 
  }
  lastOrbLetter = c;

  float startX = width + 80;
  float startY = random(height * 0.35, height * 0.80);

  float speed = map(spawnIntervalMs, 420, minSpawnIntervalMs, 6.5, 12.5);
  speed = constrain(speed, 6.0, 13.0);

  orbs.add(new SpellOrb(orbSprite, c, startX, startY, speed));
}

void takeDamage() {
  health--;
  hitFlashStart = millis();
}

void drawHealthBar() {
  float pad = 24;
  float panelW = 280;
  float panelH = 90;
  float x = width - panelW - pad;
  float y = pad;

  fill(0, 0, 0, 170);
  stroke(255);
  strokeWeight(2);
  rect(x, y, panelW, panelH, 10);

  fill(255);
  textAlign(LEFT, TOP);
  textSize(22);
  text("Health", x + 16, y + 14);

  float barX = x + 16;
  float barY = y + 48;
  float barW = panelW - 32;
  float barH = 18;

  noStroke();
  fill(255, 255, 255, 70);
  rect(barX, barY, barW, barH, 6);

  float pct = health / (float)maxHealth;
  pct = constrain(pct, 0, 1);

  fill(255, 80, 80, 200);
  rect(barX, barY, barW * pct, barH, 6);

  fill(255);
  textSize(18);
  text(health + " / " + maxHealth, barX, barY + 26);
}

void drawBattleOverlay() {
  fill(255, 230);
  textAlign(LEFT, TOP);
  textSize(20);
  text("Destroyed: " + destroyedOrbs + " / " + destroyGoal, 40, 40);
  text("Type the orb's letter to dispel it", 40, 66);
}

void drawHitFlash() {
  if (hitFlashStart == 0) return;
  int elapsed = millis() - hitFlashStart;
  if (elapsed > hitFlashDuration) return;

  float alpha = map(elapsed, 0, hitFlashDuration, 140, 0);
  noStroke();
  fill(255, 0, 0, alpha);
  rect(0, 0, width, height);
}

void buildRune() {
  runePoints.clear();

  float cx = width * 0.55;
  float cy = height * 0.45;

  float radius = min(width, height) * 0.18;
  float angle = -PI/2;

  for (int i = 0; i < 220; i++) {
    float t = i / 220.0;
    float r = lerp(radius, radius * 0.35, t);
    float a = angle + t * TWO_PI * 1.6; // ~1.6 turns

    float x = cx + cos(a) * r;
    float y = cy + sin(a) * r;

    runePoints.add(new PVector(x, y));
  }

  PVector end = runePoints.get(runePoints.size()-1);
  for (int i = 0; i < 50; i++) {
    runePoints.add(new PVector(end.x + i*3.2, end.y - i*1.2));
  }
}

void startSpellTest() {
  spellStarted = true;
  spellFinished = false;
  spellPassed = false;

  playerTrace.clear();
  runeIndex = 0;

  traceHits = 0;
  traceChecks = 0;

  spellStartTime = millis();
}

void runSpellTest() {
  drawRuneTarget();
  drawPlayerTrace();

  // time left
  int elapsed = millis() - spellStartTime;
  int timeLeft = max(0, (spellTimeLimitMs - elapsed) / 1000);

  fill(255);
  textAlign(LEFT, TOP);
  textSize(22);
  text("Time: " + timeLeft, 40, 40);

  // live accuracy
  float acc = (traceChecks == 0) ? 0 : (traceHits / (float)traceChecks);
  text("Accuracy: " + int(acc * 100) + "%", 40, 66);

  // finish conditions
  if (!spellFinished) {
    // pass if you reach near the end of the rune
    if (runeIndex >= runePoints.size() - 15) {
      finishSpellTest(true);
    }

    // fail if time runs out
    if (elapsed > spellTimeLimitMs) {
      finishSpellTest(false);
    }
  }

  // end message overlay
  if (spellFinished) {
    if (spellPassed) {
      drawDialogue("Spell complete.\nYou passed.");
    } else {
      drawDialogue("Your rune fizzles...\nYou failed.");
    }
  }
}

void finishSpellTest(boolean reachedEnd) {
  spellFinished = true;

  float acc = (traceChecks == 0) ? 0 : (traceHits / (float)traceChecks);
  spellPassed = reachedEnd && (acc >= passPercent);
}

void drawRuneTarget() {
  noFill();
  stroke(180, 220);
  strokeWeight(10);

  beginShape();
  for (PVector p : runePoints) {
    vertex(p.x, p.y);
  }
  endShape();

  // highlight the current goal point
  PVector g = runePoints.get(constrain(runeIndex, 0, runePoints.size()-1));
  noStroke();
  fill(255, 255, 255, 180);
  ellipse(g.x, g.y, 18, 18);
}

void drawPlayerTrace() {
  if (playerTrace.size() < 2) return;

  noFill();
  stroke(255);
  strokeWeight(6);

  beginShape();
  for (PVector p : playerTrace) {
    vertex(p.x, p.y);
  }
  endShape();
}
