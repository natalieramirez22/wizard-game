// main vars
PImage bg, wizardProf, wizardStudent;

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

// for noise
int flashDuration = 900;
float noiseScale = 0.02;
String[] introLines = {
  "Welcome to the wizarding school!",
  "I am the Professor, and you are my new apprentice.",
  "Today, your magic will be truly tested...",
  "We will begin with a spell casting test!"
};

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
  bg = loadImage("wizard_school_new.png");
  bg.resize(width, height);
  
  // draw initial sprites
  wizardProf = loadImage("wizard_professor.png");
  wizardStudent = loadImage("apprentice.png");
  wizardProf.resize(0, height/3);
  wizardStudent.resize(0, height/2);
}

void draw() {
  image(bg, 0, 0);
  if (storyState == 0) {
    image(wizardProf, width/2 - 30, 390);
    image(wizardStudent, 60, 350);
    
    initialScene();
  } else if (storyState == 1) {
    drawNoiseFlash();
    //spellTest();
    storyState = 2; 
  } else if (storyState == 2) {
    //if (gameWon) {
    //  levelUpScene();
    //} else {
    //  failScene(); 
    //}
    storyState = 3; 
  } else if (storyState == 3) {
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
      lastUpdateTime = millis() - (currText.length() * typingSpeed);
      displayIndex = currText.length();
    } 
    // if text finished, move to next line
    else {
      dialogueIndex++;
      // after initial scene over, move to next storyState
      if (dialogueIndex >= introLines.length) {
        storyState = 1;
        flashStartTime = millis(); // trigger flash for next state
        dialogueIndex = 0; // reset for dialogue usage
      }
    }
  }
}
