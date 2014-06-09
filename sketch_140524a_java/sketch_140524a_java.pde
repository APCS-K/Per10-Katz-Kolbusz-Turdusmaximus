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

int blocksFalling;
int rising;

int pushUp;
RowQueue nextNewRow;

color red = color(245,20,20);
color yellow = color(245,245,20);
color green = color(20,200,20);
color sky = color(40,220,220);
color blue = color(40,40,255);
color pink = color(245,10,245);
color[] colors = {red,yellow,green,sky,blue,pink};

Random r = new Random();

void setup() {
  size(400,520);
  frameRate(30);
  
  timeOfLastMove = 4;
  lastMove = 'n';
  
  moving = false;
  movingi = 0;
  movingrow = -1;
  movingcol = -1;
  
  leftblock = null;
  rightblock = null;
  
  nextNewRow = new RowQueue();
  nextNewRow.enqueue();
  nextNewRow.enqueue();
  /*Block[] newBottomRow = createRandomRow();
  Block[] newBottomRow2 = createRandomRow();
  nextNewRow.enqueue(newBottomRow);
  nextNewRow.enqueue(newBottomRow2);*/
  //print(nextNewRow);
  
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
  fill(0,0,0);
  rect(0,height-pushUp,240,pushUp);
  deleteBlocks();
  
  // ------------------------------------------------------------------------------DISPLAYING BLOCKS IN THE ARRAY
  //int j = 0;
  for (int row = 0; row < blocks.length; row++) {
    for (int col = 0; col < blocks[row].length; col++) {
      //print("\t"+b.equals(leftblock));
      Block b = blocks[row][col];
      //print(" "+movingcol+" ");
      if ( (b != null) && !( (row == movingrow) && ( (col == movingcol) || (col == movingcol+1) ) ) ){ //block exists, and is not the block defined as being in the row where a move is taking place in the two columns beng moved (aka the blocks switched)
        //j++;
        //print(b.isFalling()+" ");
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
      if ((isEmptyBelow != -1) && (isEmptyBelow != row) /*(blockBelow == null)*/ && (blockInQuestion != null) && !blockInQuestion.isFalling()) {//empty space below, block exists and has not already been assigned true/end variables
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
         int bCol = b.getX()/40;
         int bRow = ((height-b.getTEMP())/40)-1;
         int shift = b.isThereABlockStuckInsideMe();
         if (shift != -1) {
           //print("\t"+currentY+" ");
           b.setY(currentY-(42-shift)); 
           //b.display();        
           //print(b.getY()+"\t");
           //test = b;
           //blocks[bRow][bCol] = null;
         }
         if (currentY < endY) { //hasn't reached the endRow
           b.setY(b.getY()+2); //IT TOOK ME THREE DAYS TO FIGURE OUT THAT CURRENTY SHOULD NOT BE USED HERE
           b.fall();
         }
         else { //hooray we finished falling
           blocksFalling--;
           b.setFalling(false);
           //print(b.isFalling());

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
           
         
  // ------------------------------------------------------------------------------FALLING PREVENTING RISING
  for (int row = 0; row < blocks.length; row++) {
    for (int col = 0; col < blocks[0].length; col++) {
      Block b = blocks[row][col];
      if ((b != null) && (b.isFalling())) {
        blocksFalling++;
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
        
        /*
        if (leftblock != null) {
          color leftcolor = leftblock.getColor();
          blocks[movingrow][movingcol+1] = new Block(movingrow,movingcol+1,leftcolor);
          int isEmptyBelowRight = isEmptyBelow(blocks[movingrow][movingcol+1]);
          if ((isEmptyBelowRight != -1) && (isEmptyBelowRight != movingrow)) {
            blocks[movingrow][movingcol+1].setFalling(true);
            //print("LEFT FALLING");
          }
          
          //if (rightblock == null) {
          else {
            blocks[movingrow][movingcol] = null;
          }
        }
        
        if (rightblock != null) {
          color rightcolor = rightblock.getColor();
          blocks[movingrow][movingcol] = new Block(movingrow,movingcol,rightcolor);
          int isEmptyBelowLeft = isEmptyBelow(blocks[movingrow][movingcol]);
          if ((isEmptyBelowLeft != -1) && (isEmptyBelowLeft != movingrow)) {
            blocks[movingrow][movingcol].setFalling(true);
            
            //print("RIGHT FALLING");
          }
          
          if (leftblock == null) {
            blocks[movingrow][movingcol+1] = null;
          }
          /* first we switch the blocks in the array, then we do the animation
this is to prevent any POTENTIAL case where the user swaps a block while it is still moving 
        }
        
        */
        
        color leftcolor = 0;
        color rightcolor = 0;
        if (leftblock != null) {
          leftcolor = leftblock.getColor();
        }
        if (rightblock != null) {
          rightcolor = rightblock.getColor();
        }
        
        blocks[movingrow][movingcol] = null;
        blocks[movingrow][movingcol+1] = null;
        
        if (leftblock != null) {
          addBlock(movingrow,movingcol+1,leftcolor);
          int isEmptyBelowRight = isEmptyBelow(blocks[movingrow][movingcol+1]);
          if ((isEmptyBelowRight != -1) && (isEmptyBelowRight != movingrow)) {
            blocks[movingrow][movingcol+1].setFalling(true);
          }
        }
        
        if (rightblock != null) {
          addBlock(movingrow,movingcol,rightcolor);
          int isEmptyBelowLeft = isEmptyBelow(blocks[movingrow][movingcol]);
          if ((isEmptyBelowLeft != -1) && (isEmptyBelowLeft != movingrow)) {
            blocks[movingrow][movingcol].setFalling(true);
          }
        }
        
      }
    }
  }
  
  // ------------------------------------------------------------------------------BLOCK RISING

  if (blocksFalling <= 0) {
    //print(anyFalling+" ");
    rising++;
    if (rising%3 == 0) {
      pushUp++;
      if (pushUp%40 == 0) {
        //print(pushUp+" ");
        pushUp = 0;
        cursor.moveUp();
        //print(nextNewRow);
        Block[] newBottomRow = nextNewRow.dequeue();
        /*Block[] newNext = createRandomRow();
        nextNewRow.enqueue(newNext);*/
        nextNewRow.enqueue();
        for (int row = blocks.length-1; row >= 0; row--) {
          for (int col = 0; col < 6; col++) {
            Block b = blocks[row][col];
            if ((b != null)){ //&& (!b.isFalling())) {
              int bcol = b.getX()/40;
              int brow;
              if (b.isFalling()) {
                brow = ((height-b.getTEMP())/40)-1;
              }
              else {
                brow = ((height-b.getY())/40)-1;
              }
              color bc = b.getColor();
              blocks[row][col] = null;
              addBlock(brow+1,bcol,bc);
            }
          }
        }
        blocks[0] = newBottomRow;
        if (leftblock != null) {
          int newswitchingrow = (height-leftblock.getY())/40;
          int switchingcol = leftblock.getX()/40;
          leftblock = blocks[newswitchingrow][switchingcol];
          rightblock = blocks[newswitchingrow][switchingcol+1];
        }
        //println("\n\n\n");
      }
    }
  }
  
  // ------------------------------------------------------------------------------MISC DRAW ITERATIONS

  print(blocksFalling+"\t");
  blocksFalling = 0;
  cursor.display(); //cursor is drawn on top of the blocks
  //println("\n");
}





// ------------------------------------------------------------------------------MISC FUNCTIONS
  
void addBlock(int row, int col, color c) {
  if (row < blocks.length) {
    blocks[row][col] = new Block(row,col,c);
  }
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

void deleteBlocks(){
  //Sets triplets and more in columns to be deleted
  for(int x = 0; x < 6; x++){
    int num = 0;
    color tempC = #FFFFFF;
    for(int y = 0; y < 12; y++){
      if (pushUp == 0) {
        //print(y+" "+x+" "+blocks[y].length+" ");
        //print(blocks[y][x]+"\t");
      }
      if(blocks[y][x] == null){
        num = 0;
        tempC = #FFFFFF;
      }
      else if((blocks[y][x].getColor() == tempC) && (!blocks[y][x].isFalling())){
        num++;
        if(num >= 3){
          blocks[y-2][x].delete();
          blocks[y-1][x].delete();
          blocks[y][x].delete();
        }
      }
      else{
        num = 1;
        tempC = blocks[y][x].getColor();
      }
    }
  }
  //Sets triplets and more in rows to be deleted
  for(int y = 0; y < 12; y++){
    int num = 0;
    color tempC = #FFFFFF;
    for(int x = 0; x < 6; x++){
      if(blocks[y][x] == null){
        num = 0;
        tempC = #FFFFFF;
      }
      else if(blocks[y][x].getColor() == tempC && (!blocks[y][x].isFalling())){
        num++;
        if(num >= 3){
          blocks[y][x-2].delete();
          blocks[y][x-1].delete();
          blocks[y][x].delete();
        }
      }
      else{
        num = 1;
        tempC = blocks[y][x].getColor();
      }
    }
  }
  //Deletes blocks set to be deleted
  for(int y = 0; y < 12; y++){
    for(int x = 0; x < 6; x++){
      if(blocks[y][x] != null && blocks[y][x].toBeDeleted()){
        blocks[y][x] = null;
      }
    }
  }
}
 

 
//-------------------------------------------------------------------------------------------------

class Block {
  private int x,y,endingRow,temp,fallingi;
  private color c;
  private boolean falling,delete;
  
  public Block(int row, int col, color c) {
    x = 40*col;
    y = height-(40*(row+1));
    this.c = c;
    falling = false;
    delete = false;
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
  
  public int isThereABlockStuckInsideMe() {
    for (int row = 0; row < blocks.length; row++) {
      int col = x/40;
      //print(row+" "+col+"\t");
      Block otherblock = blocks[row][col];
      if ((otherblock != null) && (!otherblock.equals(this)) && otherblock.isFalling()) {
        //print(x+" "+y+"\t");
        int otherY = otherblock.getY();
        int difference = otherY - y;
        //print(difference+" ");
        if ((difference < 40) && (difference > 0)) {
         return difference;
        }
      }
    }
    return -1;
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
  
  public boolean toBeDeleted() {return delete;}
  public void delete() {delete = true;}
  
  public void display() {
    fill(c);
    rect(x,y-pushUp,40,40,6);
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
    rect(x,y-pushUp,80,40);
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


class RowQueue {
  Block[][] queue;
  int i;
  
  public RowQueue() {
    queue = new Block[2][1];
  }
  
  public Block[] dequeue() {
    Block[] temp = queue[i];
    queue[i] = null;
    ;//print(temp);
    return temp;
  }
  
  public void enqueue() {
    //print(queue[i]);
    //if (queue[i] == null) {
      //print("HELLO");
      queue[i] = createRandomRow();
      if (i == 0) {
        i = 1;
      }
      else {
        i = 0;
     // }
    }
  }
  
  public String toString() {
    return "\t["+Arrays.toString(queue[0])+"]"+Arrays.toString(queue[1])+"]]\t";
  }
  
  public Block[] createRandomRow() { //designed for the bottom, and only the bottom, row
    Block[] ret = new Block[6];
    for (int i = 0; i < 6; i++) {
      ret[i] =  new Block(0,i,colors[r.nextInt(colors.length)]);
    }
    //print(Arrays.toString(ret));
    return ret;
  }
 
}
  
