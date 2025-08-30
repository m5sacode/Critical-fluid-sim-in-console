import controlP5.*;

ControlP5 cp5;

int size = 15;
float startDensity = 0.5;
float T = 10;
boolean[][] state_screen = new boolean[size][size];

// rolling average
int windowSize = 30;                   // how many steps to average
ArrayList<Float> energyDiffs = new ArrayList<Float>();

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
  println("\n \n ");
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
  println("\n \n ");
}

int Get_pixel_pot_energy(boolean[][] screen, int size, int x, int y) {

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

  if (screen[x1][y1] ^ screen[x2][y2]) {
    int energy_dif = Get_pixel_pot_energy(screen, size, x2, y2) - Get_pixel_pot_energy(screen, size, x1, y1);

    // === record absolute energy difference ===
    recordEnergyDiff(abs(energy_dif));

    float q = exp(energy_dif/T);
    float changeprob12 = q/(1+q);
    boolean change = RandomBoolean(changeprob12);
    if (change) {
      screen[x1][y1] = !screen[x1][y1];
      screen[x2][y2] = !screen[x2][y2];
    }
  }
}

//   store energy diffs and keep rolling average
void recordEnergyDiff(float val) {
  energyDiffs.add(val);
  if (energyDiffs.size() > windowSize) {
    energyDiffs.remove(0); // remove oldest
  }
}

float getRollingAverage() {
  if (energyDiffs.size() == 0) return 0;
  float sum = 0;
  for (float v : energyDiffs) sum += v;
  return sum / energyDiffs.size();
}

void Draw_Screen_Graphics(boolean[][] screen, int size) {
  background(255);
  float cellSize = width / float(size);

  noStroke();
  for (int x = 0; x<size; x++) {
    for (int y = 0; y<size; y++) {
      if (screen[x][y]) {
        fill(50, 50, 255); // black square
      } else {
        fill(0); // white square
      }
      rect(x*cellSize, y*cellSize, cellSize, cellSize);
    }
  }
}

void Draw_cell(int x, int y, boolean state, float cellSize) {
  if (state) fill(50, 50, 255);
  else fill(0);
  noStroke();
  rect(x * cellSize, y * cellSize, cellSize, cellSize);
}

void Update_and_Draw(boolean[][] screen, int size, float T) {
  int x1 = int(random(size));
  int y1 = int(random(size));
  int x2 = int(random(size));
  int y2 = int(random(size));
  boolean p1 = screen[x1][y1];
  boolean p2 = screen[x2][y2];

  if (p1 ^ p2) {
    int e1 = Get_pixel_pot_energy(screen, size, x1, y1);
    int e2 = Get_pixel_pot_energy(screen, size, x2, y2);
    int energy_dif = e2 - e1;

    float q = exp(energy_dif/T);
    float changeprob12 = q/(1+q);

    if (RandomBoolean(changeprob12)) {
      screen[x1][y1] = !p1;
      screen[x2][y2] = !p2;

      float cellSize = width / float(size);
      Draw_cell(x1, y1, !p1, cellSize);
      Draw_cell(x2, y2, !p2, cellSize);
    }
  }
}


// Function to get the energy of a state

//int GetEnergy(){
//  int energy = 0;

//  return energy;
//}

void setup() {
  size(700, 700);
  //Generate_checkerboard(size, state_screen);
  Generate_random(size, state_screen, startDensity);

  // === Slider setup ===
  cp5 = new ControlP5(this);
  cp5.addSlider("T", 0.05, 10, T, 10, height-40, 200, 20).plugTo(this, "T");//Nombre, Min, max, pos, x, y, ancho, alto
  Draw_Screen_Graphics(state_screen, size);
}

void draw() {
  //Update_state(state_screen, size, T);
  //Draw_Screen_Graphics(state_screen, size);
  //Draw_Screen_Console(state_screen, size, " @ ", "   ");
  Update_and_Draw(state_screen, size, T);
  fill(255);
  textSize(14);
  text("Temperature: " + nf(T, 1, 2), 10, 40);
}
