/**
 * Fortress Fight is a game in which the user plays as a knight fighting against monsters and trying to survive through increasingly difficult waves.
 * When run, the user is presented with a game menu in which they can access help (how to play the game, controls), save their game, toggle the difficulty, and play the game.
 * The controls are versatile; multiple keys do the same things in order to accomodate for what different players are comfortable with.
 *
 * @author  Ethan Lau
 * @version 1.0
 * @since   2025-1-21
 */



//GLOBAL VARIABLES: CAN BE USED IN ANY METHOD

//ZOMBIES:

//monster characteristics
final int MAX_ZOMBIES = 20; //arbitrary, set relatively small to save memory
int zombieSpawnFrequency = 300; //frames between zombie spawing
final int ZOMBIE_Y = 570; //zombies can't jump or move up so their y is a constant
int zombieMaxHp = 100; //100%

//speeds
double zombieSpeed = 1.2; //pixels moved per frame, will be changed to increase difficulty
final double ZOMBIE_JUMP_SPEED = 16 * zombieSpeed; //pixels moved per frame

//attack characteristics
final int ZOMBIE_SIGHT_RANGE = 180; //distance from character that the zombie starts attacking at
final double ZOMBIE_KNOCKBACK = 10 * zombieSpeed; //pixels character moves per frame being hit by zombie
int zombieDamage = 10; //% of character health per hit

//attack animation frames
final int ZOMBIE_JUMP_FRAME = 30; //frame to jump forward
final int ZOMBIE_ATTACK_END_FRAME = 60; //frame to end attack animation
final int ZOMBIE_MAX_ATTACK_DISPLACEMENT = 200; //how far the zombie should travel when jumping

//dynamic values
double zombieSpawnDistance = 0; //distance the zombie spawns from a side of the screen, will change every time a zombie spawns
int closestZombie = -1;
double closestZombieX = -1;


//zombie array attributes: stored in an array because these attributes can be different for each zombie

//stores x pos of each zombie
double[] zombieX = new double[MAX_ZOMBIES];

//whether each zombie is in up or down position
boolean[] zombieUp = new boolean[MAX_ZOMBIES];

//attacking
int[] zombieAttackFrame = new int[MAX_ZOMBIES];//frame of the attack animation that each zombie is on (-1 = not attacking)
int[] zombieAttackDisplacement = new int[MAX_ZOMBIES]; //how far the zombie has travelled while attacking
//zombieState contains the state of each zombie as follows:
//0 = doesn't exist, 1 = moving left, 2 = attacking left, 3 = moving right, 4 = attacking right
int[] zombieState = new int[MAX_ZOMBIES];
boolean[] zombieDamaging = new boolean[MAX_ZOMBIES]; //stores zombies are doing damage to character

//health and being attacked
boolean[] zombieAttacked = new boolean[MAX_ZOMBIES]; //stores which zombies have already been attacked every character attack
int[] zombieHp = new int[MAX_ZOMBIES]; //stores hp of each zombie in percentage of starting health
double[] zombieHpBarX = new double[MAX_ZOMBIES]; //pos of health bar



//CHARACTER:
//character coordinates
int characterY = 585; //start on the ground
int characterX = 700; //start in middle of the screen

int characterDamage = 50; //% of monster health

boolean facingRight = true;
boolean characterUp = true;

//full characterHp
int maxCharacterHp = 100; //will be changed using upgrades
int characterHp = 100; //100%

final double CHARACTER_SPEED = 7; //pixels moved per frame
final double CHARACTER_KNOCKBACK = 35; //pixels monsters move per hit by character

//characterLevel is used to track last place the character was standing, NOT its exact position
int characterLevel = 1; //changed to 1 when character stands on ground, changed to 2 when character stands on platform



//jumping:
int jumpFrame = 0; //used to count how far it is in the jump animation
boolean jumping = false;
final int JUMP_LENGTH = 15;

//falling:
int fallFrame;
boolean falling = false;

//movement:
boolean moveLeft = false;
boolean moveRight = false;

//attacking:
boolean attacking = false;
boolean attackFinished = true;
int attackFrame; //used to count how far in the attack animation the character is
int attackCooldown = 0; //number of frames left before character can attack again
boolean splashAttack = false; //if true, the character can hit multiple zombies with one attack


//USER & WAVE DATA:
int zombiesKilled = 0; // per wave
int zombiesSpawned = 0;
int zombiesPerSpawn = 1;
int zombiesPerWave = 3;
int wave = 1;
int score = 0;
String difficulty = "Easy";


//FONTS AND IMAGES NEED TO BE DECLARED GLOBALLY AND INITALIZED IN SETUP
//declare knight images:
PImage knightLeftUp;
PImage knightLeftUpAttack;
PImage knightLeftDown;
PImage knightLeftDownAttack;
PImage knightRightUp;
PImage knightRightUpAttack;
PImage knightRightDown;
PImage knightRightDownAttack;

//declare zombie images:
PImage zombieLeftUp;
PImage zombieLeftDown;
PImage zombieLeftAttack;
PImage zombieLeftJump;
PImage zombieRightUp;
PImage zombieRightDown;
PImage zombieRightAttack;
PImage zombieRightJump;

//declare background images
PImage bgGameplay;
PImage bgBricks;

//declare button images
PImage pauseButtonUp;
PImage pauseButtonDown;
PImage playButtonUp;
PImage playButtonDown;
PImage bigPlayButtonUp;
PImage bigPlayButtonDown;
PImage buttonShapeUp;
PImage buttonShapeDown;
PImage longButtonShapeUp;
PImage longButtonShapeDown;

//declare other menu images
PImage titleShape;
PImage keyboard;
PImage controlsShape;

//declare fonts:
PFont mainFont;


/*FILE SYSTEM:
Line 1: difficulty
Line 2: wave
Line 3: score
Line 4: characterHp
Line 5: zombiesKilled
*/
//declare file I/O objects
BufferedReader readerSlot1;
BufferedReader readerSlot2;
PrintWriter writerSlot1;
PrintWriter writerSlot2;
int savedWave;


//menu state variable:
//0: main menu
//1: gameplay
//2: paused
//3: help menu
//4: saved games
int menuState = 0;

//buttonPressed variable: takes on various integer values that represent different buttons in each menu
int buttonPressed = 0;

//gameOverFrame variable: used to track the frame at which the gameOver() method was first called
int gameOverFrame = 0;

/**
 * sets up the canvas that processing draws on
 * pre: none
 * post: images have been loaded, size of canvas is set, zombie arrays are properly initialized if needed
 */
