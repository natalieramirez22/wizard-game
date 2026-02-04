// main vars
PImage schoolBg, spellBg, battleBg;
PImage wizardProf, wizardStudent;

// storytelling vars
int storyState = 0;
int pauseStartTime;
int flashStartTime;

// dialogue vars
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
  "Spell test scene",
  "More of spell test"
};

// for flash
int flashDuration = 900;
float noiseScale = 0.02;

void drawDialogue(String message) {
  // reset logic if text changes
  if (!message.equals(currText)) {
    currText = message;
    displayIndex = 0;
    lastUpdateTime = millis();
  }

  // typewriter animation logic
  if (displayIndex < currText.length()) {
    long elapsed = millis() - lastUpdateTime;
    displayIndex = (int)(elapsed / typingSpeed);
    
    if (displayIndex > currText.length()) {
      displayIndex = currText.length(); 
    }
  }

  // draw box
  float margin = 40;
  float boxWidth = width - (margin * 2);
  float boxHeight = 150;
  float x = margin;
  float y = height - boxHeight - margin;
  
  fill(0, 0, 0, 220);
  stroke(255);
  strokeWeight(3);
  rect(x, y, boxWidth, boxHeight, 8);

  // draw text
  fill(255);
  textSize(32);
  textAlign(LEFT, TOP);
  
  String visiblePart = currText.substring(0, displayIndex);
  text(visiblePart, x + 30, y + 30, boxWidth, boxHeight);
}

void initialScene() {
  if (dialogueIndex < introLines.length) {
    drawDialogue(introLines[dialogueIndex]);
  }
}

void spellTest() {
  if (dialogueIndex < levelUpLines.length) {
    drawDialogue(levelUpLines[dialogueIndex]);
  }
}

void drawNoiseFlash() {
  int elapsed = millis() - flashStartTime;

  float half = flashDuration / 2.0;
  float intensity = (elapsed < half)
    ? (elapsed / half)
    : ((flashDuration - elapsed) / half);

  float n = noise(millis() * 0.003);

  float brightness = 200 + 55 * n;
  float alpha = intensity * 220;

  noStroke();
  fill(brightness, alpha);
  rect(0, 0, width, height);
}

void setup() {
  // set screen
  fullScreen();
  schoolBg = loadImage("wizard_school.png");
  schoolBg.resize(width, height);
  battleBg = loadImage("battle_room.png");
  battleBg.resize(width, height);
  spellBg = loadImage("scroll_room.png");
  spellBg.resize(width, height);
  
  // draw initial sprites
  wizardProf = loadImage("wizard_professor.png");
  wizardStudent = loadImage("apprentice.png");
  wizardProf.resize(0, height/3);
  wizardStudent.resize(0, height/2);
}

void draw() {
  if (storyState == 1) {
    image(spellBg, 0, 0);
  } else if (storyState == 3) {
    image(battleBg, 0, 0);
  } else {
    image(schoolBg, 0, 0);
  }
  
  if (storyState == 0) {
    image(wizardProf, width/2 - 30, 390);
    image(wizardStudent, 60, 350);
    initialScene();
  } else if (storyState == 1) {
    drawNoiseFlash();
    spellTest();
  } else if (storyState == 2) {
    drawNoiseFlash();
    //if (gameWon) {
    //  levelUpScene();
    //} else {
    //  failScene(); 
    //}
    drawDialogue("Back to dialogue, decide to move on or fail");
  } else if (storyState == 3) {
    drawNoiseFlash();
    image(wizardStudent, 60, 350);
    drawDialogue("The battle begins now!");
  } else if (storyState == 4) {
    //if (gameWon) {
    //  winScene();
    //} else {
    //  failScene(); 
    //} 
  }
}

void mousePressed() {
  if (storyState == 0) {
    // if text still typing, skip to eol
    if (displayIndex < currText.length()) {
      displayIndex = currText.length();
      lastUpdateTime = millis() - (currText.length() * typingSpeed);
    } else { // if text finished, move to next line
      dialogueIndex++;
      // after initial scene over, move to next storyState
      if (dialogueIndex >= introLines.length) {
        storyState = 1;
        flashStartTime = millis(); // trigger flash for next state
        dialogueIndex = 0; // reset for dialogue usage
      }
    }
  } else if (storyState == 1) {
    if (displayIndex < currText.length()) {
      displayIndex = currText.length();
      lastUpdateTime = millis() - (currText.length() * typingSpeed);
    } else {
      dialogueIndex++;
      if (dialogueIndex >= levelUpLines.length) {
        storyState = 2;
        flashStartTime = millis();
        dialogueIndex = 0;
      }
    }
  } else if (storyState == 2) {
    if (displayIndex < currText.length()) {
      displayIndex = currText.length();
      lastUpdateTime = millis() - (currText.length() * typingSpeed);
    } else {
      storyState = 3;
      flashStartTime = millis();
      dialogueIndex = 0;
    }
  }
}
