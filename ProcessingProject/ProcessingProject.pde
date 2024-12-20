/**
* This program is a game in which the user plays as a knight fighting against monsters and trying to survive through increasingly difficult waves.
* When run, the user is presented with a game menu in which they can access settings, save their game, and 
* The user can press a and d to move left or right, space to jump, and j to attack. 
* 
* @author  Ethan Lau
* @version 1.0
* @since   2025-1-1
*/



//GLOBAL VARIABLES: CAN BE USED IN ANY METHOD

//zombie attributes:
double zombieSpeed = 1.2; //pixels moved per frame, will be changed to increase difficulty
int zombieDamage = 10; //% of character health per hit
final double ZOMBIE_JUMP_SPEED = 16 * zombieSpeed; //pixels moved per frame
final double ZOMBIE_KNOCKBACK = 10 * zombieSpeed; //pixels character moves per frame being hit by zombie
final int MAX_ZOMBIES = 20; //arbitrary, set relatively small to save memory
final int ZOMBIE_Y = 440; //zombies can't jump or move up so their y is a constant
final int ZOMBIE_SPAWN_FREQUENCY = 300; //frames between zombie spawing
double zombieSpawnDistance = 0; //distance the zombie spawns from a side of the screen, will change every time a zombie spawns

//zombie array attributes: stored in an array because these attributes can be different for each zombie

//stores x pos of each zombie
double[] zombieX = new double[MAX_ZOMBIES]; 

//stores whether each zombie is in up or down pos
boolean[] zombieUp = new boolean[MAX_ZOMBIES]; 

//array containing the state of each zombie as follows: 
//0 = doesn't exist
//1 = moving left, 2 = attacking left
//3 = moving right, 4 = attacking right
int[] zombieState = new int[MAX_ZOMBIES];

//stores hp of each zombie in percentage
int[] zombieHp = new int[MAX_ZOMBIES];

double[] zombieHpBarX = new double[MAX_ZOMBIES];

//stores the frame of the attack animation that each zombie is on (-1 = not attacking)
int[] zombieAttackFrame = new int[MAX_ZOMBIES];

//stores how far the zombie has travelled while attacking
int[] zombieAttackDisplacement = new int[MAX_ZOMBIES];

//stores which zombies are doing damage to character
boolean[] zombieDamaging = new boolean[MAX_ZOMBIES];

//stores which zombies have already been attacked every character attack
boolean[] zombieAttacked = new boolean[MAX_ZOMBIES];

//zombie attack animation frames
final int ZOMBIE_JUMP_FRAME = 30; //frame to jump forward
final int ZOMBIE_ATTACK_END_FRAME = 60; //frame to end attack animation
final int ZOMBIE_MAX_ATTACK_DISPLACEMENT = 200; //how far the zombie should travel when jumping


//character attributes:
//character coordinates
int characterY = 450; //start on the ground
int characterX = 700; //start in middle of the screen

int characterDamage = 50; //% of monster health

boolean facingRight = true;
boolean characterUp = true;

//full characterHp
int characterHp = 100; //100%

final double CHARACTER_SPEED = 7; //pixels moved per frame
final double CHARACTER_KNOCKBACK = 30; //pixels monsters move per hit by character

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




/**
* sets up the canvas that processing draws on
* pre: none
* post: images have been loaded, size of canvas is set, zombie arrays are properly initialized if needed
*/
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
  
  //initialize all zombie states as 0 (not existing), attack displacements at 0 and attack frames as -1 (not attacking)
  for (int i = 0; i < MAX_ZOMBIES; i++) {
    zombieState[i] = 0;
    zombieAttackFrame[i] = -1;
    zombieAttackDisplacement[i] = 0;
  }
}













