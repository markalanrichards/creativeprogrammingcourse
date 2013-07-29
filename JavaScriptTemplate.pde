//The MIT License (MIT) - See Licence.txt for details

//Copyright (c) 2013 Mick Grierson, Matthew Yee-King, Marco Gillies (original work of Sonic Painter)
//Copyright (c) 2013 Mark Richards (Probably very different from original, but possibly borrowing a few lines, and the helper classes ;-) )


Maxim maxim;
AudioPlayer player;
AudioPlayer player2;
boolean player_playing;


//control_top between visualization and controls
int visualization_height;
int sound_wave_height;
int sound_wave_top;
int control_top;
int control_height;
int margin_y;
//color weighting
int hue_color;
int brightness_color;
int saturation_color;

//color control area dimenstions
int control_area_top;
int control_area_bottom;
int control_area_width;
int control_area_height;
int hue_control_area_x;
int saturation_control_area_x;
int brightness_control_area_x;

int y_pos;
int x_pos;
int length_of_hue_ellipse;
//int control dimesions
int ellipse_radius;
int hue_slide_x;
int hue_slide_y;
int saturation_slide_x;
int saturation_slide_y;
int brightness_slide_x;
int brightness_slide_y;


int[] starLocations;
int starLocationsArraySize;
int starLimit;
int starNext;

int lastSquareWaveX, lastSquareWaveY, nextSquareWaveX, nextSquareWaveY;
int SquareWaveX, SquareWaveY;
float SquareWaveAngle;

PShape star;

void setup()
{
  colorMode(HSB);
  hue_color = 180;
  brightness_color = 50;
  saturation_color = 50;
  size(960,640);
  maxim = new Maxim(this);
  player = maxim.loadFile("funky2.wav");
  player.setLooping(true);
  player.setAnalysing(true);
  player_playing = false;
//  player.volume(1);
  background(255);
  calculate_bottom();
  calculate_control_areas();
  calculate_sliders();
  starLimit = 255;
  starLocationsArraySize = starLimit * 3;
  starLocations = new int[starLocationsArraySize];
  for (int i=0;i<starLocationsArraySize;i++) starLocations[i] = -1;
  starNext = 0;
  star = loadShape("whitestar.svg");
  star.disableStyle();
  fill(0);
  rect(0,0,width,height);
 
  SquareWaveY = height/4;
  SquareWaveX = 0;
  lastSquareWaveX = 0;
  lastSquareWaveY = 0;
  nextSquareWaveX = 0;
  nextSquareWaveY =0;
  strokeWeight(3);
  
}

void calculate_bottom() {
  control_top = (3*height)/4;
  control_height = height - control_top;
}
void calculate_control_areas() {
  margin_y = control_height / 12;
  control_area_top = control_top + margin_y;
  control_area_bottom = height - margin_y; 
  control_area_width = width / 24;
  control_area_height = control_area_bottom - control_area_top;
  hue_control_area_x = (width / 4) - (control_area_width/2) - (control_area_width)/4;
  saturation_control_area_x = (width / 2) - (control_area_width/2);
  brightness_control_area_x  = ((3 * width) / 4) - (control_area_width/2) + (control_area_width)/4;
  y_pos = (control_area_top + control_area_bottom) / 2;
  x_pos = ((width - control_area_width) / 4);
  length_of_slider = (control_area_bottom - control_area_top);
  length_of_hue_ellipse = ((control_area_bottom - control_area_top) /2) - (ellipse_radius/2);
}
void calculate_sliders() {
  ellipse_radius = (control_area_width * 15) /10;
  float angle =((float)hue_color) * PI / (float) 180;
  hue_slide_x = (length_of_hue_ellipse * cos(angle)) + ((width - control_area_width) / 4);
  hue_slide_y = (length_of_hue_ellipse * sin(angle)) + y_pos;
  //hue_slide_y = (int) map(hue_color,360,0,control_area_top, control_area_bottom);
  saturation_slide_x = ( width) /2;
  saturation_slide_y = (int) map(saturation_color,100,0,control_area_top, control_area_bottom);
  brightness_slide_x = ((control_area_width) + (3 * width)) / 4;
  brightness_slide_y = (int) map(brightness_color,100,0,control_area_top, control_area_bottom);
}
void calculate_rotator() {
  stroke((hue_color+180)%360,100,100);
  fill(hue_color,100,100); 
  ellipse(hue_slide_x,hue_slide_y, ellipse_radius, ellipse_radius);  
}
void draw_stars() {
  noStroke();
  for (int i=0;i<starLocationsArraySize;i+=3) {
    if(starLocations[i] > -1) { 
      draw_star(starLocations[i],starLocations[i+1],starLocations[i+2]);
      starLocations[i] = starLocations[i]-1;
    }
  }
}
void draw_star(int brightness, int x, int y) {
  pushMatrix();
  translate(x,y);
  //rotate(map(brightness,0,255,0,TWO_PI));
  
  fill(hue_color,saturation_color,brightness);
  shape(star,-10,-10, 20,20);
  popMatrix();
  
}
void draw_slider(int x, int y) {
 ellipse(x, y,ellipse_radius, ellipse_radius); 
}
void draw_sliders() {
 //fill(180,100,100);
 // draw_slider(hue_slide_x, hue_slide_y);
 fill(0,50,0);
 draw_slider(saturation_slide_x, saturation_slide_y);
 fill(0,0,50);
 draw_slider(brightness_slide_x, brightness_slide_y);
 
}

