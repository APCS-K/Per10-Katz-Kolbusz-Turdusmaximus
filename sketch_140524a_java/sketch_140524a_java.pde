/*
blocks empty dy oldy newy  fallingi
6 3 360    -160 200  480
6 2 240    -80 160    320
5 2 240    -80 160    320
5 1     0 120    160
  
  -1            +80 -40         -160

*/



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

void setup() {
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
  blocks = new Block[13][6];//6 by 12 blocks (really 13)
  
  // ------------------------------------------------------------------------------creating randomly colored blocks for testing purposes
  for (int i=0; i<blocks.length-7; i++) {
     for (int j=0; j<blocks[0].length/2; j++) {
       int k = r.nextInt(colors.length);
       
       addBlock(i,j,colors[k]);
     }
  }
  
  for (int i=0; i<blocks.length-1; i++) {
     for (int j=blocks[0].length/2; j<blocks[0].length; j++) {
       int k = r.nextInt(colors.length);
       
       addBlock(i,j,colors[k]);
     }
  }

  //addBlock(12,2,red);
  blocks[6][4] = null;
  //blocks[5][4] = null;
  //blocks[3][4] = null;
}
 
 
 
 
 
 
 
void draw() {
  background(204);
  
  
  // ------------------------------------------------------------------------------DISPLAYING BLOCKS IN THE ARRAY
  //int j = 0;
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
  
  
  
  // ------------------------------------------------------------------------------SWITCHING BLOCKS
  if (movingi > 0) { //moving animation
    //two blocks switching
    if ((leftblock != null) && (rightblock != null)) {
      //println(movingi);
      leftblock.setX(40*movingcol + ((8-movingi)*5)); //40*movingcol = original x position, moves 5 pixels to the right per draw iteration
      rightblock.setX(40*movingcol + (movingi*5)); //40*movingcol = ending x position, moves 5 pixels to the left per draw iteration
      movingi--;
      
      //for some reason we need to make these two special snowflakes display separately even if we put the display block after this
      leftblock.display();
      rightblock.display();
    }
    else if ((leftblock == null) && (rightblock != null)) { //block on left is empty space
      rightblock.setX(40*movingcol + (movingi*5)); //40*movingcol = ending x position, moves 5 pixels to the left
      movingi--;
      rightblock.display();
    }
    else if ((rightblock == null) && (leftblock != null)) { //block on right is empty space
      leftblock.setX(40*movingcol + ((8-movingi)*5)); //40*movingcol = original x position, moves 5 pixels to the right
      movingi--;
      leftblock.display();
    }
  }
       
  if (movingi == 0) { //resetting move variables
    leftblock = null;
    rightblock = null;
    //don't want the third if clause in the display block to trigger
    movingrow = -1;
    movingcol = -1;
  }
  
  
  
  // ------------------------------------------------------------------------------CHOOSING BLOCKS TO FALL
  for (int row = 1; row < blocks.length; row++) { //I really hope nothing in row 0 is falling
    for (int col = 0; col < blocks[row].length; col++) {
      Block blockInQuestion = blocks[row][col];
      //Block blockBelow = blocks[row-1][col];
      int isEmptyBelow = isEmptyBelow(blockInQuestion);
      if ((isEmptyBelow != -1) /*(blockBelow == null)*/ && (blockInQuestion != null) && !blockInQuestion.isFalling()) {//empty space below, block exists and has not already been assigned true/end variables
        blockInQuestion.setFalling(true);
        //int endingRow = row-1;
        blockInQuestion.setTEMP(blockInQuestion.getY()); //dummy variable to keep track of where the block started
        //while ((endingRow > 0) && (blocks[endingRow-1][col] == null)) { //while the block immediately beneath the block in question is void
          //endingRow--;
        //}
        //print("\t"+endingRow);
        /*int endRow = isEmptyBelow;
        for (int rowBetween = endRow; rowBetween < row; rowBetween++) {
          if (blocks[rowBetween][col] != null) {
            endRow++;
          }
        }
        blockInQuestion.setEndingRow(endRow);
        */
        updateEndingRow(blockInQuestion);
        //print(" choosing ");
      }
    }
  }
    
  
  
  // ------------------------------------------------------------------------------HAVING BLOCKS FALL
  for (Block[] row : blocks) {
    for (Block b : row) {
      if ((b != null) && (b.isFalling())) {
         //print(b.isFalling());
         //int endRow = b.getEndingRow();
         //print(" "+endRow+" ");
         //if (endRow != ((height-b.getY())/40)-1) {
           updateEndingRow(b); //see comment on update function
         //}
         //print(" falling ");
         int endRow = b.getEndingRow();
         int endY = height-(40*(endRow+1));
         int currentY = b.getY();
         if (currentY < endY) { //hasn't reached the endRow
           b.setY(currentY+2); //the overshooting of pixels makes a really nice thudding effect when currentY hits endY
           b.fall();
         }
         else { //hooray we finished falling
           b.setFalling(false);
           //print(b.isFalling());
           int bCol = b.getX()/40;
           int bRow = ((height-b.getTEMP())/40)-1;
           //print(bRow+"\t");
           color bColor = b.getColor();
           //print(bRow+" "+bCol);
           //print(" "+bRow+" "+bCol);
           Block mightBeOldBlock = blocks[bRow][bCol]; 
           //print("THE"+bRow+" "+bCol+"TH"+b.getY()+"E"); //works correctly afaik
             //print("the");
           if (mightBeOldBlock != null && b.blockEquals(mightBeOldBlock)) {//removing block from old location
             //print("the");
             blocks[bRow][bCol] = null; //isOldBlock
           }             
           addBlock(endRow,bCol,bColor); //putting block in new location
           //print("YOU");
         }
      }
    }
  }
           
         
  
  
  // ------------------------------------------------------------------------------PRESSING KEYS
  if (keyPressed) {
    long currentTime = System.nanoTime();
    //println(currentTime);
    //println("\t"+(currentTime - timeOfLastMove));
    if (((currentTime - timeOfLastMove > Integer.MAX_VALUE/20) && (!moving)) || (key != lastMove)) {
      /*
basically doesn't allow a move in the same direction for a certain
length of time unless the cursor has already moved in a different direction
DON'T TWEAK THIS
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
        if ((leftblock != null) && leftblock.isFalling()) { //don't fall and move that's just wrong
          leftblock = null;
        }
        
        rightblock = blocks[movingrow][movingcol+1];
        if ((rightblock != null) && rightblock.isFalling()) {
          rightblock = null;
        }
        
        //leftblock.moving(true);
        //rightblock.moving(true);
        
        if (leftblock != null) {
          color leftcolor = leftblock.getColor();
          blocks[movingrow][movingcol+1] = new Block(movingrow,movingcol+1,leftcolor);
          
          if (rightblock == null) {
            blocks[movingrow][movingcol] = null;
          }
        }
        
        if (rightblock != null) {
          color rightcolor = rightblock.getColor();
          blocks[movingrow][movingcol] = new Block(movingrow,movingcol,rightcolor);
          
          if (leftblock == null) {
            blocks[movingrow][movingcol+1] = null;
          }
          /* first we switch the blocks in the array, then we do the animation
this is to prevent any POTENTIAL case where the user swaps a block while it is still moving */
        }
      }
    }
  }
  
  
  
  // ------------------------------------------------------------------------------MISC DRAW ITERATIONS
  
  cursor.display(); //cursor is drawn on top of the blocks
  //println("\n");
}





