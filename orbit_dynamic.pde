float SCALE_FACTOR, MAX_MAGNITUDE = 2;
color BROT_COLOUR = color(100);
int MAX_OVERLAY_ITERATIONS = 1000;
PImage BROT_OVERLAY;
ArrayList<PImage> ORBIT_OVERLAYS;
int MAX_ORBIT_ITERATIONS = 10000;
float RAINBOW_RATE = 3;
float ORBIT_POINT_RADIUS = 5;

class Complex {
  float re, im;
  Complex(float re, float im) {
    this.re = re;
    this.im = im;
  }

  Complex(int x, int y) {
    this((x - width * 0.5) * SCALE_FACTOR, 
         (y - height * 0.5) * SCALE_FACTOR);
  }
  
  PVector coord() {
    return new PVector(re / SCALE_FACTOR + width * 0.5,
                       im / SCALE_FACTOR + height * 0.5);
  }
  
  Complex copy() {
    return new Complex(re, im);
  }
  
  void mult(Complex other) {
    float old_re = re,
          old_im = im,
          otd_re = other.re,
          otd_im = other.im;
    re = old_re * otd_re - otd_im * old_im;
    im = old_re * otd_im + old_im * otd_re;
  }
  
  void add(Complex other) {
    re += other.re;
    im += other.im;
  }
  
  float abs() {
    return dist(0, 0, re, im); 
  }
}

boolean is_brot(int x, int y) {
  Complex z, c;
  c = new Complex(x, y);
  z = c.copy();
  for (int i = 0; i < MAX_OVERLAY_ITERATIONS; i++) {
    z.mult(z);
    z.add(c);
    if (z.abs() > 2) {
      return false; 
    }
  }
  return true;
}

PImage draw_brot() {
  PImage brot = createImage(width, height, RGB);
  brot.loadPixels();
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < width; y++) {
      if (is_brot(x, y)) {
        brot.pixels[y * width + x] = BROT_COLOUR; 
      }
    }
  }
  brot.updatePixels();
  return brot;
}

PGraphics brot_orbit(int x, int y) {
  PVector pnt;
  PGraphics orb = createGraphics(width, height);
  orb.beginDraw();
  orb.ellipseMode(CENTER | RADIUS);
  orb.noStroke();
  orb.colorMode(HSB, 255, 255, 255);
  Complex z, c = new Complex(x, y);
  z = c.copy();
  for (int i = 0; i < MAX_ORBIT_ITERATIONS; i++) {
    z.mult(z);
    z.add(c);
    pnt = z.coord();
    orb.fill((i * RAINBOW_RATE) % 255, 255, 255);
    orb.ellipse(pnt.x, pnt.y, ORBIT_POINT_RADIUS, ORBIT_POINT_RADIUS);
  }
  orb.endDraw();
  return orb;
}

void setup() {
  size(1024, 1024);
  background(0);
  if (height > width) {
    SCALE_FACTOR = 2 * MAX_MAGNITUDE / width;
  } else {
    SCALE_FACTOR = 2 * MAX_MAGNITUDE / height;
  }
  BROT_OVERLAY = draw_brot();
  ORBIT_OVERLAYS = new ArrayList<PImage>();
}

void draw() {
  image(BROT_OVERLAY, 0, 0);
  for (PImage img: ORBIT_OVERLAYS) {
    image(img, 0, 0);
  }
  image(brot_orbit(mouseX, mouseY), 0, 0);
}

void keyPressed() {
  switch (keyCode) {
    case ' ':
      mouseClicked();
      break;
    case 'R':
      ORBIT_OVERLAYS.clear();
      break;
    case BACKSPACE:
      if (ORBIT_OVERLAYS.size() > 0) {
        ORBIT_OVERLAYS.remove(ORBIT_OVERLAYS.size() - 1);
      }
      break;
  }
}

void mouseClicked() {
  ORBIT_OVERLAYS.add(brot_orbit(mouseX, mouseY));
}
