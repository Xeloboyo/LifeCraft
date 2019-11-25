import peasy.*;
import peasy.org.apache.commons.math.*;
import peasy.org.apache.commons.math.geometry.*;
float toal = 0.0,toal2=0.0;
PImage output;
PeasyCam p;
SpriteBatch tileBatch;
void setup(){
  System.setProperty("user.dir","C:\\Users\\Maks\\Documents\\GitHub\\LifeCraft\\");
  sysdir=System.getProperty("user.dir");
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
  tileBatch = new SpriteBatch(20000);
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


class TerrainType{
  color c;
  String name;
  TerrainType(JSONObject o){
     c = color(o.getInt("red"),o.getInt("green"),o.getInt("blue"));
    name = o.getString("name");
  }
}
class TerrainTile{
  TerrainType tp;
  int x,y;
  float height;
  float moisture;
  float soilcover;
  int variant;
  float temp;
  TerrainTile(TerrainType init, int x,int y, float height,float moisture,float soilcover,float temp, int variant){
     tp = init;
    this.x=x;
    this.y=y;
    this.height=height;
    this.moisture = moisture;
    this.soilcover = soilcover;
    this.variant =variant;
    this.temp=temp;
  }
  
  float getDisplayHeight(){
    return height+moisture;
  }
  void assignToType(){
    if(tp.name.equals("dirt") && soilcover<1){
      tp = terrainTypes.get("rock");
    }
    if(tp.name.equals("rock") && soilcover>5){
      tp = terrainTypes.get("dirt");
    }
    if(tp.name.equals("sand")&&height>30){
      tp = terrainTypes.get("rock");
    }
    
    if(tp.name.equals("sand")&&moisture>0.3){
      moisture-=0.2;
      tp = terrainTypes.get("arid dirt");
    }
    if(tp.name.equals("water") && (moisture<0.3)){
      tp = terrainTypes.get("dirt");
    }
    if(tp.name.equals("sand") && (soilcover>10)){
      tp = terrainTypes.get("dirt");
    }
    
    if(tp.name.equals("dirt") &&(moisture<0.05)){
      tp = terrainTypes.get("arid dirt");
    }
    if(tp.name.equals("arid dirt") &&(moisture>0.08)){
      tp = terrainTypes.get("dirt");
    }
    if(moisture>0.3){
      tp = terrainTypes.get("water");
      if(temp<0){
        tp = terrainTypes.get("ice");
      }
    }else if(moisture>0.2){
      if(temp<0){
        tp = terrainTypes.get("snow");
      }
      
    }
    
    if(tp.name.equals("grass") && moisture<0.2&&moisture>0.1&&soilcover>5&&temp>0&&temp<30){
      tp = terrainTypes.get("forest");
    }
    
    if(tp.name.equals("grass") && (moisture<0.04||temp<0||temp>40)){
      tp = terrainTypes.get("arid dirt");
      moisture+=0.05;
    }
    
    if(moisture>0.05&&temp>0){
      if(tp.name.equals("dirt")){
        tp = terrainTypes.get("grass");
      }
    }
    
  }
  
  
}

TerrainTile getTile(float x,float y){
  return getTile(int(x),int(y));
}
TerrainTile getTile(int x,int y){
  return land[(x+w*10)%w][(y+h*10)%h];
}

void generate(int w,int h){
  this.w=w;
  this.h=h;
  land = new TerrainTile[w][h];
  biome = new String[w][h];
  //setting base terrain
  for (int i=0; i<land.length; i++)
    {
        for (int j=0; j<land[i].length; j++)
        {
            float noisevalue = noise(i*(1.0/scale),j*(1.0/scale))-biomeoffset;
            
            float noisevalue2 = noise(i*(1.0/scale)+200,j*(1.0/scale))-biomeoffset;
            //actuall terrain
            int at=0;
            
            
            
            if(noisevalue>0.9f){
              at=2;
            }else if(noisevalue>0.7f){
              at=5;
            }else if(noisevalue>0.4f){
              at=0;
            }else if(noisevalue>0.25f){
              at=2;
            }
            
            else if(noisevalue>0.2f){
              at=0;
            }
            //if(heights[i][j]/MAXHEIGHT-terraintypeoffset<0.15f){
            //  at=4;
            //}else if(heights[i][j]/MAXHEIGHT-terraintypeoffset<0.18f){
            //  at=2;
            //}
           
            /// height is mapped from 0 to 1.
            
            
            
            float height = ((pow(noise(i*(1.0/scale)+0.93,0.2+j*(1.0/scale)),4) )*ruggedness )*50+10 + 5*(noise(i*0.1/scale,j*0.1/scale))*(noise(i*(10.0/scale)+0.93,0.2+j*(10.0/scale))-0.5);
            
            float temperature = noise(i*(1.0/scale)-4.33,-3.5+j*(1.0/scale))*30.3 - (height-10)*0.6;
            
            
            float moisture = max(0,noise(i*(1.0/scale)-0.33,0.5+j*(1.0/scale)) -  dryness - ((height-10)*0.003*noise(i*0.3/scale+0.6,j*0.3/scale)));
            float soilcover = max(0,noise(i*(1.0/scale)-0.33,-0.5+j*(1.0/scale))*20.3 - (height-10)*0.4);
            
            
            
            land[i][j]=new TerrainTile(new TerrainType(masterobj.getJSONObject("TerrainType_"+at)),i,j, height,  moisture, soilcover,temperature,(int)random(20));
            
        }
    }
    //stabilising water & large scale erosion
    int steps = 300;
    
    println("stablising water");
    for (int z=0; z<steps; z++){
      settleWater();
    }  
     println("reseting types");
    reassignAll();
}
void reassignAll(){
  for (int i=0; i<land.length; i++)
    {
        for (int j=0; j<land[i].length; j++)
        {
          land[i][j].assignToType();
        }
      }
}
void erode(){
  int steps = 50;
  float px = random(w),py = random(h);
  float water=2;
  float speed =0;
  float vx=0,vy=0;
  float soil = 0.0;
  float net=0;
  float pheight = getTile(px-1,py).height * (1 - px%1) * (1 - py%1) +getTile(px+1,py).height * px%1 * (1 - py%1) + getTile(px-1,py+1).height * (1 - px%1) * py%1 + getTile(px+1,py+1).height * px%1 * py%1;
  for (int z=0; z<steps; z++){
    float xdir = getTile(px+1,py).height - getTile(px-1,py).height;
    float ydir =  getTile(px,py+1).height - getTile(px,py-1).height;
    
    speed = dist(0,0,vx,vy)+0.001;
   
    TerrainTile tt  = getTile(px,py);
     px-=vx/speed;
    py-=vy/speed;
    float nheight = getTile(px-1,py).height * (1 - px%1) * (1 - py%1) +getTile(px+1,py).height * px%1 * (1 - py%1) + getTile(px-1,py+1).height * (1 - px%1) * py%1 + getTile(px+1,py+1).height * px%1 * py%1;
    float dheight = nheight - pheight ;
    pheight=nheight;
     float cap = max(dheight*speed*water*0.2,0.5);;
    if(dheight>0){
      speed-=dheight;
    }
    if(soil>cap || dheight>0){
      //println(soil,cap);
      float soildep = 0.1*(dheight>0?min(soil,dheight*0.01):min(-dheight,(soil-cap)*0.2));
      for (int i=-1; i<=1; i++)
      {
        for (int j=-1; j<=1; j++)
        {
          float t = dist(i,j,0,0)+0.2;
          t=1f/t;
          tt.soilcover +=soildep*t/toal2;
           tt.height += soildep*t/toal2;
        }
      }
      
     net+=soildep;
     
      soil -=soildep;
      
    }
    //getTile(px,py).tp = terrainTypes.get("swamp");

    float rcap = min(min(max(0,dheight),getTile(px,py).soilcover),max(0,0.1*(cap-soil)));
    //if(z<5)
    //println(dheight);
    rcap = max(rcap,0);
    float accum = 0;
    
    
    for (int i=-3; i<=3; i++)
      {
        for (int j=-3; j<=3; j++)
        {
          float t = dist(i,j,0,0)+0.5;
          t=1f/t;
          float take = min(getTile(px+i,py+j).soilcover,rcap*t/toal);
          getTile(px+i,py+j).soilcover -=take;
           getTile(px+i,py+j).height -= take;
          accum += take;
        }
      }
    
   soil+=accum;
   
   if(z!=0){
    
   }
    
    vx+=xdir;
    vy+=ydir;
    
    vx*=0.9;
    vy*=0.9;
    water*=0.9;
    
  }
  if(soil>0){
    float soildep = soil*0.1;
    getTile(px,py).soilcover +=soildep;
     getTile(px,py).height += soildep;
  }
  
}
void settleWater(){
  float[][] newheight = new float[w][h],newwater = new float[w][h];
  for (int i=1; i<land.length-1; i++)
      {
        for (int j=1; j<land[i].length-1; j++)
        {
          //maximum runoff moisture
          float maxamount = lerp(sqrt(max(0,land[i][j].moisture-0.15)),land[i][j].moisture,0.5)*0.25;
          
          
          float xwdirleft = max(0,getTile(i,j).height+land[i][j].moisture - (getTile(i-1,j).height+getTile(i-1,j).moisture));
          float xwdirright = max(0,land[i][j].height+land[i][j].moisture - (land[i+1][j].height+land[i+1][j].moisture));
          float ywdirup = max(0,land[i][j].height+land[i][j].moisture - (land[i][j-1].height+land[i][j-1].moisture));
          float ywdirdown = max(0,land[i][j].height+land[i][j].moisture - (land[i][j+1].height+land[i][j+1].moisture));
          
          
          float xdirleft = max(0,land[i][j].height - getTile(i-1,j).height);
          float xdirright = max(0,land[i][j].height - land[i+1][j].height);
          float ydirup = max(0,land[i][j].height - land[i][j-1].height);
          float ydirdown = max(0,land[i][j].height - land[i][j+1].height);
          
          float maxerosion = 1.0;
          float total2 = xdirleft+xdirright+ydirup+ydirdown;
          float min2 = min(xdirleft,min(xdirright,min(ydirup,ydirdown)));
          //less soil, less erosion
          maxerosion *= (max(0.9,land[i][j].soilcover*0.1)+0.1 )*min2;
          
          float total = xwdirleft+xwdirright+ywdirup+ywdirdown;
          
          
          
          float flowoff = min(1.0,total*0.175);
          maxamount *= flowoff;
          maxerosion *= flowoff;
          newwater[i][j] += land[i][j].moisture-maxamount;
          if(total!=0){
              newwater[i-1][j] += maxamount*xwdirleft/total;
              newwater[i+1][j] += maxamount*xwdirright/total;
              newwater[i][j-1] += maxamount*ywdirup/total;
              newwater[i][j+1] += maxamount*ywdirdown/total;
          }
          
          
          
          newheight[i][j] +=land[i][j].height- (min2*maxerosion);
          
          if(total<=0||Float.isNaN(maxerosion)){
            newheight[i][j] =land[i][j].height;
            continue;
          }
          //println(min(total2,total*maxerosion));
          
          newheight[i-1][j] += xwdirleft/total*maxerosion;
          newheight[i+1][j] += xwdirright/total*maxerosion;
          newheight[i][j-1] += ywdirup/total*maxerosion;
          newheight[i][j+1] += ywdirdown/total*maxerosion;
          //println((min2*xdirleft/total2)*maxerosion);
          
        }
      }
      for (int i=0; i<land.length; i++)
      {
        for (int j=0; j<land[i].length; j++)
        {
          land[i][j].moisture =  newwater[i][j];
          newwater[i][j] = 0;
          
          float f = land[i][j].height-newheight[i][j];
          if(f<0){
            land[i][j].soilcover-=f;
            if(land[i][j].soilcover<0){
              land[i][j].soilcover=0;
            }
          }
          if(Float.isNaN( land[i][j].moisture)|| land[i][j].moisture<0){
             land[i][j].moisture = 0;
            }
            if(Float.isNaN( land[i][j].soilcover)|| land[i][j].soilcover<0){
             land[i][j].soilcover = 0;
            }
          
          land[i][j].height=newheight[i][j];
          if(land[i][j].height<0||Float.isNaN(land[i][j].height)){
            land[i][j].height=0;
          }
          newheight[i][j] = 0;
        }
      }
}




PImage terrainToImage(){
  PGraphics pg = createGraphics(w,h);
  pg.beginDraw();
  pg.loadPixels();
  for (int i=0; i<land.length; i++)
  {
    for (int j=0; j<land[i].length; j++)
    {
      pg.pixels[i+j*w] = lerpColor(land[i][j].tp.c,color(0,0,30),0.5*(1.0-land[i][j].height));
    }
  }
  pg.updatePixels();
  pg.endDraw();
  return pg;
}

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
  
  
  reassignAll();
  //output = terrainToImage();
  noStroke();
  pushMatrix();
  scale(zoom);
  translate(-cameraX,-cameraY);
  
  
  TerrainTile t = getTile(screenToWorldX(mouseX)/32,screenToWorldY(mouseY)/32);
  
  //beginShape(QUADS);
  tileBatch.reset();
  for (int i=constrain(floor(screenToWorldX(0)/32),0,w-1); i<constrain(floor(screenToWorldX(width+32)/32),0,w-1); i++)
  {
    for (int j=constrain(floor(screenToWorldY(0)/32),0,h-1); j<constrain(floor(screenToWorldY(height+32)/32),0,h-1); j++)
      
    {
      color c= lerpColor(color(255),color(0,0,30),(1.0-0.05*land[i][j].height));
      if(land[i][j]==t){
        c = #FF0000;
      }
      tileBatch.addDrawOrder(land[i][j].tp.name,i*32,j*32,32,32,c);
    }
  }
  //endShape();
  tileBatch.draw(g);
  popMatrix();
  
  fill(255);
  text(t.tp.name,20,20);
  text("moisture:"+t.moisture,20,40);
  text("soil:"+t.soilcover,20,60);
  text("height:"+t.height,20,80);
  text("temp:"+t.temp,20,100);
}
