TerrainType [][] land;
int w,h;
float scale,chaos, ruggedness, biomeoffset;

int seed1=0;
int seed2=0;
int seed3=0;
boolean randomized=true;
boolean showland=true;
boolean showheights=false;
boolean showores=false;

String folder="main";

JSONObject masterobj;

class TerrainType{
  color c;
  TerrainType(JSONObject o){
    c = color(o.getInt("red"),o.getInt("green"),o.getInt("blue"));
  }
  
  
}


void generate(int w,int h){
  this.w=w;
  this.h=h;
  land = new TerrainType[w][h];
  
  
  for (int i=0; i<land.length; i++)
    {
        for (int j=0; j<land[i].length; j++)
        {
            float noisevalue = noise(i*(1.0/scale),j*(1.0/scale))-biomeoffset;
            
            float noisevalue2 = noise(i*(1.0/scale)+200,j*(1.0/scale))-biomeoffset;
            //actuall terrain
            int at=0;
            
            
            
            if(noisevalue>0.9f){
              at=6;
            }else if(noisevalue>0.7f){
              at=1;
            }else if(noisevalue>0.6f){
              at=2;
            }else if(noisevalue>0.45f){
              at=1;
            }
            //if(heights[i][j]/MAXHEIGHT-terraintypeoffset<0.15f){
            //  at=4;
            //}else if(heights[i][j]/MAXHEIGHT-terraintypeoffset<0.18f){
            //  at=2;
            //}
            if(noisevalue2<0.1f){
              at=3;
            }
            if(at==2&&noisevalue2<0.3f){
              at=1;
            }
            
            if(noisevalue2>0.95f){
              at=6;
            }
            
            if(noisevalue2>0.6f&&noisevalue2<0.7f){
              at=4;
            }
            land[i][j]=new TerrainType(masterobj.getJSONObject("TerrainType_"+at));
            
        }
    }
}


void setup(){}