// ------------------------------------------------------------------------------MISC FUNCTIONS
  
void addBlock(int row, int col, color c) {
  blocks[row][col] = new Block(row,col,c);
}

void keyReleased() {
  moving = false;
}

int isEmptyBelow(Block b) { //returns -1 if nothing empty below b, otherwise returns the lowest row of emptiness
  if (b == null) {
    return -1;
  }
  int col = b.getX()/40;
  int row = ((height-b.getY())/40)-1;
  for (int rowBelow = 0; rowBelow < row; rowBelow++) {
    if (blocks[rowBelow][col] == null) {
      return rowBelow;
    }
  }
  return row;
}

void updateEndingRow(Block b) { //i.e. block is falling and another block gets switched under its fall
  int row = ((height-b.getY())/40)-1;
  int col = b.getX()/40;
  int endRow = isEmptyBelow(b);
  //print(" "+endRow);
  for (int rowBetween = endRow; rowBetween < row; rowBetween++) {
    //print(rowBetween+" "+row+" "+col+"\t");
    if (blocks[rowBetween][col] != null) {
      endRow++;
    }
  }
  //println("");
  //if(row < endRow) {//whoops you overshot it
  //  b.setEndingRow(endRow+1);
  //}
  //else {
    //print(endRow);
    b.setEndingRow(endRow);
 // }
}
//-------------------------------------------------------------------------------------------------

class Block {
  private int x,y,endingRow,temp,fallingi;
  private color c;
  private boolean falling;
  
  public Block(int row, int col, color c) {
    x = 40*col;
    y = height-(40*(row+1));
    this.c = c;
    falling = false;
  }
  
  public boolean blockEquals(Block b) {
    //this is used when a block has finished falling
    //"is the block I am looking at this block before it fell"
    int dy = fallingi/4;
    int oldy = y-dy;
    boolean xEqual = (b.getX() == x);
    boolean yEqual = (b.getTEMP() == oldy);
    boolean colEqual = (b.getColor() == c);
    //print("       "+b.getTEMP()+" "+oldy+" "+fallingi+" "+dy+"\t");
    
    //print("\t"+xEqual + yEqual + colEqual);
    return (xEqual && yEqual && colEqual);
  }
  
  public void fall() {
    fallingi = fallingi+8;
  }
  
  public color getColor() {return c;}
  
  public void setX(int i) {x = i;
    //print("\t"+x+","+c);
  }
  public int getX() {return x;}

  public void setY(int i) {y = i;}
  public int getY() {return y;}
  
  public void setTEMP(int i) {temp = i;}
  public int getTEMP() {return temp;}
  
  public void setEndingRow(int r) {endingRow = r;}
  public int getEndingRow() {return endingRow;}
  
  public void setFalling(boolean b) {falling = b;}
  public boolean isFalling() {return falling;}
  
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
