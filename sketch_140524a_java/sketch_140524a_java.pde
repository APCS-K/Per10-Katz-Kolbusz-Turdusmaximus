Block[][] a;
color red = color(255,20,20);

void setup() { //6 by 12 blocks (really 13)
  size(240,520);
  frameRate(30);
  
  a = new Block[12][6];
  
  a[0][0] = new Block(0,0,red);
}
 
void draw() { 
  background(204);
  
  for (Block[] row : a) {
    for (Block b : row) {
      if (b != null) {
        b.display();
      }
    }
  }
  
}


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
    rect(x,y,40,40,5);
  }
  
}
