import controlP5.*;

ControlP5 cp5;



int size = 30;
float T = 0.1;
boolean[][] state_screen = new boolean[size][size];

// Test screen:
//boolean[][] state_screen = {{true, false, true, false},
//                            {false, true, false, true},
//                            {true, false, true, false},
//                            {false, true, false, true}};

// Draws aternating screen of a given size TRABAJANDO EN ESTO

void Generate_checkerboard(int size, boolean[][] state_screen) {
  for (int x = 0; x<size; x++) {
    for (int y = 0; y<size; y++) {
      state_screen[x][y] = ((y%2 == 0) && (x%2 == 0)) || ((y%2 != 0) && (x%2 != 0)) ;
    }
  }
}

void Generate_random(int size, boolean[][] state_screen, float prob) {
  for (int x = 0; x<size; x++) {
    for (int y = 0; y<size; y++) {
      state_screen[x][y] = RandomBoolean(prob) ;
    }
  }
}


void Draw_Screen_Console(boolean[][] screen, int size, String white, String black) {
  String line = "";
  String separator = "";
  for (int i=0; i<size; i++) separator+="---";
  println("\n" + separator + " \n");
  for (int y=0; y<size; y++) {
    line = "";

    for (int x=0; x<size; x++) {
      if (screen[x][y]) {
        line += white;
      } else {
        line += black;
      }
    }
    println(line);
  }
  println("\n \n" + separator + "\n");
}

int Get_pixel_energy(boolean[][] screen, int size, int x, int y) {

  int energy = 0;
  if (x>0) {
    if (screen[x-1][y])energy--;
  }
  if (x<size-1)
  {
    if (screen[x+1][y])energy--;
  }
  if (y>0) {
    if (screen[x][y-1])energy--;
  }
  if (y<size-1)
  {
    if (screen[x][y+1])energy--;
  }
  return energy;
}

boolean RandomBoolean(float prob) {
  float randomN = random(0, 1);
  return (randomN < prob);
}

void Update_state(boolean[][] screen, int size, float T) {
  int x1 = int(random(size));
  int y1 = int(random(size));
  int x2 = int(random(size));
  int y2 = int(random(size));
  boolean p1 = screen[x1][y1];
  boolean p2 = screen[x2][y2];
  if (p1 ^ p2) {
    int energy_dif = Get_pixel_energy(screen, size, x1, y1) - Get_pixel_energy(screen, size, x2, y2);
    if (p2) {
      energy_dif*=-1;
    }
    float q = exp(energy_dif/T);
    float changeprob12 = q/(1+q);
    boolean change = RandomBoolean(changeprob12);
    if (change) {
      screen[x1][y1] = !p1;
      screen[x2][y2] = !p2;
    }
  }
}

// Function to get the energy of a state

//int GetEnergy(){
//  int energy = 0;

//  return energy;
//}

void setup() {
  size(300, 100);
  
  //Generate_checkerboard(size, state_screen);
  Generate_random(size, state_screen, 0.1);
  // slider for temperature
  cp5 = new ControlP5(this);
  cp5.addSlider("T", 0.1, 2, T, 10, height/2 -20, 260, 40).plugTo(this, "T");
}

void draw() {
  for (int i = 0; i<500; i++) {
    Update_state(state_screen, size, T);
  }
  Draw_Screen_Console(state_screen, size, " @ ", "   ");
  background(0);
}
