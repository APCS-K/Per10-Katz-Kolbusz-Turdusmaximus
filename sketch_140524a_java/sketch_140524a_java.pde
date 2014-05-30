import java.util.*;

Block[][] blocks;
Cursor cursor;

long timeOfLastMove;
char lastMove;

boolean moving;
int movingi;
int movingrow;
int movingcol;

Block leftblock;
Block rightblock;

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
  
  moving = false;
  movingi = 0;
  movingrow = -1;
  movingcol = -1;
  leftblock = null;
  rightblock = null;
  
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
  //int j = 0;
  
  //displaying all the blocks in the array
  for (int row = 0; row < blocks.length; row++) {
    for (int col = 0; col < blocks[row].length; col++) {
      //print("\t"+b.equals(leftblock));
      Block b = blocks[row][col];
      //print(" "+movingcol+" ");
      if ( (b != null) && !( (row == movingrow) && ( (col == movingcol) || (col == movingcol+1) ) ) ){ //block exists, and is not the block defined as being in the row where a move is taking place in the two columns beng moved (aka the blocks switched)
        //j++;
        b.display();
      }
    }
  }
  //print(" "+j);
  
  if (movingi > 0) { //moving animation
    //by definition leftblock and rightblock have to be non-null but just in case
    if ((leftblock != null) && (rightblock != null)) {
      //println(movingi);
      leftblock.setX(40*movingcol + ((8-movingi)*5)); //40*movingcol = original x position, moves 5 pixels to the right
      rightblock.setX(40*movingcol + (movingi*5)); //40*movingcol = ending x position, moves 5 pixels to the left
      movingi--;
      
      //for some reason we need to make these two special snowflakes display separately even if we put the display block after this
      leftblock.display();
      rightblock.display();
    }
  }
       
  if (movingi == 0) {
    leftblock = null;
    rightblock = null;
    //don't want the third if clause in the display block to trigger
    movingrow = -1;
    movingcol = -1;
  }
  
  if (keyPressed) {
    long currentTime = System.nanoTime();
    //println(currentTime);
    //println("\t"+(currentTime - timeOfLastMove));
    if (((currentTime - timeOfLastMove > Integer.MAX_VALUE/20) && (!moving)) || (key != lastMove)) {
      /*
      basically doesn't allow a move in the same direction for a certain
      length of time unless the cursor has already moved in a different direction
      
      tweak this??
      */
      moving = true;
      lastMove = key;
      
      
      timeOfLastMove = currentTime;
      if (key == 'w') {
        //timeOfLastMove = currentTime;
        cursor.moveUp();
      }
      if (key == 'a') {
        //timeOfLastMove = currentTime;
        cursor.moveLeft();
      }
      if (key == 's') {
        //timeOfLastMove = currentTime;
        cursor.moveDown();
      }
      if (key == 'd') {
        //timeOfLastMove = currentTime;
        cursor.moveRight();
      }
      if (key == ENTER) {
        //timeOfLastMove = currentTime;
        movingi = 7; //HEY WE'RE MOVING NOW
        movingrow = cursor.getRow();
        movingcol = cursor.getCol();
        
        
        leftblock = blocks[movingrow][movingcol];
        rightblock = blocks[movingrow][movingcol+1];
        
        //leftblock.moving(true);
        //rightblock.moving(true);
        
        color leftcolor = leftblock.getColor();
        color rightcolor = rightblock.getColor();
        blocks[movingrow][movingcol] = new Block(movingrow,movingcol,rightcolor);
        blocks[movingrow][movingcol+1] = new Block(movingrow,movingcol+1,leftcolor);
        
        /* first we switch the blocks in the array, then we do the animation
        this is to prevent any POTENTIAL case where the user swaps a block while it is still moving */
        
     }
    
    }
   
   
}
  
  cursor.display(); //cursor is drawn on top of the blocks
}

void addBlock(int row, int col, color c) {
  blocks[row][col] = new Block(row,col,c);
}

void keyReleased() {
  moving = false;
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
  
  public color getColor() {return c;}
  
  public int getX() {return x;}
  public void setX(int i) {x = i;
    //print("\t"+x+","+c);
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
  
  public int getRow() {return row;}
  public int getCol() {return leftcol;}
  
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
    
 
