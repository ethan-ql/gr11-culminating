/**
* This program is a game in which the user plays as a knight fighting against monsters and trying to survive through increasingly difficult waves.
* When run, the user is presented with a game menu in which they can access settings, save their game, and 
* The user can press a and d to move left or right, space to jump, and j to attack.
*
* @author  Ethan Lau
* @version 1.0
* @since   2024-1-1
*/



//GLOBAL VARIABLES: CAN BE USED IN ANY METHOD

//zombie attributes:
double zombieSpeed = 1.2; //pixels moved per frame
final int MAX_ZOMBIES = 20; //arbitrary number, set relatively small to save memory
final int ZOMBIE_Y = 440; //zombies can't jump or move up so their y is a constant
final int ZOMBIE_SPAWN_FREQUENCY = 300; //frames between zombie spawing

//zombie array attributes: stored in an array because these attributes can be different for each zombie

//stores x pos of each zombie
float[] zombieX = new float[MAX_ZOMBIES]; 

//stores whether each zombie is in up or down pos
boolean[] zombieUp = new boolean[MAX_ZOMBIES]; 

//array containing the state of each zombie as follows: 
//0 = doesn't exist
//1 = moving left, 2 = attacking left
//3 = moving right, 4 = attacking right
int[] zombieState = new int[MAX_ZOMBIES];

//stores the frame of the attack animation that each zombie is on (-1 = not attacking)
int[] zombieAttackFrame = new int[MAX_ZOMBIES];

//stores how far the zombie has travelled while attacking
int[] zombieAttackDisplacement = new int [MAX_ZOMBIES];


//character attributes:
//Character starting coordinates
int characterY = 450; //on the ground
int characterX = 700; //middle of the screen

boolean facingRight = true;
boolean characterUp = true;

double characterSpeed = 7; //pixels moved per frame

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
PImage zombieRightUp;
PImage zombieRightDown;
PImage zombieRightAttack;




//SETUP METHOD: RUNS ONCE AT START OF PROGRAM
void setup() {
  //set size of canvas: 1400px wide, 700px tall
  size(1400, 700);
  
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
  zombieRightUp = loadImage("zombieRightUp.png");
  zombieRightDown = loadImage("zombieRightDown.png");
  zombieRightAttack = loadImage("zombieRightAttack.png");
  
  //initialize all zombie states as 0 (not existing)
  for (int i = 0; i < MAX_ZOMBIES; i++) {
    zombieState[i] = 0;
    zombieAttackFrame[i] = -1;
    zombieAttackDisplacement[i] = 0;
  }
}













