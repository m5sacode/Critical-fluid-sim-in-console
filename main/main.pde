import controlP5.*;

ControlP5 cp5;

int size = 400;          // grid size (try 200+ for performance test)
float startDensity = 0.2;
float T = 0.1;
boolean[][] state_screen = new boolean[size][size];

PImage gridImage;        // image buffer for fast drawing

// rolling average
int windowSize = 30;                   
ArrayList<Float> energyDiffs = new ArrayList<Float>();

// === Initialization ===
void setup() {
  size(700, 700);
  Generate_random(size, state_screen, startDensity);

  // create image to represent the grid
  gridImage = createImage(size, size, RGB);
  gridImage.loadPixels();
  for (int x=0; x<size; x++) {
    for (int y=0; y<size; y++) {
      gridImage.pixels[y*size + x] = state_screen[x][y] ? color(50,50,255) : color(0);
    }
  }
  gridImage.updatePixels();

  // slider for temperature
  cp5 = new ControlP5(this);
  cp5.addSlider("T", 0.01, 0.3, T, 10, height-40, 200, 20).plugTo(this, "T");
}

// === Drawing loop ===
void draw() {
  int stepsPerFrame = 5000;  // do many updates per frame for smoother dynamics
  for (int i=0; i<stepsPerFrame; i++) {
    Update_and_Draw(state_screen, size, T);
  }

  gridImage.updatePixels();
  image(gridImage, 0, 0, width, height);

  // overlay text
  fill(255);
  rect(0, 0, 220, 40);
  fill(0);
  textSize(14);
  text("Temperature: " + nf(T, 1, 2), 10, 20);
  text("Rolling avg ΔE: " + nf(getRollingAverage(), 1, 3), 10, 35);
}

// === Core functions ===
void Generate_random(int size, boolean[][] screen, float prob) {
  for (int x = 0; x<size; x++) {
    for (int y = 0; y<size; y++) {
      screen[x][y] = RandomBoolean(prob);
    }
  }
}

boolean RandomBoolean(float prob) {
  return (random(1) < prob);
}

int Get_pixel_pot_energy(boolean[][] screen, int size, int x, int y) {
  int energy = 0;
  if (x>0 && screen[x-1][y]) energy--;
  if (x<size-1 && screen[x+1][y]) energy--;
  if (y>0 && screen[x][y-1]) energy--;
  if (y<size-1 && screen[x][y+1]) energy--;
  return energy;
}

void setPixelInImage(int x, int y, boolean state) {
  gridImage.pixels[y*size + x] = state ? color(50,50,255) : color(0);
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
    int energy_dif = e1 - e2;

    recordEnergyDiff(abs(energy_dif));

    float q = exp(energy_dif/T);
    float changeprob12 = q/(1+q);

    if (RandomBoolean(changeprob12)) {
      screen[x1][y1] = !p1;
      screen[x2][y2] = !p2;

      setPixelInImage(x1, y1, !p1);
      setPixelInImage(x2, y2, !p2);
    }
  }
}

// === Rolling average helpers ===
void recordEnergyDiff(float val) {
  energyDiffs.add(val);
  if (energyDiffs.size() > windowSize) {
    energyDiffs.remove(0);
  }
}

float getRollingAverage() {
  if (energyDiffs.size() == 0) return 0;
  float sum = 0;
  for (float v : energyDiffs) sum += v;
  return sum / energyDiffs.size();
}
