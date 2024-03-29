
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
    
    if(tp.name.equals("dirt") &&(moisture<0.01)){
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
    if(tp.name.equals("forest") && (moisture<=0.1||temp<0||temp>30)){
      tp = terrainTypes.get("grass");
      moisture+=0.05;
    }
    if(tp.name.equals("grass") && (moisture<0.04||temp<0||temp>40)){
      tp = terrainTypes.get("arid dirt");
      moisture+=0.05;
    }
    
    if(moisture>0.02&&temp>0){
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
  println("setting base terrain");
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
    int steps = 30;
    
    
    for (int z=0; z<steps; z++){
      println("stablising climate: "+nf(100*z/steps,0,2)+"%");
      for (int i=0; i<10; i++){
        settleWater();
        
      }
      for(int i =0;i<2;i++){
        EvolveLandscape();
      }
      reassignAll();
    }  
    
    println("checking biomes");
    analyseBiome();
    println("filling gaps");
    forceBiomeBoundaries();
    println("checking static biomes");
    analyseStaticBiome();
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

void EvolveLandscape(){
  for (int i=1; i<land.length-1; i++)
  {
    for (int j=1; j<land[i].length-1; j++)
    {
      float water = getRatio(i,j,1,"water");
      float forest = getRatio(i,j,1,"forest");
      float grass = getRatio(i,j,1,"grass");
      float sand = getRatio(i,j,1,"sand");
      if(water>0&&sand>0.0&&forest<0.3&&(!land[i][j].tp.name.equals("water"))){
        land[i][j].tp = terrainTypes.get("sand");
      }
      if(forest>0.3&&(land[i][j].tp.name.equals("sand"))){
        land[i][j].tp = terrainTypes.get("arid dirt");
        land[i][j].moisture*=0.7;
      }
      if(grass>0.7&&(land[i][j].tp.name.equals("sand"))){
        land[i][j].tp = terrainTypes.get("arid dirt");
        land[i][j].moisture*=0.7;
      }
    }
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



float getRatio(int x,int y,int r,String type){
  float count=0;
  for (int i=x-r; i<=x+r; i++)
  {
    for (int j=y-r; j<=y+r; j++)
    {
      count+=getTile(i,j).tp.name.equals(type)?1:0;
    }
  }
  return count/sqrd(2*r+1);
}

//just a float wrapper lmao
class Count{int c=0; void inc(){c++;}}
void forceBiomeBoundaries(){
  
  HashMap<String,Count> biomes;
  biomes = new HashMap();
  int supercount = 1;
  while(supercount>0){
    supercount = 0;
    String[][] newbiome = new String[w][h];
    for (int i=0; i<land.length; i++)
    {
      for (int j=0; j<land[i].length; j++)
      {
        for(String s:biomes.keySet()){
          biomes.get(s).c=0;
        }
        int atotal = 0;
        int acount = 0;
        for (int a=max(0,i-1); a<=min(w-1,i+1); a++)
        {
          for (int b=max(0,j-1); b<=min(h-1,j+1); b++)
          {
            if(biome[a][b]!="none"&&biome[i][j]!=null){
              if(!biomes.containsKey(biome[a][b])){
                biomes.put(biome[a][b], new Count());
              }
              biomes.get(biome[a][b]).inc();
              acount++;
            }
            atotal++;
          }
        }
        int maxcount=-1;
        String biomehigh="";
        if((biome[i][j]=="none"||biome[i][j]==null)&&acount>0){
          for(String s:biomes.keySet()){
            if(biomes.get(s).c>maxcount){
              biomehigh = s;
              maxcount = biomes.get(s).c;
            }
          }
          newbiome[i][j] = biomehigh;
        }else{
          newbiome[i][j] = biome[i][j]==null?"none":biome[i][j];
        }
        
        supercount+=(atotal-acount);
      }
    }
    biome = newbiome;
    println(supercount);
  }
}
void analyseBiome(){
  for (int i=0; i<land.length; i++)
  {
    for (int j=0; j<land[i].length; j++)
    {
      TerrainTile tt = land[i][j];
      biome[i][j] = "none";
      
      float grass = getRatio(i,j,5,"grass");
      float sand = getRatio(i,j,5,"sand");
      float rock = getRatio(i,j,5,"rock");
      float snow = getRatio(i,j,5,"snow");
      float water = getRatio(i,j,5,"water");
      float forest = getRatio(i,j,5,"forest");
      float drydirt = getRatio(i,j,5,"arid dirt");
      
      
        if(sand>0.65){
          biome[i][j] = "desert";
          if(water>0.0&&getRatio(i,j,1,"grass")>0){
            biome[i][j] = "oasis";
          }
        }
        
        
        if(forest>0.3&&water<0.3){
          biome[i][j] = "forest";
        }
        else if(grass>0.55){
          biome[i][j] = "grassland";
        }else if(water>0.2 && forest+grass+water>0.8 && sand<0.1){
          biome[i][j] = "wetland";
        }
        
        if(drydirt>0.7){
          biome[i][j] = "arid flats";
        }
        
      
      
      
      if(land[i][j].tp.name.equals("rock")){
        if(water>0.3){
          biome[i][j] = "crags";
        }
        
      }
      
      if(tt.height>30&&rock+snow>0.2){
        
        biome[i][j] = "mountains";
      }
      
    }
  }
}


void analyseStaticBiome(){
  for (int i=0; i<land.length; i++)
  {
    for (int j=0; j<land[i].length; j++)
    {
      TerrainTile tt = land[i][j];
      float water = getRatio(i,j,5,"water");
      float ice = getRatio(i,j,3,"ice");
      if(tt.height>20&&land[i][j].tp.name.equals("ice") || ice>0.3){
        
        biome[i][j] = "glacier";
      }
      
      if(land[i][j].tp.name.equals("water")){
        if(water>0.9){
          biome[i][j] = "deepwater";
        }
        else {
          biome[i][j] = "shallowwater";
        }
      }
      if(water>0.35&&land[i][j].tp.name.equals("sand")){
        biome[i][j] = "beach";
      }
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