void setup() {
  //set size of canvas: 1400px wide, 700px tall
  size(1400, 700);
  

  //create BufferedReaders and PrintWriters
  readerSlot1 = createReader("saveSlot1.txt"); 
  readerSlot2 = createReader("saveSlot2.txt");


  //load knight images
  knightLeftUp = loadImage("knightLeftUp.png");
  knightLeftUpAttack = loadImage("knightLeftUpAttack.png");
  knightLeftDown = loadImage("knightLeftDown.png");
  knightLeftDownAttack = loadImage("knightLeftDownAttack.png");
  knightRightUp = loadImage("knightRightUp.png");
  knightRightUpAttack = loadImage("knightRightUpAttack.png");
  knightRightDown = loadImage("knightRightDown.png");
  knightRightDownAttack = loadImage("knightRightDownAttack.png");

  //load zombie images
  zombieLeftUp = loadImage("zombieLeftUp.png");
  zombieLeftDown = loadImage("zombieLeftDown.png");
  zombieLeftAttack = loadImage("zombieLeftAttack.png");
  zombieLeftJump = loadImage("zombieLeftJump.png");
  zombieRightUp = loadImage("zombieRightUp.png");
  zombieRightDown = loadImage("zombieRightDown.png");
  zombieRightAttack = loadImage("zombieRightAttack.png");
  zombieRightJump = loadImage("zombieRightJump.png");

  //load background images
  bgGameplay = loadImage("castleBackground.png");
  bgBricks = loadImage("darkBrickWall.jpg");
  
  //load button images
  pauseButtonUp = loadImage("pauseButtonUp.png");
  pauseButtonDown = loadImage("pauseButtonDown.png");
  playButtonUp = loadImage("playButtonUp.png");
  playButtonDown = loadImage("playButtonDown.png");
  bigPlayButtonUp = loadImage("bigPlayButtonUp.png");
  bigPlayButtonDown = loadImage("bigPlayButtonDown.png");
  buttonShapeUp = loadImage("buttonShapeUp.png");
  buttonShapeDown = loadImage("buttonShapeDown.png");
  longButtonShapeUp = loadImage("longButtonShapeUp.png");
  longButtonShapeDown = loadImage("longButtonShapeDown.png");
  
  //load other menu images
  titleShape = loadImage("titleShape.png");
  keyboard = loadImage("keyboard.png");
  controlsShape = loadImage("controlsShape.png");
  
  //load and set font to tiny5
  mainFont = createFont("Tiny5-Regular.ttf", 150);


  //initialize all zombie states as 0 (not existing), attack displacements at 0, attack frames as -1 (not attacking), zombieHp as 100
  for (int zombieIndex = 0; zombieIndex < MAX_ZOMBIES; zombieIndex++) {
    zombieState[zombieIndex] = 0;
    zombieAttackFrame[zombieIndex] = -1;
    zombieAttackDisplacement[zombieIndex] = 0;
    zombieHp[zombieIndex] = zombieMaxHp;
  }
}













/**
 * draws everything on screen, is repeated each frame
 * pre: setup method has run
 * post: character, landscape, zombies, background, and platforms drawn
 */
