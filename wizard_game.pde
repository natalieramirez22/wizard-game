PImage bg, wizardProf, wizardStudent;

void startScreen() {
  // with only the background on the screen,
  // add a text box with a decorative scroll
  // asking the user to start the game
}

void drawSprites() {
  wizardProf = loadImage("wizard_professor-export.png");
  wizardStudent = loadImage("wizard_student_match.png");
  wizardProf.resize(width/2, height/2);
  wizardStudent.resize(width/2, height/2);
  image(wizardProf, width/2, 300);
  image(wizardStudent, 50, 325);
}

void setup() {
  size(600, 600);
  bg = loadImage("wizard_room_ai.png");
  bg.resize(width, height);
  image(bg, 0, 0);
}

void draw() {
  startScreen();
  drawSprites();
  
}
