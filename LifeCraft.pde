import peasy.*;
import peasy.org.apache.commons.math.*;
import peasy.org.apache.commons.math.geometry.*;

TerrainTile [][] land;
int w,h;
float scale = 50,chaos, ruggedness = 1.2, biomeoffset;
float dryness = 0.35;

int seed1=0;
int seed2=0;
int seed3=0;
boolean randomized=true;
boolean showland=true;
boolean showheights=false;
boolean showores=false;


JSONObject masterobj;
HashMap<String,TerrainType> terrainTypes = new HashMap();



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
  TerrainTile(TerrainType init, int x,int y, float height,float moisture,float soilcover){
     tp = init;
    this.x=x;
    this.y=y;
    this.height=height;
    this.moisture = moisture;
    this.soilcover = soilcover;
  }
  
  float getDisplayHeight(){
    return height+moisture;
  }
  void assignToType(){
    if(tp.name.equals("dirt") && soilcover<0.02){
      tp = terrainTypes.get("rock");
    }
    if(tp.name.equals("rock") && soilcover>0.02){
      tp = terrainTypes.get("dirt");
    }
    
    if(tp.name.equals("sand") && soilcover>0.1){
      tp = terrainTypes.get("dirt");
    }
    if(moisture>0.3){
      tp = terrainTypes.get("water");
    }else if(moisture>0.2){
      if(height>0.7){
        tp = terrainTypes.get("snow");
      }
      
    }
    
    if(moisture>0.05){
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
  return land[(x+w)%w][(y+h)%h];
}

void generate(int w,int h){
  this.w=w;
  this.h=h;
  land = new TerrainTile[w][h];
  
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
            float height = ((noise(i*(1.0/scale)+0.93,0.2+j*(1.0/scale)) - 0.5)*ruggedness +0.5)*50;
            float moisture = max(0,noise(i*(1.0/scale)-0.33,0.5+j*(1.0/scale)) -  dryness);
            float soilcover = noise(i*(1.0/scale)-0.33,-0.5+j*(1.0/scale))*20.3;
            land[i][j]=new TerrainTile(new TerrainType(masterobj.getJSONObject("TerrainType_"+at)),i,j, height,  moisture, soilcover);
            
        }
    }
    //stabilising water & large scale erosion
    int steps = 1;
    
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
  float water=50;
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
      float soildep = soil*0.01*(dheight>0?min(1.0,dheight*0.01):1.0);
      tt.soilcover +=soildep;
     tt.height += soildep;
     net+=soildep;
     
      soil -=soildep;
      
    }
    //getTile(px,py).tp = terrainTypes.get("swamp");

    float rcap = min(min(max(0,dheight),getTile(px,py).soilcover),0.1*(cap-soil));
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
    
    vx+=xdir/(speed+1.0);
    vy+=ydir/(speed+1.0);
    
    //vx*=0.98;
    //vy*=0.98;
    water*=0.95;
    
  }
  if(soil>0){
    float soildep = soil*0.05;
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
          float maxamount = lerp(sqrt(max(0,land[i][j].moisture-0.15)),land[i][j].moisture,1.0-land[i][j].soilcover)*0.25;
          
          
          float xwdirleft = max(0,land[i][j].height+land[i][j].moisture - (land[i-1][j].height+land[i-1][j].moisture));
          float xwdirright = max(0,land[i][j].height+land[i][j].moisture - (land[i+1][j].height+land[i+1][j].moisture));
          float ywdirup = max(0,land[i][j].height+land[i][j].moisture - (land[i][j-1].height+land[i][j-1].moisture));
          float ywdirdown = max(0,land[i][j].height+land[i][j].moisture - (land[i][j+1].height+land[i][j+1].moisture));
          
          
          float xdirleft = max(0,land[i][j].height - land[i-1][j].height);
          float xdirright = max(0,land[i][j].height - land[i+1][j].height);
          float ydirup = max(0,land[i][j].height - land[i][j-1].height);
          float ydirdown = max(0,land[i][j].height - land[i][j+1].height);
          
          float maxerosion = 1.0;
          float total2 = xdirleft+xdirright+ydirup+ydirdown;
          float min2 = min(xdirleft,min(xdirright,min(ydirup,ydirdown)));
          //less soil, less erosion
          maxerosion *= (max(0.9,land[i][j].soilcover*10.0)+0.1 )*min2;
          
          float total = xwdirleft+xwdirright+ywdirup+ywdirdown;
          
          
          
          float flowoff = min(1.0,total*0.75);
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


float toal = 0.0;
PImage output;
PeasyCam p;
void setup(){
  for (int i=-3; i<=3; i++)
      {
        for (int j=-3; j<=3; j++)
        
        {
          toal+=1f/(dist(i,j,0,0)+0.5);
        }
      }
  masterobj = parseJSONObject(fileToString("masterContent.txt"));
  int types = masterobj.getInt("terrainTypes");
  for(int i = 0;i<types;i++){
    JSONObject ttype = masterobj.getJSONObject("TerrainType_"+i);
    terrainTypes.put(ttype.getString("name"),new TerrainType(ttype));
  }
  generate(400,200);
  size(1000,500,P3D);
  output = terrainToImage();
  p  = new PeasyCam(this, 400);
    
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

void draw(){
  background(200);
  //image(output,0,0);
  for(int i =0 ;i<5;i++){
    //settleWater();
    for(int z =0;z<10;z++){
      erode();
    }
  }
  
  
  reassignAll();
  //output = terrainToImage();
  noStroke();
  translate(-w/2,-h/2);
  directionalLight(255,255,255, -1, 1, -0.5);
  directionalLight(255,255,255, -1, 1, -0.52);
  ambientLight(40,100,130);
  beginShape(QUADS);
  for (int i=0; i<land.length-1; i++)
  {
    for (int j=0; j<land[i].length-1; j++)
      
    {
      fill(lerpColor(land[i][j].tp.c,color(0,0,30),(1.0-land[i][j].height)));
      vertex(i,j,land[i][j].getDisplayHeight());
      vertex(i+1,j,land[i+1][j].getDisplayHeight());
      vertex(i+1,1+j,land[i+1][j+1].getDisplayHeight());
      vertex(i,1+j,land[i][j+1].getDisplayHeight());
    }
  }
  endShape();
}