/**
* draws everything on screen, is repeated each frame
* pre: setup method has run
* post: character, landscape, zombies, background, and platforms drawn
*/
void draw() {
  //set background colour
  background(30, 10, 50);
  
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
  
  //SPAWNING ZOMBIES
  //call spawnZombie method for every set number of frames
  if (frameCount % ZOMBIE_SPAWN_FREQUENCY == 0) {
    spawnZombie();
    spawnZombie();
  }
  
  //CHARACTER MOVEMENT:
  //check if character is on screen and which direction it should move, move it accordingly
  if (moveRight) {
    characterX += CHARACTER_SPEED;
  }
  if (moveLeft) {
    characterX -= CHARACTER_SPEED;
  }
  
  //PARSE THROUGH ZOMBIE ARRAYS
  for (int i = 0; i < MAX_ZOMBIES; i++) {
    if (zombieState[i] >= 1 && zombieState[i] <=6 ) {
      if (frameCount % 11 == 0) {
        zombieUp[i] = !zombieUp[i];
      }
      
      rectMode(CENTER);
      if (zombieState[i] != 2 && zombieState[i] != 4) {
        if (characterX - zombieX[i] >= 150) { // moving right
          zombieState[i] = 3;
          
        } else if (zombieX[i] - characterX >=  150) { //moving left
          zombieState[i] = 1;
          
        } else if (characterX - zombieX[i] >= 0 && characterX - zombieX[i] < 150 ) { //moving right attacking
          zombieState[i] = 4;
          
        } else if (zombieX[i] - characterX >= 0 && zombieX[i] - characterX < 150) { //moving left attacking
          zombieState[i] = 2;
        }
      }
      
      switch (zombieState[i]) {
        
        case 1: //moving left
          zombieX[i] -= zombieSpeed;
          if (zombieUp[i]) { //up position
            image(zombieLeftUp, (float) zombieX[i], ZOMBIE_Y, 130, 130);
          } else { //down position
            image(zombieLeftDown, (float) zombieX[i], ZOMBIE_Y, 130, 130);
          }
          zombieHpBarX[i] = zombieX[i] - (55);
          break;
        
        case 2:
          zombieAttackLeft(i);
          break;
          
        case 3: //moving right
          zombieX[i] += zombieSpeed;
          if (zombieUp[i]) { //up position
            image(zombieRightUp, (float) zombieX[i], ZOMBIE_Y, 130, 130);
          } else { //down position
            image(zombieRightDown, (float) zombieX[i], ZOMBIE_Y, 130, 130);
          }
          zombieHpBarX[i] = zombieX[i] - 10;
          break;
        
        case 4: //attacking right
          zombieAttackRight(i);
          
          
          break;
        
        
      }
      
      //print zombie health bar
      rectMode(CORNER);
      noStroke();
      fill(255, 0, 0);
      rect((int) zombieHpBarX[i], ZOMBIE_Y - 75, zombieHp[i] * 0.65, 10);
      
      stroke(200, 200, 200);
      strokeWeight(4);
      noFill();
      rect((int) zombieHpBarX[i], ZOMBIE_Y - 75, 65, 10);
      strokeWeight(0);
      
  
      
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
  
  
  //if character is attacking
  if (attacking) {
    
    if (attackFrame == 0) {
      attackCooldown = 20;
    }
    
    attackFrame++;
    
    for (int i = 0; i < MAX_ZOMBIES; i++) {
      if (characterY > 350 && ((facingRight && zombieX[i] - characterX < 100 && zombieX[i] - characterX > -20) || (!facingRight && characterX - zombieX[i] < 100 && characterX - zombieX[i] > -20)) && !zombieAttacked[i]) { 
        zombieHp[i] -= characterDamage;
        zombieAttacked[i] = true;
        
        
        if (facingRight) {
          zombieX[i] += CHARACTER_KNOCKBACK;
        } else {
          zombieX[i] -= CHARACTER_KNOCKBACK;
        }
      }
      if (zombieHp[i] <= 0) {
        zombieState[i] = 0;
        zombieAttackFrame[i] = 0;
      }
    }
    
    
      
    
    if (attackFrame > 20) {
      attacking = false;
      attackFrame = -1;
      for (int i = 0; i < MAX_ZOMBIES; i++) {
        zombieAttacked[i] = false; 
      }
    }
  }
  
  if (attackCooldown > 0) {
    attackCooldown--;
  }
  
  
  
  //Character health bar:
  rectMode(CORNER);
  noStroke();
  fill(255, 20, 20);
  rect(50, 50, characterHp * 3, 60);
  
  stroke(200, 200, 200);
  strokeWeight(12);
  noFill();
  rect(50, 50, 300, 60);
  
  //Character attack cooldown bar:
  rectMode(CORNER);
  noStroke();
  fill(20, 20, 255);
  rect(1150, 50, 200 - attackCooldown * 10, 60);
  
  stroke(200, 200, 200);
  strokeWeight(12);
  noFill();
  rect(1150, 50, 200, 60);
  strokeWeight(0);
  
  //ensure character stays on screen
  if (characterX > 1400) {
    characterX = 1400;
  } else if (characterX < 0) {
    characterX = 0;
  }
  
  //SHOW CHARACTER:
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
  
  

  
  //draw the ground
  stroke(100, 100, 100);
  fill(100, 100, 100);
  rect(0, 500, 1400, 200);
  fill(60, 60, 60);
  rect(0, 500, 1400, 20);
  for (int i = 0; i < MAX_ZOMBIES; i++) {
    if (zombieDamaging[i]) {
      fill(255, 0, 0, 50);
      rect(0, 0, 1400, 700);
    }
  }
  
  //printAllValues();
  /*
  print("Hp: \t\t");
  for (int i = 0; i < MAX_ZOMBIES /2; i++) {
    print(zombieHp[i] + ",\t");
  }
  println();
  print("Attacked: \t");
  for (int i = 0; i < MAX_ZOMBIES/2; i++) {
    print(zombieAttacked[i] + ",\t");
  }
  println();
  print("State: \t\t");
  for (int i = 0; i < MAX_ZOMBIES/2; i++) {
    print(zombieState[i] + ",\t");
  }
  println();*/
  
}












/**
* checks if the mouse is clicked (used to attack)
* pre: none
* post: attacking = true (if cooldown is finished and attack animation is still going)
*/
void mousePressed() {
  if (attackFrame >= 0 && attackCooldown == 0) {
    attacking = true;  
  }
}

/**
* checks if the mouse is clicked (used to release attack)
* pre: none
* post: attacking = false, attackFrame = 0, all zombieAttacked = false
*/
void mouseReleased() {
  attacking = false;
  attackFrame = 0;
  for (int i = 0; i < MAX_ZOMBIES; i++) {
    zombieAttacked[i] = false; 
  }
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
  if (key == 'j' && attackFrame >= 0 && attackCooldown == 0) {
    attacking = true;  
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
    for (int i = 0; i < MAX_ZOMBIES; i++) {
      zombieAttacked[i] = false; 
    }
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
* places a zombie at a random distance (0-100 or 250-350 pixels) off of the left or right side of the screen 
* pre: none
* post: zombie placed 
*/
void spawnZombie() {
  
  //use for loop to find first empty slot in array
  for (int i = 0; i < MAX_ZOMBIES; i++) {
    if (zombieState[i] == 0) {
      
      zombieUp[i] = true;
      zombieHp[i] = 100;
      
      //randomly decide whether to spawn on left or right side
      if (Math.random() < 0.5) { //left side       
        zombieX[i] =  -65 - zombieSpawnDistance;
        zombieState[i] = 3;
        
      } else { //right side
        zombieX[i] = 1465 + zombieSpawnDistance;
        zombieState[i] = 1;
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
    image(zombieLeftUp, (float) zombieX[zombieNum], ZOMBIE_Y, 130, 130);
    zombieHpBarX[zombieNum] = zombieX[zombieNum] - 55;
		
		//check if zombie was near character (should do damage)
    if (Math.abs(zombieX[zombieNum] - characterX) <= ZOMBIE_JUMP_SPEED && characterY > 350) {
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
      image(zombieRightUp, (float) zombieX[zombieNum], ZOMBIE_Y, 130, 130);
      zombieHpBarX[zombieNum] = zombieX[zombieNum] - 10;
			
			//check if zombie is near character (should do damage)
      if (Math.abs(zombieX[zombieNum] - characterX) <= ZOMBIE_JUMP_SPEED && characterY > 350) {
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