void draw() {

  switch (menuState) {
    case 0: //main menu
      
      //brick background
      background(bgBricks);
      
      
      //title
      imageMode(CENTER);
      image(titleShape, 700, 130, 1350, 180);
      textFont(mainFont, 160);
      fill(145, 50, 205); //purple
      textAlign(CENTER, CENTER);
      text("FORTRESS FIGHT", 710, 130);
      
      //BUTTONS:
      //big play button
      if (buttonPressed != 1) { //big play button not pressed
        image(bigPlayButtonUp, 700, 400, 230, 230); 
        
      } else { //big play button pressed
        image(bigPlayButtonDown, 700, 400, 230, 230);
      }
      
      //help 
      textFont(mainFont, 90);
      if (buttonPressed != 2) { //help button not pressed
        image(buttonShapeUp, 300, 400, 400, 200); 
        text("Help", 300, 400);
        
      } else { //help button pressed
        image(buttonShapeDown, 300, 400, 400, 200);
        text("Help", 300, 413);
      }
           
      //saved games 
      textFont(mainFont, 70);
      if (buttonPressed != 3) { //saved games button not pressed
        image(buttonShapeUp, 1100, 400, 400, 200); 
        text("Saved\nGames", 1100, 400);
        
      } else { //saved games button pressed
        image(buttonShapeDown, 1100, 400, 400, 200);
        text("Saved\nGames", 1100, 413);
      }
      
      //toggle difficulty 
      textFont(mainFont, 60);
      if (buttonPressed != 4) { //toggle difficulty button not pressed
        image(longButtonShapeUp, 700, 610, 675, 135); 
        text("Toggle Difficulty: "+difficulty, 700, 610);
        
      } else { //toggle difficulty button pressed
        image(longButtonShapeDown, 700, 610, 675, 135);
        text("Toggle Difficulty: "+difficulty, 700, 623);
      }
      
      
      break;
  
  
  
    case 1: //gameplay
  
      //background image
      background(bgGameplay);
  
  
      //draw a platform on left side
      stroke(100, 50, 40);
      fill(100, 50, 40);
      rect(300, 495, 200, 20);
      stroke(90, 40, 30);
      fill(90, 40, 30);
      rect(300, 495, 200, 5);
  
      //draw a platform right side
      stroke(100, 50, 40);
      fill(100, 50, 40);
      rect(900, 495, 200, 20);
      stroke(90, 40, 30);
      fill(90, 40, 30);
      rect(900, 495, 200, 5);
      
      
      //draw ground
      fill(20, 15, 45);
      rect(0, 630, 1400, 70);
  
      //SPAWNING ZOMBIES
      //call spawnZombie method for every set number of frames
      if (frameCount % zombieSpawnFrequency == 0) {
  
        //spawn correct amount of zombies
        for (int i = 0; i < zombiesPerSpawn; i++) {
          if (zombiesSpawned < zombiesPerWave && zombiesSpawned < MAX_ZOMBIES) { //put this check inside the for loop to not print extra zombies
            spawnZombie();
            zombiesSpawned++;
          }
        }
      }
  
  
  
      //PARSE THROUGH ZOMBIE ARRAYS FOR PRINTING AND ATTACKING
      for (int zombieIndex = 0; zombieIndex < MAX_ZOMBIES; zombieIndex++) {
        //check zombie death and kill accordingly
        if (zombieHp[zombieIndex] <= 0) {
          killZombie(zombieIndex);
          score += 50;
        }
        if (zombieState[zombieIndex] >= 1 && zombieState[zombieIndex] <=6 ) {
          if (frameCount % 11 == 0) {
            zombieUp[zombieIndex] = !zombieUp[zombieIndex];
          }
  
          rectMode(CENTER);
          if (zombieState[zombieIndex] != 2 && zombieState[zombieIndex] != 4) {
            if (characterX - zombieX[zombieIndex] >= ZOMBIE_SIGHT_RANGE) { // moving right
              zombieState[zombieIndex] = 3;
            } else if (zombieX[zombieIndex] - characterX >=  ZOMBIE_SIGHT_RANGE) { //moving left
              zombieState[zombieIndex] = 1;
            } else if (characterX - zombieX[zombieIndex] >= 0 && characterX - zombieX[zombieIndex] < ZOMBIE_SIGHT_RANGE ) { //moving right attacking
              zombieState[zombieIndex] = 4;
            } else if (zombieX[zombieIndex] - characterX >= 0 && zombieX[zombieIndex] - characterX < ZOMBIE_SIGHT_RANGE) { //moving left attacking
              zombieState[zombieIndex] = 2;
            }
          }
  
          switch (zombieState[zombieIndex]) {
  
          case 1: //moving left
            zombieX[zombieIndex] -= zombieSpeed;
            if (zombieUp[zombieIndex]) { //up position
              image(zombieLeftUp, (float) zombieX[zombieIndex], ZOMBIE_Y, 130, 130);
            } else { //down position
              image(zombieLeftDown, (float) zombieX[zombieIndex], ZOMBIE_Y, 130, 130);
            }
            zombieHpBarX[zombieIndex] = zombieX[zombieIndex] - (55);
            break;
  
          case 2:
            zombieAttackLeft(zombieIndex);
            break;
  
          case 3: //moving right
            zombieX[zombieIndex] += zombieSpeed;
            if (zombieUp[zombieIndex]) { //up position
              image(zombieRightUp, (float) zombieX[zombieIndex], ZOMBIE_Y, 130, 130);
            } else { //down position
              image(zombieRightDown, (float) zombieX[zombieIndex], ZOMBIE_Y, 130, 130);
            }
            zombieHpBarX[zombieIndex] = zombieX[zombieIndex] - 10;
            break;
  
          case 4: //attacking right
            zombieAttackRight(zombieIndex);
            break;
          }
  
          //print zombie health bar
          rectMode(CORNER);
          noStroke();
          fill(255, 0, 0);
          rect((int) zombieHpBarX[zombieIndex], ZOMBIE_Y - 75, ((float) zombieHp[zombieIndex] / (float) zombieMaxHp) * 65, 10);
  
          stroke(200, 200, 200);
          strokeWeight(4);
          noFill();
          rect((int) zombieHpBarX[zombieIndex], ZOMBIE_Y - 75, 65, 10);
          strokeWeight(0);
        }
      }
      rectMode(CORNER);
  
  
      //CHARACTER MOVEMENT:
      //check if character is on screen and which direction it should move, move it accordingly
      if (moveRight) {
        characterX += CHARACTER_SPEED;
      }
      if (moveLeft) {
        characterX -= CHARACTER_SPEED;
      }
  
      //change character up and down every few frames to simulate walking motion
      if (frameCount % 7 == 0) {
        characterUp = !characterUp;
      }
  
      //if character was on level 2 & now off the platform & not already falling
      if (characterLevel == 2 && !onLevel2() && !falling) {
        falling = true;
        fallFrame = 0;
      }
  
      //fall code
      if (falling && !jumping) {
  
        if (characterY < 550) {
          characterY +=  fallFrame;
          fallFrame++;
        } else {
          characterLevel = 1;
          characterY = 585;
          falling = false;
          fallFrame = 0;
        }
  
        if (onLevel2()) {
          characterLevel = 2;
          falling = false;
          jumpFrame = 0;
          fallFrame = 0;
        }
      }
  
      //if character should be jumping
      if (jumping) {
        characterY -= -2 * (jumpFrame - JUMP_LENGTH);
        jumpFrame++;
        falling = false;
        if (jumpFrame == JUMP_LENGTH) {
          jumping = false;
          falling = true;
          fallFrame = 0;
        }
      }
  
  
  
  
  
  
      //CHARACTER ATTACK
      if (attacking) {
  
        if (attackFrame == 0) {
          attackCooldown = 20;
        }
  
        attackFrame++;
  
        closestZombieX = -1000;
        closestZombie = -1;
  
        //parse through zombie arrays to check if they have been hit
        for (int zombieIndex = 0; zombieIndex < MAX_ZOMBIES; zombieIndex++) {
  
  
          //if the zombie is in attack range
          if (characterY > 480 && ((facingRight && zombieX[zombieIndex] - characterX < 100 && zombieX[zombieIndex] - characterX > -20) || (!facingRight && characterX - zombieX[zombieIndex] < 100 && characterX - zombieX[zombieIndex] > -20)) && !zombieAttacked[zombieIndex]) {
  
            if (splashAttack) {
              //damage the zombie and state that it has already been damaged in this attack animation
              zombieHp[zombieIndex] -= characterDamage;
              zombieAttacked[zombieIndex] = true;
  
              //knock the zombies back in the correct direction
              if (facingRight) {
                zombieX[zombieIndex] += CHARACTER_KNOCKBACK;
              } else {
                zombieX[zombieIndex] -= CHARACTER_KNOCKBACK;
              }
  
              //set closestZombie variable to zombieNum with smallest zombieX
            } else if (!splashAttack && Math.abs(closestZombieX - characterX) > Math.abs(zombieX[zombieIndex] - characterX)) {
              closestZombieX = zombieX[zombieIndex];
              closestZombie = zombieIndex;
            }
          }
        }
  
        if (closestZombie != -1) { //this for loop needs to be put first otherwise it will index -1 which is out of bounds
          if (!splashAttack && !zombieAttacked[closestZombie]) {
            //damage the zombie and state that it has already been damaged in this attack animation
            zombieHp[closestZombie] -= characterDamage;
  
            //knock the zombies back in the correct direction
            if (facingRight) {
              zombieX[closestZombie] += CHARACTER_KNOCKBACK;
            } else {
              zombieX[closestZombie] -= CHARACTER_KNOCKBACK;
            }
  
            //only one zombie can be attacked when splashAttack is off, so this loop sets all zombie to having been attacked to ensure that none can be attacked again
            for (int zombieIndex = 0; zombieIndex < MAX_ZOMBIES; zombieIndex++) {
              zombieAttacked[zombieIndex] = true;
            }
          }
        }
  
        //end character attack if it has been going for 20 frames
        if (attackFrame > 20) {
          attacking = false;
          attackFrame = -1;
        }
      }
  
      //progress attackCooldown
      if (attackCooldown > 0) {
        attackCooldown--;
      }
  
  
      //DRAW UI AT TOP OF SCREEN
      
      //ensure characterHp doesn't go below 0
      if (characterHp <= 0) {
        characterHp = 0;
      }
      
      //Character health bar:
      //inside
      rectMode(CORNER);
      noStroke();
      fill(255, 20, 20);
      rect(50, 60, characterHp * 3, 60);
  
      //outside
      stroke(200, 200, 200);
      strokeWeight(12);
      noFill();
      rect(50, 60, 300, 60);
  
      //label
      textFont(mainFont, 40);
      fill(255, 255, 255);
      textAlign(LEFT, TOP);
      text("KNIGHT HP", 50, 20);
  
  
      //wave progress bar:
      //inside
      rectMode(CORNER);
      noStroke();
      fill(255, 255, 20); //yellow
      rect(1050, 60, (float) zombiesKilled / (float) zombiesPerWave * 300, 60); //zombiesKilled and zombiesPerWave are cast as floats to avoid unwanted rounding
  
      //outside
      stroke(200, 200, 200); //grey
      strokeWeight(12); //border only
      noFill();
      rect(1050, 60, 300, 60);
      strokeWeight(0);
  
      //wave progress label
      textFont(mainFont, 40);
      fill(255, 255, 255);
      textAlign(RIGHT, TOP);
      text("WAVE PROGRESS", 1350, 20);
  
  
      //waves label:
      textFont(mainFont, 40);
      fill(255, 255, 255);
      textAlign(CENTER, TOP);
      text("WAVE: \n"+wave, 525, 25);
  
      //score label:
      textFont(mainFont, 40);
      fill(255, 255, 255);
      textAlign(CENTER, TOP);
      text("SCORE: \n"+score, 875, 25);
  
      //draw pause button
      imageMode(CENTER);
      if (buttonPressed != 1) { //pause button not pressed
        image(pauseButtonUp, 700, 60, 80, 80);
        
      } else { //pause button being pressed
        image(pauseButtonDown, 700, 60, 80, 80);
      }
  
  
  
      //ENSURE CHARACTER STAYS ON SCREEN
      if (characterX > 1400) {
        characterX = 1400;
      } else if (characterX < 0) {
        characterX = 0;
      }
  
      //DRAW CHARACTER:
      imageMode(CENTER);
  
      //facing left and not attacking
      if (!facingRight && !attacking) {
  
        //not moving or moving left and character up
        if ((characterUp && moveLeft) || !moveLeft) {
          image(knightLeftUp, characterX, characterY, 110, 110);
          //moving left (and character down)
        } else if (moveLeft) {
          image(knightLeftDown, characterX, characterY, 110, 110);
        }
  
        //facing left and attacking
      } else if (!facingRight && attacking) {
  
        //not moving or moving left and character up
        if ((characterUp && moveLeft) || !moveLeft) {
          image(knightLeftUpAttack, characterX, characterY, 110, 110);
  
          //moving left (and character down)
        } else if (moveLeft) {
          image(knightLeftDownAttack, characterX, characterY, 110, 110);
        }
  
        //facing right and not attacking
      } else if (facingRight && !attacking) {
  
        //not moving or moving right and character up
        if ((characterUp && moveRight) || !moveRight) {
          image(knightRightUp, characterX, characterY, 110, 110);
  
          //moving right (and character down)
        } else if (moveRight) {
          image(knightRightDown, characterX, characterY, 110, 110);
        }
  
        //facing right and attacking
      } else if (facingRight && attacking) {
  
        //not moving or moving right and character up
        if ((characterUp && moveRight) || !moveRight) {
          image(knightRightUpAttack, characterX, characterY, 110, 110);
  
          //moving right (and character down)
        } else if (moveRight) {
          image(knightRightDownAttack, characterX, characterY, 110, 110);
        }
      }
  
  
      //draw cooldown bar
      rectMode(CORNER);
      if (facingRight && attackCooldown > 0) { //facing right (different X position than left)
        //inside
        noStroke();
        fill(20, 20, 255); //blue
        rect(characterX - 50, characterY - 70, attackCooldown * 3, 10);
  
        //outside
        stroke(200, 200, 200); //grey
        strokeWeight(4); //border of the bar
        noFill();
        rect(characterX - 50, characterY - 70, 60, 10);
        strokeWeight(0);
      } else if (!facingRight && attackCooldown > 0) { //facing left
        //inside
        noStroke();
        fill(20, 20, 255); //blue
        rect(characterX - 10, characterY - 70, attackCooldown * 3, 10);
  
        //outside
        stroke(200, 200, 200); //grey
        strokeWeight(4); //border of the bar
        noFill();
        rect(characterX - 10, characterY - 70, 60, 10);
        strokeWeight(0);
      }
  
  
  
  
  
      //DRAW TRANSPARENT RED ON SCREEN WHEN CHARACTER IS DAMAGED
      for (int zombieIndex = 0; zombieIndex < MAX_ZOMBIES; zombieIndex++) {
        if (zombieDamaging[zombieIndex] && characterHp > 0) {
          fill(255, 0, 0, 50);
          rect(0, 0, 1400, 700);
        }
      }
  
  
      //CHECK FOR CHARACTER DEATH
      if (characterHp <= 0) {
        gameOver();
      }
  
  
      //CHECK IF USER HAS KILLED ALL ZOMBIES
      if (zombiesKilled >= zombiesPerWave) {
        nextWave();
      }
      
      break;
  
  
  
  
    case 2: //paused
      background(bgBricks);
  
      //DRAW UI AT TOP OF SCREEN
  
      //Character health bar:
      //inside
      rectMode(CORNER);
      noStroke();
      fill(255, 20, 20);
      rect(50, 60, characterHp * 3, 60);
  
      //outside
      stroke(200, 200, 200);
      strokeWeight(12);
      noFill();
      rect(50, 60, 300, 60);
  
      //label
      textFont(mainFont, 40);
      fill(255, 255, 255);
      textAlign(LEFT, TOP);
      text("KNIGHT HP", 50, 20);
  
  
      //wave progress bar:
      //inside
      rectMode(CORNER);
      noStroke();
      fill(255, 255, 20); //yellow
      rect(1050, 60, (float) zombiesKilled / (float) zombiesPerWave * 300, 60); //zombiesKilled and zombiesPerWave are cast as floats to avoid unwanted rounding
  
      //outside
      stroke(200, 200, 200); //grey
      strokeWeight(12); //border only
      noFill();
      rect(1050, 60, 300, 60);
      strokeWeight(0);
  
      //wave progress label
      textFont(mainFont, 40);
      fill(255, 255, 255);
      textAlign(RIGHT, TOP);
      text("WAVE PROGRESS", 1350, 20);
  
  
      //waves label:
      textFont(mainFont, 40);
      fill(255, 255, 255);
      textAlign(CENTER, TOP);
      text("WAVE: \n"+wave, 525, 25);
  
      //score label:
      textFont(mainFont, 40);
      fill(255, 255, 255);
      textAlign(CENTER, TOP);
      text("SCORE: \n"+score, 875, 25);
      
      //BUTTONS:  
      //draw play button
      imageMode(CENTER);
      if (buttonPressed != 1) { //play button not pressed
        image(playButtonUp, 700, 60, 80, 80);
        
      } else { //play button being pressed
        image(playButtonDown, 700, 60, 80, 80);
      }
      
      fill(145, 50, 205); //purple
      textAlign(CENTER, CENTER);
      
      //save slot 1 
      textFont(mainFont, 70);
      if (buttonPressed != 2) { //save slot 1 button not pressed
        image(buttonShapeUp, 400, 325, 400, 200); 
        text("Save: Slot 1", 400, 325);
        
      } else { //save slot 1 button pressed
        image(buttonShapeDown, 400, 325, 400, 200);
        text("Save: Slot 1", 400, 338);
      }
      
      //save slot 2
      textFont(mainFont, 70);
      if (buttonPressed != 3) { //save slot 2 button not pressed
        image(buttonShapeUp, 1000, 325, 400, 200); 
        text("Save: Slot 2", 1000, 325);
        
      } else { //save slot 2 button pressed
        image(buttonShapeDown, 1000, 325, 400, 200);
        text("Save: Slot 2", 1000, 338);
      }
      
      //back to main menu
      textFont(mainFont, 60);
      if (buttonPressed != 4) { //main menu button not pressed
        image(buttonShapeUp, 700, 550, 400, 200); 
        text("Back to\nMain Menu", 700, 550);
        
      } else { //main menu button pressed
        image(buttonShapeDown, 700, 550, 400, 200);
        text("Back to\nMain Menu", 700, 563);
      }
      
      break;
    
    case 3: //help menu
      background(bgBricks);
      
      //TITLE:
      fill(145, 50, 205); //purple
      textFont(mainFont, 100);
      image(titleShape, 700, 100, 900, 120);
      text("HELP", 700, 100);
      
      //DESCRIPTION
      fill(255, 255, 255);
      textSize(35);
      text("Welcome to Fortress Fight! You are a fierce knight, defending your castle\nagainst endless hordes of zombies. Use the controls shown below to destroy them!", 700, 220);
      
      //KEYBOARD
      imageMode(CENTER);
      image(keyboard, 575, 425, 1038, 276);
      image(controlsShape, 1250, 425, 210, 280);
      
      //COLOURED LEGEND
      textSize(55);
      //"pause" coloured text
      fill(255, 194, 14); //yellow
      text("Pause", 1250, 325);
      
      //"jump" coloured text
      fill(34, 177, 76); //green
      text("Jump", 1250, 390);
      
      //"move" coloured text
      fill(77, 109, 243); // blue
      text("Move", 1250, 455);
      
      //"attack" coloured text
      fill(237, 28, 36); //red
      text("Attack", 1250, 520);
      
      
      //back button
      fill(145, 50, 205); //purple
      textFont(mainFont, 70);
      if (buttonPressed != 1) { //back button not pressed
        image(buttonShapeUp, 700, 631, 240, 120); 
        text("Back", 700, 631);
        
      } else { //back button pressed
        image(buttonShapeDown, 700, 631, 240, 120);
        text("Back", 700, 642);
      }
      
      
      
      break;
      
    case 4: //saved games menu
      background(bgBricks);
      
      imageMode(CENTER);
      
      //TITLE:
      fill(145, 50, 205); //purple
      textFont(mainFont, 100);
      image(titleShape, 700, 100, 900, 120);
      text("SAVED GAMES", 700, 100);
      
      //BUTTONS:      
      //load slot 1 
      textFont(mainFont, 70);
      if (buttonPressed != 1) { //load slot 1 button not pressed
        image(buttonShapeUp, 400, 375, 400, 200); 
        text("Load Slot 1", 400, 375);
        
      } else { //load slot 1 button pressed
        image(buttonShapeDown, 400, 375, 400, 200);
        text("Load Slot 1", 400, 388);
      }
      
      //load slot 2
      textFont(mainFont, 70);
      if (buttonPressed != 2) { //load slot 2 button not pressed
        image(buttonShapeUp, 1000, 375, 400, 200); 
        text("Load Slot 2", 1000, 375);
        
      } else { //load slot 2 button pressed
        image(buttonShapeDown, 1000, 375, 400, 200);
        text("Load Slot 2", 1000, 388);
      }
      
      //back button
      textFont(mainFont, 70);
      if (buttonPressed != 3) { //back button not pressed
        image(buttonShapeUp, 700, 600, 300, 150); 
        text("Back", 700, 600);
        
      } else { //back button pressed
        image(buttonShapeDown, 700, 600, 300, 150);
        text("Back", 700, 613);
      }
      
      break;
  }
} //END DRAW METHOD






