import processing.sound.*;
import java.util.Date;
SoundFile rainsound, dropsound;

float [][] Buffer1;
float [][] Buffer2;

//settings!
int background = 20;
boolean rain = true;
int rainvalue = 7;
int dropsize = 5;
float flow = 20;
boolean sound = false;
boolean weirddot = false;
boolean screensaver = false;

/***
 *       ____        _      _    ______ _               
 *      / __ \      (_)    | |  |  ____| |              
 *     | |  | |_   _ _  ___| | _| |__  | | _____      __
 *     | |  | | | | | |/ __| |/ /  __| | |/ _ \ \ /\ / /
 *     | |__| | |_| | | (__|   <| |    | | (_) \ V  V / 
 *      \___\_\\__,_|_|\___|_|\_\_|    |_|\___/ \_/\_/  
 *                                                      
 *                                                      
 */

void setup() {
  //size(750, 400);
  fullScreen();
  Buffer1 = new float[width][height];
  Buffer2 = new float[width][height];

  rainsound = new SoundFile(this, "Rain.wav");
  dropsound = new SoundFile(this, "Drop.wav");
  if (rain == true && sound == true)rainsound.loop();
  console();
}


void draw() {
  if (weirddot == true)Buffer1[width/2][height/2] = 20*dropsize;
  if (screensaver == true)screensaver();
  ripple();
}

void ripple() {
  loadPixels();
  for (int x = 1; x < width - 1; x++) {
    for (int y = 1; y < height - 1; y++) {
      Buffer2[x][y] =(
        Buffer1[x - 1][y] +
        Buffer1[x + 1][y] +
        Buffer1[x][y + 1] +
        Buffer1[x][y - 1]) / 2 - Buffer2[x][y];

      Buffer2[x][y] *= dampening(flow);

      int index = x + y * width;
      pixels[index] = color(Buffer1[x][y]*100 + background);
    }
  }

  if (rain == true)rain(rainvalue);

  float[][] temp = Buffer2;
  Buffer2 = Buffer1;
  Buffer1 = temp;

  updatePixels();
}

int sscount = 0;
int ssswitch = 1000;
void screensaver() {
  if (sscount == ssswitch*1/3) {
    flow = 45;  
    console();
  }
  if (sscount == ssswitch) {
    flow = 15;
    sscount = 0;
    console();
  }
  sscount++;
}

int count = 0;
void rain(int weight) {
  for (int x = 0; x < weight; x++) {
    if (count == 10) {
      Buffer2[(int)random(5, width - 5)][(int)random(5, height - 5)] = dropsize; 
      count = 0;
    }
    count++;
  }
}


// Functional ===========================================================

void console() {
  println(new String(new char[20]).replace("\0", "\r\n"));
  println("QuickFlow");
  println("Scroll to adjust dampening length\nPress any key to reset");
  if (rain == true)println("It's Raining...");
  else println("The sky is clear...");
  println("Flow: " + (int)flow + ", Dropsize: " + (int)dropsize);
  println("Mouse x,y: " + mouseX + ", " + mouseY);
}

void mouseDragged() {
  if (mouseInBound()) {
    Buffer1[mouseX][mouseY] = dropsize;
    console();
  }
}

void mousePressed() {
  if (mouseInBound()) {
    Buffer1[mouseX][mouseY] = 40*dropsize;
    if (sound == true)dropsound.play();
    console();
  }
}

boolean mouseInBound() {
  if (mouseX > 0 && mouseX < width && mouseY > 0 && mouseY < height)return true;
  return false;
}

void keyPressed() {
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      Buffer2[x][y] = Buffer1[x][y] = 0;
    }
  }
  println("Canvas reset!");
}

void mouseWheel(MouseEvent event) {
  if (event.getCount() == -1 && flow < 50)flow++;
  if (event.getCount() == 1 && flow > -10)flow--;
  console();
}

float dampening(float flow) {
  return (1 / (1 + pow((float)Math.E, -(flow/5))));
}
