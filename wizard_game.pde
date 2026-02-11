/* 
  Exercise 5: Processing Hackathon (PAT 204)

  STORY FLOW (as requested):
  storyState 0: schoolBg + apprentice + professor + cat + intro dialogue
  storyState 1: spellBg + apprentice only + status panel (no cat/professor)
  storyState 2: schoolBg + apprentice + professor + cat + level-up dialogue
  storyState 3: battleBg + apprentice only + status panel (no cat/professor)
  storyState 4: schoolBg + apprentice + professor + cat + final success/fail message (placeholder)

  NOTES:
  - Background bug + trails were caused by imageMode(CENTER) carrying over from sprite drawing.
  - This main file forces imageMode(CORNER) before drawing backgrounds every frame.
*/

// -------------------- IMAGES --------------------
PImage schoolBg, spellBg, battleBg;
PImage profSprite, studentSprite, catSprite;

// -------------------- STORY VARS --------------------
int storyState = 0;
int flashStartTime = 0;

// -------------------- DIALOGUE VARS --------------------
String currText = "";
int displayIndex = 0;
long lastUpdateTime = 0;
int typingSpeed = 55;
int dialogueIndex = 0;

String[] introLines = {
  "Welcome to the wizarding school!",
  "I am the Professor, and you are my new apprentice.",
  "Today, your magic will be truly tested...",
  "We will begin with a spell casting test!"
};

String[] levelUpLines = {
  "Spell test scene result goes here (pass/fail)",
  "If they pass, we move on to the battle!"
};

String[] endingLines = {
  "Final scene: you passed! (replace later)",
  "Final scene: you failed... (replace later)"
};

// -------------------- FLASH VARS --------------------
int flashDuration = 900;

// -------------------- CHARACTERS (CLASSES) --------------------
Wizard professor;
Wizard apprentice;
CatNPC cat;

// -------------------- SETUP --------------------
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

  // sprites (loaded once; passed into objects)
  profSprite = loadImage("wizard_professor.png");
  studentSprite = loadImage("apprentice.png");
  catSprite = loadImage("cat.png"); // make sure cat.png exists

  // create wizard objects
  professor = new Wizard(
    "Professor",
    profSprite,
    width/2 + 250,
    height * 0.62,
    height/3
  );

  apprentice = new Wizard(
    "Apprentice",
    studentSprite,
    200,
    height * 0.66,
    height/2
  );

  // player stats (used in storyState 1 and 3)
  apprentice.mana = 100;
  apprentice.maxMana = 100;

  // cat NPC (only shown in storyState 0,2,4)
  cat = new CatNPC(catSprite, width * 0.55, height * 0.72);
}

// -------------------- DRAW LOOP --------------------
void draw() {
  // 1) ALWAYS draw background first (and force CORNER mode)
  drawSceneBackground();

  // 2) flash overlay if active
  drawNoiseFlashIfActive();

  // 3) draw characters based on story state (exactly how you described)

  // storyState 0: school, all characters, intro dialogue
  if (storyState == 0) {
    professor.display();
    apprentice.display();

    cat.update();
    cat.display();

    initialScene();
  }

  // storyState 1: spell test scene (apprentice only + stats)
  else if (storyState == 1) {
    apprentice.display();
    apprentice.drawStatusPanel();   // player UI only here
    drawDialogueForState1();
  }

  // storyState 2: back to school, all characters, level up dialogue
  else if (storyState == 2) {
    professor.display();
    apprentice.display();

    cat.update();
    cat.display();

    levelUpScene();
  }

  // storyState 3: battle scene (apprentice only + stats)
  else if (storyState == 3) {
    apprentice.display();
    apprentice.drawStatusPanel();   // player UI only here
    drawDialogue("The battle begins now!");
  }

  // storyState 4: final school scene (all characters, ending message)
  else if (storyState == 4) {
    professor.display();
    apprentice.display();

    cat.update();
    cat.display();

    endingScene();
  }
}

// -------------------- BACKGROUND DRAW (FIXES CORNER BUG + TRAILS) --------------------
void drawSceneBackground() {
  imageMode(CORNER); // critical: backgrounds must use CORNER

  if (storyState == 1) {
    if (spellBg != null) image(spellBg, 0, 0, width, height);
    else background(30);
  } 
  else if (storyState == 3) {
    if (battleBg != null) image(battleBg, 0, 0, width, height);
    else background(20);
  } 
  else {
    if (schoolBg != null) image(schoolBg, 0, 0, width, height);
    else background(10);
  }
}

// -------------------- STORY DIALOGUE HELPERS --------------------
void initialScene() {
  if (dialogueIndex < introLines.length) {
    drawDialogue(introLines[dialogueIndex]);
  }
}

void drawDialogueForState1() {
  // placeholder until your spell test game exists
  drawDialogue("Spell Test (game goes here). Click to continue for now.");
}

void levelUpScene() {
  if (dialogueIndex < levelUpLines.length) {
    drawDialogue(levelUpLines[dialogueIndex]);
  }
}

void endingScene() {
  // placeholder ending (you’ll replace with pass/fail logic later)
  drawDialogue("Final scene placeholder: success/fail goes here.");
}

// -------------------- DIALOGUE BOX --------------------
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

// -------------------- FLASH OVERLAY --------------------
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

// -------------------- INPUT --------------------
void mousePressed() {
  // cat interaction ONLY when cat exists in the scene
  if (storyState == 0 || storyState == 2 || storyState == 4) {
    if (cat.isMouseOver()) {
      cat.reactToClick();
    }
  }

  // dialogue click-to-advance
  if (displayIndex < currText.length()) {
    skipTyping();
    return;
  }

  // advance story logic (keeps your original feel, just aligned to your new states)
  if (storyState == 0) {
    dialogueIndex++;
    if (dialogueIndex >= introLines.length) {
      storyState = 1;
      triggerFlash();
      dialogueIndex = 0;
    }
  }
  else if (storyState == 1) {
    // for now, click moves to level-up dialogue scene
    storyState = 2;
    triggerFlash();
    dialogueIndex = 0;
  }
  else if (storyState == 2) {
    dialogueIndex++;
    if (dialogueIndex >= levelUpLines.length) {
      storyState = 3;
      triggerFlash();
      dialogueIndex = 0;
    }
  }
  else if (storyState == 3) {
    // placeholder: after battle, go to final scene
    storyState = 4;
    triggerFlash();
    dialogueIndex = 0;
  }
  else if (storyState == 4) {
    // final scene: you can later lock this or restart
  }
}

void skipTyping() {
  displayIndex = currText.length();
  lastUpdateTime = millis() - (currText.length() * typingSpeed);
}