//this giant whitespace is here to very clearly separate the draw method (which is the largest and most important) with the other methods








/**
 * checks if the mouse is clicked (used to attack and press buttons)
 * pre: none
 * post: attacking = true (if cooldown is finished and attack animation is still going)
 */
void mousePressed() {
  switch (menuState) {
    case 0: //main menu
      
      //press big play button
      if (mouseX > 585 && mouseX < 815 && mouseY > 285 && mouseY < 515) {
        buttonPressed = 1;
        
      //press help button
      } else if (mouseX > 100 && mouseX < 500 && mouseY > 300 && mouseY < 500) {
        buttonPressed = 2;
        
      //press saved games button
      } else if (mouseX > 900 && mouseX < 1300 && mouseY > 300 && mouseY < 500) {
        buttonPressed = 3;
        
      //press toggle difficulty button 700, 610, 675, 135
      } else if (mouseX > 362.5 && mouseX < 1037.5 && mouseY > 542.5 && mouseY < 677.5) {
        buttonPressed = 4;
      }
      
      break;
      
    case 1: //gameplay 
      //attacking
      if (attackFrame >= 0 && attackCooldown == 0 && characterHp > 0) {
        attacking = true;
      }
      
      //press pause button
      if (mouseX > 660 && mouseX < 740 && mouseY > 20 && mouseY < 100) { 
        buttonPressed = 1;  
      }
      
      break;
      
    case 2: //paused
      // press play button
      if (mouseX > 660 && mouseX < 740 && mouseY > 20 && mouseY < 100) { 
        buttonPressed = 1;
        
      //press save slot 1 button
      } else if (mouseX > 200 && mouseX < 600 && mouseY > 225 && mouseY < 425) {
        buttonPressed = 2;
        
      //press save slot 2 button
      } else if (mouseX > 800 && mouseX < 1200 && mouseY > 225 && mouseY < 425) {
        buttonPressed = 3;
      
      
      //press back to main menu button
      } else if (mouseX > 500 && mouseX < 900 && mouseY > 450 && mouseY < 650) {
        buttonPressed = 4;
      }
      break;
      
    case 3: //help
      //back button
      if (mouseX > 550 && mouseX < 850 && mouseY > 525 && mouseY < 675) {
        buttonPressed = 1;
      }
      break;
      
      
      
    case 4: //save games menu 
      //press load slot 1 button
      if (mouseX > 200 && mouseX < 600 && mouseY > 275 && mouseY < 475) {
        buttonPressed = 1;
        
      //press load slot 2 button
      } else if (mouseX > 800 && mouseX < 1200 && mouseY > 275 && mouseY < 475) {
        buttonPressed = 2;
        
      //press back button
      } else if (mouseX > 550 && mouseX < 850 && mouseY > 525 && mouseY < 675) {
        buttonPressed = 3;
      }
      break;
  }
  
}

