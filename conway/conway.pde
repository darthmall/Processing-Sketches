boolean []board;

int generations = 0;

boolean paused = false;

color bg;
color fg;
color err;
color semiwhite;

boolean stats = false;
CircularBuffer perf;
float slowest = 0;

void setup() {
  size(1024, 768);

  board = new boolean[width * height];
  for (int i = 0; i < board.length; i++) {
    board[i] = random(0, 1) < 0.1;
  }

  bg = color(41, 68, 85);
  fg = color(212, 194, 170);
  err = color(229, 80, 24);
  semiwhite = color(255);
  
  perf = new CircularBuffer(100);
  
  background(bg);
  frameRate(32);
}

void draw() {
  int start = millis();
  
  loadPixels();
  for (int i = 0; i < board.length; i++) {
    pixels[i] = board[i] ? fg : bg;
  }
  updatePixels();

  if (paused) {
    text("(Paused)", 3, 24);
    return;
  }

  boolean []next = new boolean[board.length];
  for (int i = 0; i < board.length; i++) {
    int neighbors = neighborCount(i);
    
    next[i] = neighbors == 3 || (board[i] && neighbors == 2);
  }
  
  board = next;
  generations++;
  int end = millis();
  
  slowest = max(slowest, end - start);
  
  perf.insert((float) (end - start));
  
  if (stats) {
    fill(255);
    text("Generation: " + str(generations), 3, 12);
    
    // Print performance monitor
    translate(3, 74);
    noStroke();
    for (int i = 0; i < perf.size(); i++) {
      // Ad hoc horizon chart
      float v = perf.get(i);
      float h = v % 20;
      float level = floor(v / 5);
      
      fill(lerpColor(semiwhite, err, (level - 1) / 10));
      rect(i, -50, 1, map(20 - h, 0, 20, 0, 50));
      
      fill(lerpColor(semiwhite, err, level / 10));
      rect(i, 0, 1, map(h, 0, 20, 0, -50));
    }
    
    fill(0, 128);
    text(str((int) 1000 / perf.mean()), 0, -38);
    text(str(perf.mean()), 0, 0);
  }
}

int neighborCount(int index) {
  int count = board[index] ? -1 : 0;
  
  for (int x = -1; x < 2; x++) {
    for (int y = -1; y < 2; y++) {
      count += board[wrap(index + x + (width * y))] ? 1 : 0;
    }
  }
  
  return count;
}

int wrap(int index) {
  while (index < 0) {
    index += board.length;
  }
  
  while (index >= board.length) {
    index -= board.length;
  }
  
  return index;
}

void keyPressed() {
  if (key == ' ') {
    paused = !paused;
  } else if (key == TAB) {
    stats = !stats;
  }
}

class CircularBuffer {
  int offset = 0;
  int size = 0;
  
  float []data;
  
  public CircularBuffer(int size) {
    data = new float[size];
  }
  
  public void insert(float d) {
    data[offset] = d;
    offset = (offset + 1) % data.length;
    
    if (size < data.length) {
      size++;
    }
  }
  
  public int size() {
    return this.size;
  } 

  public float get(int i) {
    return data[(oldest() + i) % data.length];
  }

  public float mean() {
    float m = 0;
    
    for (int i = 0; i < size; i++) {
      m += data[i];
    }
    
    return m / size;
  }
  
  protected int oldest() {
    return (size < data.length) ? 0 : offset;
  }
}
