import java.util.Map;

PVector last;

float exposure = 0.077;
float gamma = 1.045;

float a = -0.167;
float b = 5.462;
float c = 0.913;
float d = -2.949;

int oversample = 1;

float []points;
float total = 0.0;
float peak = 1.0;

boolean stats = false;
boolean paused = false;

float []histogram;

color bg;
color fg;

void setup() {
  size(600, 600);
  
  bg = color(41, 68, 85);
  fg = color(212, 194, 170);

  points = new float[width * oversample * height * oversample];
  for (int i = 0; i < points.length; i++) {
    points[i] = 0.0;
  }
  
  last = new PVector();
  
  noSmooth();
}

void draw() {
  background(bg);
  if (!paused) {
    for (int i = 0; i < 1000; i++) {
      float x = sin(a * last.y) - cos(b * last.x);
      float y = sin(c * last.x) - cos(d * last.y);
      
      last.x = x;
      last.y = y;
      
      x = map(x, -2, 2, 0, width * oversample);
      y = map(y, -2, 2, height * oversample, 0);
        
      int idx = ((int) round(x)) + (((int) round(y)) * width * oversample);
      points[idx] = points[idx] + 1;
      peak = max(peak, points[idx]);
    }
    
    total += 1000;
  }
  
  loadPixels();
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      int i = (x * oversample) + (y * width * oversample);
      float rd = 0.0;
      float gn = 0.0;
      float bl = 0.0;
      
      for (int j = 0; j < oversample; j++) {
        for (int k = 0; k < oversample; k++) {
          float v = points[i + j + (k * width * oversample)] / peak * 100;
          float b = exposure * pow(v, gamma);
          color c = lerpColor(bg, fg, b);
          
          rd += red(c);
          gn += green(c);
          bl += blue(c);
        }
      }
      
      rd /= pow(oversample, 2);
      gn /= pow(oversample, 2);
      bl /= pow(oversample, 2);
      
      pixels[x + y * width] = color(rd, gn, bl);
    }
  }
  updatePixels();
}

void keyPressed() {
  if (key == ' ') {
    paused = !paused;
    if (paused) println(total);
  } else if (key == TAB) {
    stats = !stats;
    paused = stats;
   println(total);
    for (int i = 0; i < histogram.length; i++) {
      println(i, histogram[i]);
    }
  }
}

void drawStats() {
  noStroke();
  fill(0, 0, 0, 0.2);
  rect(0, 0, width, height);
  
  pushMatrix();
  translate(12, 12);
  
  fill(255);
  
  int w = (width - 24) / histogram.length;
  
  float upper = 0;
  for (int i = 0; i < histogram.length; i++) {
    upper = max(upper, histogram[i]);
  }
  
  for (int i = 0; i < histogram.length; i++) {
    rect(i * w, height - 24, w - 1, map(histogram[i], 0, upper, 0, 24 - height));
  }
    
  popMatrix();
}