/**
 * checks if the mouse is clicked (used to release attack)
 * pre: none
 * post: attacking = false, attackFrame = 0, all zombieAttacked = false
 */
void mouseReleased() {
  switch (menuState) {
    case 0: //main menu
      
      //release big play button
      if (buttonPressed == 1) {
        menuState = 1;
        initializeGameplay();
        buttonPressed = 0; //reset
        
      //release help button
      } else if (buttonPressed == 2) {
        menuState = 3;
        buttonPressed = 0; //reset
        
      //release saved games button
      } else if (buttonPressed == 3) {
        menuState = 4;
        buttonPressed = 0; //reset
      
      //release toggle difficulty button
      } else if (buttonPressed == 4) {
        
        //cycle difficulty from easy to mid, mid to hard, hard to easy, with each toggle
        if (difficulty.equals("Easy")) {
          difficulty = "Mid";
        } else if (difficulty.equals("Mid")) {
          difficulty = "Hard";
        } else if (difficulty.equals("Hard")) {
          difficulty = "Easy";
        }
        
        buttonPressed = 0; //reset
      }
      
      break;
      
    case 1: //gameplay 
      //stop attacking - same as j released
      attacking = false;
      attackFrame = 0;
      for (int zombieIndex = 0; zombieIndex < MAX_ZOMBIES; zombieIndex++) {
        zombieAttacked[zombieIndex] = false;
      }
      
      //release pause button
      if (buttonPressed == 1) { 
        menuState = 2;
        buttonPressed = 0; //reset
      }
      
      break;
      
    case 2: //paused
      //release play button
      if (buttonPressed == 1) { 
        menuState = 1;
        buttonPressed = 0; //reset
        
      //release save slot 1 button
      } else if (buttonPressed == 2) {
        buttonPressed = 0; //reset
        
        //"create" the save file by clearing it from all current text
        writerSlot1 = createWriter("saveSlot1.txt");
        
        //print stats to file
        writerSlot1.println(difficulty);
        writerSlot1.println(wave);
        writerSlot1.println(score);
        writerSlot1.println(characterHp);
        writerSlot1.println(zombiesKilled);
        
        //flush and close writer to ensure the text is written to the file
        writerSlot1.flush();
        writerSlot1.close();
        
        
      //release save slot 2 button
      } else if (buttonPressed == 3) {
        buttonPressed = 0; //reset
        
        //"create" the save file by clearing it from all current text
        writerSlot2 = createWriter("saveSlot2.txt");
        
        //print stats to file
        writerSlot2.println(difficulty);
        writerSlot2.println(wave);
        writerSlot2.println(score);
        writerSlot2.println(characterHp);
        writerSlot2.println(zombiesKilled);
        
        //flush and close writer to ensure the text is written to the file
        writerSlot2.flush();
        writerSlot2.close();
      
      //release main menu button
      } else if (buttonPressed == 4) {
        buttonPressed = 0; //reset
        menuState = 0;
        
        //reset all variables in order to restart the game
        characterHp = maxCharacterHp;
        for (int zombieIndex = 0; zombieIndex < MAX_ZOMBIES; zombieIndex++) {
          killZombie(zombieIndex);
        }
        score = 0;
        wave = 1;
        zombiesKilled = 0;
        zombiesSpawned = 0;
      }
      break;
    
    case 3:
      //release back button
      if (buttonPressed == 1) {
        buttonPressed = 0;
        menuState = 0;
      }
      break;
    
    case 4:
      //release load slot 1 button
      if (buttonPressed == 1) {
        buttonPressed = 0;
        menuState = 1; //set to gameplay
        
        try {
          //set all values to values in the file
          difficulty = readerSlot1.readLine(); 
          savedWave = Integer.parseInt(readerSlot1.readLine()); // store saved wave in a seperate variable so that the readLine method is only called once
          while (wave < savedWave) {
            nextWave(); //call nextWave repeatedly to instantaneoulsy go to the correct wave
          }
          score = Integer.parseInt(readerSlot1.readLine());
          characterHp = Integer.parseInt(readerSlot1.readLine());
          zombiesKilled = Integer.parseInt(readerSlot1.readLine());
          zombiesSpawned = zombiesKilled; //to simplify saving process, zombiesSpawned and zombiesKilled are equal
          
        } catch (IOException e) { //thrown when reading a line
          e.printStackTrace(); //print stack trace to console (which describes the nature of the error)
        } catch (NumberFormatException e) { //thrown if the line is blank
          println("ERROR: file is empty or did not save properly."); //print error message to console
        }
        
        
      //release load slot 2 button
      } else if (buttonPressed == 2) {
        buttonPressed = 0;
        menuState = 1; //set to gameplay
        
        try {
          //set all values to values in the file
          difficulty = readerSlot2.readLine(); 
          initializeGameplay();
          savedWave = Integer.parseInt(readerSlot2.readLine()); // store saved wave in a seperate variable so that the readLine method is only called once
          while (wave < savedWave) {
            nextWave(); //call nextWave repeatedly to instantaneoulsy go to the correct wave
          }
          score = Integer.parseInt(readerSlot2.readLine()); 
          characterHp = Integer.parseInt(readerSlot2.readLine());
          zombiesKilled = Integer.parseInt(readerSlot2.readLine()); 
          zombiesSpawned = zombiesKilled; //to simplify saving process, zombiesSpawned and zombiesKilled are equal
          
        } catch (IOException e) { //thrown when reading a line
          e.printStackTrace(); //print stack trace to console (which describes the nature of the error)
        } catch (NumberFormatException e) { //thrown if the line is blank
          println("ERROR: file is empty or did not save properly."); //print error message to console
        }
        
      
      //release back button
      } else if (buttonPressed == 3) {
        buttonPressed = 0;
        menuState = 0;
      }
      break;
    
  }
  
}



