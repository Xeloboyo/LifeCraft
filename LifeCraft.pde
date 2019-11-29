import peasy.*;
import peasy.org.apache.commons.math.*;
import peasy.org.apache.commons.math.geometry.*;
float toal = 0.0,toal2=0.0;
PImage output;
PeasyCam p;
SpriteBatch tileBatch;
void setup(){
  
  sysdir=sketchPath("\\");
  initialiseGUI();
  Trait alive=new Trait("data\\traits",0);
  println(alive.name);
  for (int i=-3; i<=3; i++){for (int j=-3; j<=3; j++){toal+=1f/(dist(i,j,0,0)+0.5);}}
  for (int i=-1; i<=1; i++){for (int j=-1; j<=1; j++){toal2+=1f/(dist(i,j,0,0)+0.2);}}
  masterobj = parseJSONObject(fileToString("masterContent.txt"));
  int types = masterobj.getInt("terrainTypes");
  for(int i = 0;i<types;i++){
    JSONObject ttype = masterobj.getJSONObject("TerrainType_"+i);
    terrainTypes.put(ttype.getString("name"),new TerrainType(ttype));
  }
  generate(400,200);
  size(1000,500,P2D);
  output = terrainToImage();
  p  = new PeasyCam(this, 400);
  tiles = loadImage("tiles.png");
  tileBatch = new SpriteBatch(50000);
  tileBatch.addSprite("dirt",tiles.get(32,32,32,32));
  tileBatch.addSprite("grass",tiles.get(0,0,32,32));
  tileBatch.addSprite("sand",tiles.get(0,32,32,32));
  tileBatch.addSprite("arid dirt",tiles.get(64,0,32,32));
  tileBatch.addSprite("rock",tiles.get(32,0,32,32));

  tileBatch.addSprite("snow",tiles.get(64,32,32,32));
  tileBatch.addSprite("water",tiles.get(0,64,32,32));
  tileBatch.addSprite("forest",tiles.get(32,64,32,32));
  //  ortho();
  ((PGraphicsOpenGL)g).textureSampling(2);
  
  
  
  Program p = new Program("x = 9\n PRINT(x)");
  p.runCycle();
  
}




TerrainTile [][] land;
String[][] biome;
int w,h;
float scale = 70,chaos, ruggedness = 3, biomeoffset;
float dryness = 0.25;

int seed1=0;
int seed2=0;
int seed3=0;
boolean randomized=true;
boolean showland=true;
boolean showheights=false;
boolean showores=false;

String folder="main";

JSONObject masterobj;
HashMap<String,TerrainType> terrainTypes = new HashMap();


PImage tiles;

long time=0;
//Every 
int suncycle=12000;


float cameraX,cameraY;
float camvx = 0,avx=0;
float camvy = 0,avy=0;
float zoom = 0.3;

float screenToWorldX(float sx){
  return sx/zoom+cameraX;
}
float screenToWorldY(float sy){
  return sy/zoom+cameraY;
}

void keyPressed(){

  if(key=='a'){
    camvx-=100;
  }
  else if(key=='d'){
    camvx+=100;
  }
  if(key=='w'){
    camvy=-100;
  }
  else if(key=='s'){
    camvy+=100;
  }
}

void keyReleased(){
  
  if(key=='a'){
    camvx+=100;
  }
  else if(key=='d'){
    camvx-=100;
  }
  
  if(key=='w'){
    camvy+=100;
  }
  else if(key=='s'){
    camvy-=100;
  }
  
  
}

void mouseWheel(MouseEvent event) {

  float e = event.getCount();
  float scalechange = (e<0)?1.1:0.9;
   
  if(zoom*scalechange<0.2){
    scalechange =1.0;
    zoom=0.2;
  }zoom*=scalechange;
  cameraX += (mouseX/zoom)*(scalechange-1.0);
  cameraY += (mouseY/zoom)*(scalechange-1.0);
  //ghandler.onMouseWheel(event.getCount());
}


void draw(){
  background(200);
  //image(output,0,0);
  
  
  cameraX +=avx;
  cameraY+=avy;
  
  avx += (camvx-avx)*0.1;
  avy += (camvy-avy)*0.1;
  
  
  
  //output = terrainToImage();
  noStroke();
  pushMatrix();
  scale(zoom);
  translate(-cameraX,-cameraY);
  
  
  TerrainTile t = getTile(screenToWorldX(mouseX)/32,screenToWorldY(mouseY)/32);
  float fr = getRatio(floor(screenToWorldX(mouseX)/32),floor(screenToWorldY(mouseY)/32),5,"forest");
  float ar = getRatio(floor(screenToWorldX(mouseX)/32),floor(screenToWorldY(mouseY)/32),5,"arid dirt");
  //
  tileBatch.reset();
  
  int minx = constrain(floor(screenToWorldX(0)/32),0,w-1);
  int maxx = constrain(floor(screenToWorldX(width+32)/32),0,w-1);
  int miny = constrain(floor(screenToWorldY(0)/32),0,h-1);
  int maxy = constrain(floor(screenToWorldY(height+32)/32),0,h-1);
  for (int i= minx; i<=maxx; i++)
  {
    for (int j=miny; j<=maxy; j++)
      
    {
      color c= lerpColor(color(255),color(0,0,30),(1.0-0.05*land[i][j].height));
      if(land[i][j]==t){
        c = #FF0000;
      }
      tileBatch.addDrawOrder(land[i][j].tp.name,i*32,j*32,32,32,c);
    }
  }
  //
  tileBatch.draw(g);
  stroke(255);
  beginShape(LINES);
  noFill();
  strokeCap(SQUARE);
  strokeWeight(1f/zoom);
  
  for (int i= minx; i<maxx; i++)
  {
    for (int j=miny; j<maxy; j++) 
    {
      if(biome[t.x][t.y]==biome[i][j]){
        stroke(255);
      }else{
        stroke(255,50);
      }
      if(j-1>0 && biome[i][j] != biome[i][j-1] ){
        vertex(i*32,j*32);
        vertex(i*32+32,j*32);
      }
      if(i-1>0 && biome[i][j] != biome[i-1][j] ){
        vertex(i*32,j*32);
        vertex(i*32,j*32+32);
      }
      if(i+1<w && biome[i][j] != biome[i+1][j] ){
        vertex(i*32+32,j*32);
        vertex(i*32+32,j*32+32);
      }
      if(j+1<h && biome[i][j] != biome[i][j+1] ){
        vertex(i*32,j*32+32);
        vertex(i*32+32,j*32+32);
      }
    }
  }
  endShape();
  
  popMatrix();
  
  fill(255);
  text(t.tp.name,20,20);
  text("moisture:"+t.moisture,20,40);
  text("soil:"+t.soilcover,20,60);
  text("height:"+t.height,20,80);
  text("temp:"+t.temp,20,100);
  text("biome:"+biome[t.x][t.y],20,130);
  
  text("forest ratio:"+fr,20,170);
  text("arid ratio:"+ar,20,190);
}
