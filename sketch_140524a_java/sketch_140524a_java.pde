import java.util.*;

Block[][] blocks;
Cursor cursor;

long timeOfLastMove;
char lastMove;

color red = color(245,20,20);
color yellow = color(245,245,20);
color green = color(20,200,20);
color sky = color(40,220,220);
color blue = color(40,40,255);
color pink = color(245,10,245);
color[] colors = {red,yellow,green,sky,blue,pink};

Random r = new Random();

void setup() { //6 by 12 blocks (really 13)
  size(240,520);
  frameRate(30);
  timeOfLastMove = 4;
  lastMove = 'n';
 
  cursor = new Cursor();
  blocks = new Block[12][6];
  
  //creating randomly colored blocks for testing purposes
  for (int i=0; i<blocks.length; i++) {
     for (int j=0; j<blocks[0].length; j++) {
       int k = r.nextInt(colors.length);
       
       addBlock(i,j,colors[k]);
     }
  }

}
 
void draw() { 
  background(204);
  
  //displaying all the blocks in the array
  for (Block[] row : blocks) {
    for (Block b : row) {
      if (b != null) {
        b.display();
      }
    }
  }
  
  if (keyPressed) {
    long currentTime = System.nanoTime();
    println(currentTime);
    println("\t"+(currentTime - timeOfLastMove));
    if ((currentTime - timeOfLastMove > Integer.MAX_VALUE/20) || (key != lastMove)) {
      /*
      basically doesn't allow a move in the same direction for a certain
      length of time unless the cursor has already moved in a different direction
      */
      timeOfLastMove = currentTime;
      lastMove = key;
      
      if (key == 'w') {
        cursor.moveUp();
      }
      if (key == 'a') {
        cursor.moveLeft();
      }
      if (key == 's') {
        cursor.moveDown();
      }
      if (key == 'd') {
        cursor.moveRight();
      }
    }
  }

  cursor.display(); //cursor is drawn on top of the blocks
  
}

void addBlock(int row, int col, color c) {
  blocks[row][col] = new Block(row,col,c);
}

//-------------------------------------------------------------------------------------------------

class Block {
  private int x,y;
  private color c;
  
  public Block(int row, int col, color c) {
    x = 40*col;
    y = height-(40*(row+1));
    this.c = c;
  }
  
  public void display() {
    fill(c);
    rect(x,y,40,40,6);
  }
  
}

class Cursor {
  private int row, leftcol; //cursor is 2 columns wide
  
  public Cursor() {
    row = 5;
    leftcol = 2;
  }
  
  public void display() {
    int x = 40*leftcol;
    int y = height-(40*(row+1));
    
    strokeWeight(6);
    fill(0,0,0,0); //empty rectangle
    rect(x,y,80,40);
    strokeWeight(1); //don't want the blocks to be as thick as the cursor 
  }
  
  public void moveLeft() {
    if (leftcol > 0) {
      leftcol--;
    }
  }
  
  public void moveRight() {
    if (leftcol < 4) {
      leftcol++;
    }
  }
  
  public void moveUp() {
    if (row < 12) {
      row++;
    }
  }
  
  public void moveDown() {
    if (row > 0) {
      row--;
    }
  }
  
}
    
 
