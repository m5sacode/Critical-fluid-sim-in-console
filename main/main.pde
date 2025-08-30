int size = 60;

boolean[][] state_screen = new boolean[size][size];

// Test screen:
//boolean[][] state_screen = {{true, false, true, false},
//                            {false, true, false, true},
//                            {true, false, true, false},
//                            {false, true, false, true}};
                            
// Draws aternating screen of a given size TRABAJANDO EN ESTO

void Generate_checkerboard(int size, boolean[][] state_screen) {
  for (int x = 0; x<size; x++){
    for (int y = 0; y<size; y++){
      state_screen[x][y] = ((y%2 == 0) && (x%2 == 0)) || ((y%2 != 0) && (x%2 != 0)) ;
    }  
  }
}
                            

void Draw_Screen_Console(boolean[][] screen, int size, String white, String black){
  String line = "";
  println("\n \n ");
  for (int y=0; y<size; y++) {
    line = "";
    
    for (int x=0; x<size; x++) {
      if (screen[x][y]){
        line += white; 
      }
      else{
        line += black;
      }
    }
    println(line);
  }
  println("\n \n ");
}

void setup() {
  size(100, 100);
  Generate_checkerboard(size, state_screen);
  
}

void draw() { 
  Draw_Screen_Console(state_screen, size, " @ ", " . ");
}