/**
 * detects key presses and does the corresponding action to releasing that key
 * pre: none
 * post: none
 */
void keyPressed() {
  switch (menuState) { // for buttons
    case 0: //main menu
      
      //press enter: play from main menu 
      if (key == ENTER) {
        buttonPressed = 1;
      }
      
      break;
      
    case 1: //gameplay 
      
      //press tab: pause
      if (key == TAB && characterHp > 0) {
        buttonPressed = 1;
      }
      break;
      
    case 2: //paused
      //press tab: play
      if (key == TAB) {
        buttonPressed = 1;
      }
      break;
  }
  //d/D: move right
  if ((key == 'd' || key == 'D') && characterHp > 0) {
    moveRight = true;
    facingRight = true;
  
  //a/A: move left
  } else if ((key == 'a' || key == 'A') && characterHp > 0) {
    moveLeft = true;
    facingRight = false;
  }
  
  //j/J/s/S: attack
  if ((key == 'j' || key == 'J' || key == 's' || key == 'S') && attackFrame >= 0 && attackCooldown == 0 && characterHp > 0) {
    attacking = true;
  }
  
  //' '/w/W: jump
  if ((key == ' ' || key == 'w' || key == 'W') && !jumping && !falling && characterHp > 0) {
    jumping = true;
    jumpFrame = 0;
  }
  
  
}