/**
* draws everything on screen, is repeated each frame
* pre: none
* post: character, landscape, zombies, background, and platforms drawn
*/
void draw() {
  //set background colour
  background(30, 10, 50);
  
  //SPAWNING ZOMBIES
  //call spawnZombie method for every set number of frames
  if (frameCount % ZOMBIE_SPAWN_FREQUENCY == 0) {
    spawnZombie();
  }
  
  //CHARACTER MOVEMENT:
  //check if character is on screen and which direction it should move, move it accordingly
  if (moveRight && characterX < 1400) {
    characterX += characterSpeed;
  }
  if (moveLeft && characterX > 0) {
    characterX -= characterSpeed;
  }
  
  //PARSE THROUGH ZOMBIE ARRAYS
  for (int i = 0; i < MAX_ZOMBIES; i++) {
    if (zombieState[i] >= 1 && zombieState[i] <=6 ) {
      if (frameCount % 11 == 0) {
        zombieUp[i] = !zombieUp[i];
      }
      
      rectMode(CENTER);
      if (zombieState[i] != 2 && zombieState[i] != 4) {
        if (characterX - zombieX[i] >= 100) { // moving right
          zombieState[i] = 3;
          
        } else if (zombieX[i] - characterX >=  100) { //moving left
          zombieState[i] = 1;
          
        } else if (characterX - zombieX[i] >= 0 && characterX - zombieX[i] < 100 ) { //moving right attacking
          zombieState[i] = 4;
          println("set to 4");
          
        } else if (zombieX[i] - characterX >= 0 && zombieX[i] - characterX < 100) { //moving left attacking
          zombieState[i] = 2;
          println("set to 2");
        }
      }
      
      switch (zombieState[i]) {
        
        case 1: //moving left
          zombieX[i] -= zombieSpeed;
          if (zombieUp[i]) { //up position
            image(zombieLeftUp, zombieX[i], ZOMBIE_Y, 130, 130);
          } else { //down position
            image(zombieLeftDown, zombieX[i], ZOMBIE_Y, 130, 130);
          }
          break;
        
        case 2:
          zombieAttackLeft(i);
          break;
          
        case 3: //moving right
          zombieX[i] += zombieSpeed;
          if (zombieUp[i]) { //up position
            image(zombieRightUp, zombieX[i], ZOMBIE_Y, 130, 130);
          } else { //down position
            image(zombieRightDown, zombieX[i], ZOMBIE_Y, 130, 130);
          }
          break;
        
        case 4: //attacking right
          zombieAttackRight(i);
          break;
        
        
      }
      
      
    }
  }
  rectMode(CORNER);
  

  //if character was on level 2 & now off the platform & not already falling
  if (characterLevel == 2 && !onLevel2() && !falling) {
    falling = true;
    fallFrame = 0;
  }
  
  //fall code
  if (falling && !jumping) {
    
    if (characterY < 450) {
      characterY +=  fallFrame;
      fallFrame++;
      
    } else {
      characterLevel = 1;
      characterY = 450;
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
  
  
  //change character up and down every few frames to simulate walking motion
  if (frameCount % 7 == 0) {
    characterUp = !characterUp;
  } 
  
  if (attacking) {
    attackFrame++;
    for (int i = 0; i < MAX_ZOMBIES; i++) {
      if (characterY > 350 && ((facingRight && zombieX[i] - characterX < 100 && zombieX[i] - characterX > -20) || (!facingRight && characterX - zombieX[i] < 100 && characterX - zombieX[i] > -20))) { 
        zombieState[i] = 0;
      }
    }
    
    if (attackFrame < 0) {
      attackFrame = 0;
    }
    
    if (attackFrame > 20) {
      attacking = false;
      attackFrame = -1;
    }
    
  }
  
  //ShOW CHARACTER:
  imageMode(CENTER);
  
  //facing left, not attacking
  if (!facingRight && !attacking) {
    
    
    if ((characterUp && moveLeft) || !moveLeft) {
      image(knightLeftUp, characterX, characterY, 110, 110);
    } else if (moveLeft) {
      image(knightLeftDown, characterX, characterY, 110, 110);
    }
    
  } else if (!facingRight && attacking) {
    
    if ((characterUp && moveLeft) || !moveLeft) {
      image(knightLeftUpAttack, characterX, characterY, 110, 110);
    } else if (moveLeft) {
      image(knightLeftDownAttack, characterX, characterY, 110, 110);
    }
    
    
  } else if (facingRight && !attacking) {
    
    if ((characterUp && moveRight) || !moveRight) {
      image(knightRightUp, characterX, characterY, 110, 110);
    } else if (moveRight) {
      image(knightRightDown, characterX, characterY, 110, 110);
    }

  } else if (facingRight && attacking) {
    
    if ((characterUp && moveRight) || !moveRight) {
      image(knightRightUpAttack, characterX, characterY, 110, 110);
    } else if (moveRight) {
      image(knightRightDownAttack, characterX, characterY, 110, 110);
    }
    
  } 
  
  
  //draw a platform on left side
  stroke(100, 50, 40);
  fill(100, 50, 40);
  rect(300, 350, 200, 20);
  stroke(90, 40, 30);
  fill(90, 40, 30);
  rect(300, 350, 200, 5);
  
  //draw a platform right side
  stroke(100, 50, 40);
  fill(100, 50, 40);
  rect(900, 350, 200, 20);
  stroke(90, 40, 30);
  fill(90, 40, 30);
  rect(900, 350, 200, 5);
  
  //draw the ground
  stroke(100, 100, 100);
  fill(100, 100, 100);
  rect(0, 500, 1400, 200);
  fill(60, 60, 60);
  rect(0, 500, 1400, 20);
  
  //printAllValues();
  
}

















/**
* detects key presses and does the corresponding action to releasing that key
* pre: none
* post: none
*/
void keyPressed() {
  //move right when d is pressed
  if (key == 'd') {
    moveRight = true;
    facingRight = true;
  //move left when a is pressed
  } else if (key == 'a') {
    moveLeft = true;
    facingRight = false;
  }
  if (attackFrame >= 0) {
    if (key == 'j') {
      attacking = true;
    }
  }
  
  if (key == ' ' && !jumping && !falling) {
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
  if (key == 'd') {
    
    if (moveRight && moveLeft) {
      facingRight = false;
    }
      
    moveRight = false;
  } else if (key == 'a') {
    
    if (moveRight && moveLeft) {
      facingRight = true;
    }
    
    moveLeft = false;
  }
  
  if (key == 'j') {
    attacking = false;
    attackFrame = 0;
  }
  
}


/**
* checks if the character is on one of the platforms
* @return true if the character position is on any of the platforms, false if not
* pre: none
* post: none
*/
boolean onLevel2() {
  return ((characterY > 290 && characterY < 315) && ((characterX > 280 && characterX < 520) || (characterX > 880 && characterX < 1120)));
}

/**
* places a zombie on the left or right side of the screen 
* pre: none
* post: zombie placed 
*/
void spawnZombie() {
  
  //use for loop to find first empty slot in array
  for (int i = 0; i < MAX_ZOMBIES; i++) {
    if (zombieState[i] == 0) {
      
      zombieUp[i] = true;
      
      //randomly decide whether to spawn on left or right side
      if (Math.random() < 0.5) { //left side       
        zombieX[i] = -50;
        zombieState[i] = 3;
        
      } else { //right side
        zombieX[i] = 1450;
        zombieState[i] = 1;
      }

      
      break; //break to ensure only one zombie is created
        
    }
  }
}


/**
* progresses the zombie in the left attack animation by one frame
* @param zombieNum an int used to index the zombie arrays 
* pre: zombieNum is in range of the array
* post: zombie attack left animation has been progressed by one frame
*/
void zombieAttackLeft(int zombieNum) {
    //
    if (zombieAttackFrame[zombieNum] < 0) {
      zombieAttackFrame[zombieNum] = 0;
      image(zombieLeftAttack, zombieX[zombieNum], ZOMBIE_Y, 130, 130);
      zombieAttackFrame[zombieNum]++;
    
    //frames 0-49: wind up attack
    } else if (zombieAttackFrame[zombieNum] >= 0 && zombieAttackFrame[zombieNum] < 50) { 
      image(zombieLeftAttack, zombieX[zombieNum], ZOMBIE_Y, 130, 130);
      zombieAttackFrame[zombieNum]++;
      
    } else if (zombieAttackFrame[zombieNum] == 50) { //frame 50: jump forward - frame counting stops and displacement counting starts
      zombieX[zombieNum] -= 16 * zombieSpeed;
      zombieAttackDisplacement[zombieNum] += 16 * zombieSpeed;
      image(zombieLeftUp, zombieX[zombieNum], ZOMBIE_Y, 130, 130);
      if (zombieAttackDisplacement[zombieNum] > 200) {
        zombieAttackFrame[zombieNum]++;
      }
      
    } else if (zombieAttackFrame[zombieNum] > 50 && zombieAttackFrame[zombieNum] <= 110) { //frames 16-25: stand still - frame counting restarts and displacement counting stops
      image(zombieLeftUp, zombieX[zombieNum], ZOMBIE_Y, 130, 130);
      zombieAttackFrame[zombieNum]++;
      zombieAttackDisplacement[zombieNum] = 0;
      
    } else if (zombieAttackFrame[zombieNum] > 110) {
      zombieAttackFrame[zombieNum] = -1;
      zombieState[zombieNum] = 1;
      image(zombieLeftUp, zombieX[zombieNum], ZOMBIE_Y, 130, 130);
    }
          
}

/**
* progresses the zombie in the right attack animation by one frame
* @param zombieNum an int used to index the zombie arrays 
* pre: zombieNum is in range of the array
* post: zombie attack right animation has been progressed by one frame
*/
void zombieAttackRight(int zombieNum) {
    //if the attack hasn't started
    if (zombieAttackFrame[zombieNum] < 0) {
      zombieAttackFrame[zombieNum] = 0;
      image(zombieRightAttack, zombieX[zombieNum], ZOMBIE_Y, 130, 130);
      zombieAttackFrame[zombieNum]++;
      
    //frames 0-49: wind up attack
    } else if (zombieAttackFrame[zombieNum] >= 0 && zombieAttackFrame[zombieNum] < 50) {
      image(zombieRightAttack, zombieX[zombieNum], ZOMBIE_Y, 130, 130);
      zombieAttackFrame[zombieNum]++;
      
    } else if (zombieAttackFrame[zombieNum] == 50) { //frame 50: jump forward - frame counting stops and displacement counting starts
      zombieX[zombieNum] += 16 * zombieSpeed;
      zombieAttackDisplacement[zombieNum] += 16 * zombieSpeed;
      image(zombieRightUp, zombieX[zombieNum], ZOMBIE_Y, 130, 130);
      if (zombieAttackDisplacement[zombieNum] > 200) {
        zombieAttackFrame[zombieNum]++;
      }
    } else if (zombieAttackFrame[zombieNum] > 50 && zombieAttackFrame[zombieNum] <= 110) { //frames 16-25: stand still - frame counting restarts and displacement counting stops
      image(zombieRightUp, zombieX[zombieNum], ZOMBIE_Y, 130, 130);
      zombieAttackFrame[zombieNum]++;
      zombieAttackDisplacement[zombieNum] = 0;
      
    } else if (zombieAttackFrame[zombieNum] > 110) {
      zombieAttackFrame[zombieNum] = -1;
      zombieState[zombieNum] = 3;
      image(zombieRightUp, zombieX[zombieNum], ZOMBIE_Y, 130, 130);
    }
}