void draw_SquareWaves() {
  if(player_playing) {
  pushMatrix();
  fill(hue_color, saturation_color,brightness_color);
  stroke(hue_color, saturation_color,brightness_color);
  translate(SquareWaveX, SquareWaveY);
  pushMatrix();
  rotate(SquareWaveAngle);
  lastSquareWaveX = nextSquareWaveX;
  nextSquareWaveX = lastSquareWaveX +1; 
  if(nextSquareWaveX >= width) nextSquareWaveX = 0;
  else {
    lastSquareWaveY = nextSquareWaveY;
    nextSquareWaveY = (int) (player.getAveragePower()*(float)1000);
    line(lastSquareWaveX, lastSquareWaveY, nextSquareWaveX, nextSquareWaveY);
    ellipse(nextSquareWaveX, 0, lastSquareWaveY, nextSquareWaveY);
  }
  popMatrix();
  popMatrix();
  }
}

void draw_control_areas() { 
  fill(0);
  ellipse(x_pos, y_pos, length_of_slider + 5, length_of_slider + margin_y/2);
  
  fill(hue_color,saturation_color,brightness_color);
  ellipse(x_pos, y_pos, length_of_slider - 5, length_of_slider - margin_y/2);
  fill(0,saturation_color,0);
  rect(saturation_control_area_x, control_area_top,control_area_width, control_area_height,10);
  fill(0,0,brightness_color);
  rect(brightness_control_area_x, control_area_top,control_area_width, control_area_height,10);
}

void draw_top_background() {
  fill(0,5);
  rect(0,0,width,control_top);
}
void draw()
{
  int next_hue = hue_color+1;
  if(next_hue>=360) hue_color=0;
  else hue_color=next_hue;
  calculate_sliders();
  draw_top_background();
  draw_stars();
  draw_SquareWaves();
  draw_bottom_background();
  draw_control_areas();
  draw_sliders();
  calculate_rotator();
  player.volume((float) brightness_color/100);
  player.speed((float) saturation_color/100);
}
void draw_bottom_background() {
  fill(hue_color,saturation_color,brightness_color);
  rect(0,control_top,width,control_height);
}

boolean mouseDraggedhue() {
  if(dist(mouseX, mouseY, hue_slide_x, hue_slide_y) < ellipse_radius) {
    float angle= atan2((float)(pmouseY-y_pos),(float)(pmouseX-x_pos));
    console.log("angle: " + angle);
    hue_color = ((int)((angle * (float)180 / PI)) + 360)%360;
    console.log("hue: "+ hue_color);
    calculate_sliders();    
    return true;
  }
  return false;
}
int normalisedPMouseY(int pmouseypoint) {
  int limitedMouseY;
    if(pmouseypoint < control_area_top) limitedMouseY = control_area_top;
    else if(pmouseypoint > control_area_bottom) limitedMouseY = control_area_bottom;
    else limitedMouseY = pmouseypoint;
    return limitedMouseY;
}
boolean mouseDraggedbrightness() {
  if(dist(mouseX, mouseY, saturation_slide_x, saturation_slide_y) < ellipse_radius) {
    saturation_color = (int) map(normalisedPMouseY(pmouseY), control_area_top, control_area_bottom, 100, 0);
calculate_sliders();    
    return true;
  }
  return false;
}boolean mouseDraggedsaturation() {
  if(dist(mouseX, mouseY, brightness_slide_x, brightness_slide_y) < ellipse_radius) {
    brightness_color = (int) map(normalisedPMouseY(pmouseY), control_area_top, control_area_bottom, 100, 0);
calculate_sliders();    
    return true;
  }
  return false;
}
void mouseDragged()
{
  if(mouseY > control_top) {
    if(!mouseDraggedhue()) if(!mouseDraggedsaturation()) if (!mouseDraggedbrightness()) {
      //  not dragging anything, ignore!
    }
  }
  else {
    if(mouseX > 0 && mouseX < width && mouseY >0 ){
      SquareWaveX = pmouseX;
      SquareWaveY = pmouseY;
      int  deltaX = mouseX - pmouseX;
      int deltaY = mouseY - pmouseY;
      SquareWaveAngle = atan2((float)deltaY, (float)deltaX);
      nextSquareWaveX = 0;
      nextSquareWaveY = 0;
      player.play();
      player_playing = true;
    }
  }
}


void mouseClicked() {
  player2 = maxim.loadFile("savannahcymbal2.wav");
  player2.setLooping(false);
  player.setAnalysing(false);
  player2.play();
  starNext = starNext +1 ;
  if(starNext >= starLimit) starNext = 0;
  int starBrightnessLocation = starNext*3;
  starLocations[starBrightnessLocation] = 255;
  starLocations[starBrightnessLocation + 1] = mouseX;
  starLocations[starBrightnessLocation + 2] = mouseY;
}