/**
 * detects key releases and does the corresponding action to releasing that key
 * pre: none
 * post: none
 */
void keyReleased() {
  switch (menuState) { // for buttons
    case 0: //main menu
      
      //release enter: play from main menu
      if (key == ENTER) {
        menuState = 1; //set to gameplay
        initializeGameplay();
        buttonPressed = 0; //reset
      }
      
      break;
      
    case 1: //gameplay 
      
      //release tab: pause
      if (key == TAB && characterHp > 0) {
        menuState = 2; //set to pause menu
        buttonPressed = 0; //reset
      }
      break;
      
    case 2: //paused
      //release tab: play
      if (key == TAB) {
        menuState = 1; //set to gameplay
        buttonPressed = 0; //reset
      }
      break;
  }
  
  //d/D: stop moving right
  if (key == 'd' || key == 'D') {

    if (moveRight && moveLeft) {
      facingRight = false; //to ensure the character faces the right direction
    }

    moveRight = false;
  
  //a/A: stop moving left
  } else if (key == 'a' || key == 'A') {

    if (moveRight && moveLeft) {
      facingRight = true; //to ensure the character faces the right direction
    }

    moveLeft = false;
  }
  
  //j/J/s/S: stop attacking
  if (key == 'j' || key == 'J' || key == 's' || key == 'S') {
    attacking = false;
    attackFrame = 0;
    for (int zombieIndex = 0; zombieIndex < MAX_ZOMBIES; zombieIndex++) {
      zombieAttacked[zombieIndex] = false; //resets all zombies to allow them to be attacked again
    }
  }
}

/**
 * sets certain zombie and character variables to various values to correspond to selected difficulty
 * pre: none
 * post: zombies and character are set to act like they should for each difficulty
 */
void initializeGameplay() {
  //easy difficulty:
  if (difficulty.equals("Easy")) {
    zombieDamage = 5;
    zombieMaxHp = 90;
    characterDamage = 70;
    zombieSpeed = 0.8;
    zombiesPerWave = 2;
    zombiesPerSpawn = 1;
    
  //mid difficulty:
  } else if (difficulty.equals("Mid")) {
    zombieDamage = 10;
    zombieMaxHp = 100;
    characterDamage = 50;
    zombieSpeed = 1.2;
    zombiesPerWave = 3;
    zombiesPerSpawn = 1;
    
  //hard difficulty
  } else if (difficulty.equals("Hard")) {
    zombieDamage = 20;
    zombieMaxHp = 130;
    characterDamage = 50;
    zombieSpeed = 2.2;
    zombiesPerWave = 4;
    zombiesPerSpawn = 2;
  }
}

/**
 * checks if the character is on one of the platforms
 * pre: none
 * post: wave variable is incremented, zombieDamage and zombieHp and zombieSpeed increased, zombiesKilled and zombiesSpawned reset to zero, refill characterHp to full
 */
void nextWave() {
  wave++;
  
  //kill all zombies to be sure
  for (int zombieIndex = 0; zombieIndex < MAX_ZOMBIES; zombieIndex++) {
    killZombie(zombieIndex);
  }
  
  //variables changed to increase difficulty
  zombieDamage += 1;
  zombieMaxHp += 15;
  zombieSpeed += 0.15;
  zombiesPerWave += 1;
  zombieSpawnFrequency -= 20;
  if (wave % 4 == 0) { //increase zombies per spawn and reset spawn frequency every 4 waves
    zombiesPerSpawn++;
    zombieSpawnFrequency = 300;
  }
  
  //variables that need to be resetted
  zombiesKilled = 0;
  zombiesSpawned = 0;
  characterHp = maxCharacterHp;
}

/**
 * end the game (called when character dies)
 * pre: none
 * post: game stops being drawn and "GAME OVER" text is displayed
 */
void gameOver() {
  textFont(mainFont, 150);
  fill(255, 0, 0);
  textAlign(CENTER);
  text("GAME OVER", 700, 300);
  
  //if gameOverFrame has not been reinitialized to start counting, reinitialize it
  if (gameOverFrame == 0) {
    gameOverFrame = frameCount;
    
  //if it has been between 0 and 250 frames since gameOver was first called, fill the screen with an increasingly darker black rectangle
  } else if (frameCount - gameOverFrame < 250 && frameCount - gameOverFrame > 0) {
    rectMode(CORNER);
    fill(0, (frameCount - gameOverFrame) * 1.5); //black, alpha value of the fill is set to increasingly larger amounts each frame which decreases transparency
    rect(0, 0, 1400, 700); //fill the screen
  
  //if it has been more than 250 frames since gameOver was first called, go back to main menu and reset variables that need to be resetted to restart the game
  } else if (frameCount - gameOverFrame > 250) {
    menuState = 0; // back to main menu
    
    //reset variables that need to be resetted to restart the game
    characterHp = maxCharacterHp;
    for (int zombieIndex = 0; zombieIndex < MAX_ZOMBIES; zombieIndex++) {
      killZombie(zombieIndex);
    }
    score = 0;
    wave = 1;
    zombiesKilled = 0;
    zombiesSpawned = 0;
    gameOverFrame = 0; //reset frame counter for gameOver so that it can work next time it is called
  }
}



/**
 * checks if the character is on one of the platforms
 * @return true if the character position is on any of the platforms, false if not
 * pre: none
 * post: none
 */
boolean onLevel2() {
  return ((characterY > 440 && characterY < 470) && ((characterX > 285 && characterX < 515) || (characterX > 890 && characterX < 1115)));
}


/**
 * checks if a zombie has less than or equal to zero health, if it is, changes its values to show that it is dead and changes the score and zombiesKilled accordingly
 * @param zombieIndex: index of the zombie to check
 * pre: none
 * post: if zombie health is less than zero, zombie state and other values will be changed to show that it is dead, zombiesKilled and score are incremented accordingly
 */
void killZombie(int zombieIndex) {
  zombieHp[zombieIndex] = zombieMaxHp;
  zombieState[zombieIndex] = 0;
  zombieAttackFrame[zombieIndex] = 0;
  zombieDamaging[zombieIndex] = false;
  zombiesKilled++;
}

/**
 * places a zombie at a random distance (0-100 or 250-350 pixels) off of the left or right side of the screen
 * pre: none
 * post: zombie placed
 */
void spawnZombie() {

  //use for loop to find first empty slot in array
  for (int zombieIndex = 0; zombieIndex < MAX_ZOMBIES; zombieIndex++) {
    if (zombieState[zombieIndex] == 0) {

      zombieUp[zombieIndex] = true;
      zombieHp[zombieIndex] = zombieMaxHp;

      //randomly decide whether to spawn on left or right side
      if (Math.random() < 0.5) { //left side
        zombieX[zombieIndex] =  -65 - zombieSpawnDistance;
        zombieState[zombieIndex] = 3;
      } else { //right side
        zombieX[zombieIndex] = 1465 + zombieSpawnDistance;
        zombieState[zombieIndex] = 1;
      }


      //alternate between 0-100 px from screen to 250-350 px from screen
      if (zombieSpawnDistance < 100) {
        zombieSpawnDistance = 250.0 + Math.random() * 100.0;
      } else if (zombieSpawnDistance > 250) {
        zombieSpawnDistance = Math.random() * 100.0;
      }


      break; //break to ensure only one zombie is created
    }
  }
}



/**
 * progresses the zombie in the left attack animation by one frame and checks whether the zombie has done damage to the character
 * @param zombieNum an int used to index the zombie arrays
 * pre: zombieNum is in range of the array
 * post: zombie attack left animation has been progressed by one frame
 */
void zombieAttackLeft(int zombieNum) {
  //println(zombieAttackDisplacement[zombieNum]+" "+zombieDamaging[zombieNum]);
  //if the attack hasn't started
  if (zombieAttackFrame[zombieNum] < 0) {
    zombieAttackFrame[zombieNum] = 0;
    image(zombieLeftAttack, (float) zombieX[zombieNum], ZOMBIE_Y, 130, 130);
    zombieAttackFrame[zombieNum]++;

    //wind up attack
  } else if (zombieAttackFrame[zombieNum] >= 0 && zombieAttackFrame[zombieNum] < ZOMBIE_JUMP_FRAME) {
    image(zombieLeftAttack, (float) zombieX[zombieNum], ZOMBIE_Y, 130, 130);
    zombieAttackFrame[zombieNum]++;
    zombieHpBarX[zombieNum] = zombieX[zombieNum] - 10;

    //jump forward - frame counting stops and displacement counting starts
  } else if (zombieAttackFrame[zombieNum] == ZOMBIE_JUMP_FRAME) {
    zombieX[zombieNum] -= ZOMBIE_JUMP_SPEED;
    zombieAttackDisplacement[zombieNum] += ZOMBIE_JUMP_SPEED;
    image(zombieLeftJump, (float) zombieX[zombieNum], ZOMBIE_Y, 130, 130);
    zombieHpBarX[zombieNum] = zombieX[zombieNum] - 55;

    //check if zombie was near character (should do damage)
    if (Math.abs(zombieX[zombieNum] - characterX) <= ZOMBIE_JUMP_SPEED && characterY > 470) {
      zombieDamaging[zombieNum] = true;
      characterX -= ZOMBIE_KNOCKBACK;
    }

    //check if zombie has travelled the full attack displacement
    if (zombieAttackDisplacement[zombieNum] > ZOMBIE_MAX_ATTACK_DISPLACEMENT) {
      zombieAttackFrame[zombieNum]++;
      if (zombieDamaging[zombieNum]) {
        characterHp -= zombieDamage;
        zombieDamaging[zombieNum] = false;
      }
    }

    //stand still - frame counting restarts and displacement counting stops
  } else if (zombieAttackFrame[zombieNum] > ZOMBIE_JUMP_FRAME && zombieAttackFrame[zombieNum] <= ZOMBIE_ATTACK_END_FRAME) {
    image(zombieLeftUp, (float) zombieX[zombieNum], ZOMBIE_Y, 130, 130);
    zombieAttackFrame[zombieNum]++;
    zombieAttackDisplacement[zombieNum] = 0;
    zombieHpBarX[zombieNum] = zombieX[zombieNum] - 55;

    //stop attack animation
  } else if (zombieAttackFrame[zombieNum] > ZOMBIE_ATTACK_END_FRAME) {
    zombieAttackFrame[zombieNum] = -1;
    zombieState[zombieNum] = 1;
    image(zombieLeftUp, (float) zombieX[zombieNum], ZOMBIE_Y, 130, 130);
  }
}

/**
 * progresses the zombie in the left attack animation by one frame and checks whether the zombie has done damage to the character
 * @param zombieNum an int used to index the zombie arrays
 * pre: zombieNum is in range of the array
 * post: zombie attack right animation has been progressed by one frame
 */
void zombieAttackRight(int zombieNum) {
  //println(zombieAttackDisplacement[zombieNum]+" "+zombieDamaging[zombieNum]);
  //if the attack hasn't started
  if (zombieAttackFrame[zombieNum] < 0) {
    zombieAttackFrame[zombieNum] = 0;
    image(zombieRightAttack, (float) zombieX[zombieNum], ZOMBIE_Y, 130, 130);
    zombieAttackFrame[zombieNum]++;

    //wind up attack
  } else if (zombieAttackFrame[zombieNum] >= 0 && zombieAttackFrame[zombieNum] < ZOMBIE_JUMP_FRAME) {
    image(zombieRightAttack, (float) zombieX[zombieNum], ZOMBIE_Y, 130, 130);
    zombieAttackFrame[zombieNum]++;
    zombieHpBarX[zombieNum] = zombieX[zombieNum] - 55;

    //jump forward - **FRAME COUNTING STOPS** and displacement counting starts
  } else if (zombieAttackFrame[zombieNum] == ZOMBIE_JUMP_FRAME) {
    zombieX[zombieNum] += ZOMBIE_JUMP_SPEED;
    zombieAttackDisplacement[zombieNum] += ZOMBIE_JUMP_SPEED;
    image(zombieRightJump, (float) zombieX[zombieNum], ZOMBIE_Y, 130, 130);
    zombieHpBarX[zombieNum] = zombieX[zombieNum] - 10;

    //check if zombie is near character (should do damage)
    if (Math.abs(zombieX[zombieNum] - characterX) <= ZOMBIE_JUMP_SPEED && characterY > 470) {
      zombieDamaging[zombieNum] = true;
      characterX += ZOMBIE_KNOCKBACK;
    }

    //check if zombie has travelled the full attack displacement
    if (zombieAttackDisplacement[zombieNum] > ZOMBIE_MAX_ATTACK_DISPLACEMENT) {
      zombieAttackFrame[zombieNum]++;
      if (zombieDamaging[zombieNum]) {
        characterHp -= zombieDamage;
        zombieDamaging[zombieNum] = false;
      }
    }

    //stand still - frame counting restarts and displacement counting stops
  } else if (zombieAttackFrame[zombieNum] > ZOMBIE_JUMP_FRAME && zombieAttackFrame[zombieNum] <= ZOMBIE_ATTACK_END_FRAME) {
    image(zombieRightUp, (float) zombieX[zombieNum], ZOMBIE_Y, 130, 130);
    zombieAttackFrame[zombieNum]++;
    zombieAttackDisplacement[zombieNum] = 0;
    zombieHpBarX[zombieNum] = zombieX[zombieNum] - 10;

    //stop attack animation
  } else if (zombieAttackFrame[zombieNum] > ZOMBIE_ATTACK_END_FRAME) {
    zombieAttackFrame[zombieNum] = -1;
    zombieState[zombieNum] = 3;
    image(zombieRightUp, (float) zombieX[zombieNum], ZOMBIE_Y, 130, 130);
  }
}
