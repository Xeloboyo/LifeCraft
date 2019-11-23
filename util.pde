


//draws a bunch of sprites with a single draw call for efficentcy sake
class SpriteBatch{
  PGraphics atlas;int w,h;
  
  int csize = 0;
  int maxsize = 1024;
  int[][] queue = new int[maxsize][6];// 0 - id, 1 - x, 2 - y, 3- w, 4- h
  IntDict altasids = new IntDict();
  ArrayList<IntVec> altasDict = new ArrayList();
  ArrayList<IntVec> altasSizeDict = new ArrayList();
  SpriteBatch(int maxSize){
    maxsize = maxSize;
    queue = new int[maxsize][6];
    init();
  }
  
  SpriteBatch(){
    init();
  }
  
  void init(){
    atlas = createGraphics(512,512);
    w=h=512;
  }
  
  void reset(){
    csize = 0;
  }
  boolean touches(int x,int y,int w,int h,int sprite){
    IntVec iv = altasDict.get(sprite);
    IntVec dim = altasSizeDict.get(sprite);
    return isTouching(x,y,x+w,y+h,iv.x,iv.y,dim.x+iv.x,dim.y+iv.y);
  }
  boolean isSpaceFree(int x,int y,int w,int h){
    if(altasDict.isEmpty()){return true;}
    for(int i = 0;i<altasDict.size();i++){
      if(touches(x,y,w,h,i)){
        return false;
      }
    }
    
    return !(x<0||y<0||x+w>this.w||y+h>this.h);
  }
  void addSprite(String name, PImage pg){
    if(altasids.hasKey(name)){return;}
    IntVec pos = new IntVec(0,0);
    if(!isSpaceFree(0,0,pg.width,pg.height)){
      boolean found = false;
      while(!found){
        for(int i = 0;i<altasDict.size();i++){
          IntVec iv = altasDict.get(i);
          IntVec dim = altasSizeDict.get(i);
          if(isSpaceFree(iv.x+dim.x+1,iv.y,pg.width,pg.height)){
            pos.set(iv.x+dim.x+1,iv.y); 
            found =true;
            break;
          }
          if(isSpaceFree(iv.x,iv.y+dim.y+1,pg.width,pg.height)){
            pos.set(iv.x,iv.y+dim.y+1); 
            found =true;
            break;
          }
          
        }
        if(!found){
          PGraphics newBuffer;
          if(w>h){
            newBuffer = createGraphics(w,h*2);
            h*=2;
          }else{
            newBuffer = createGraphics(w*2,h);
            w*=2;
          }
          newBuffer.beginDraw();
          newBuffer.clear();
          newBuffer.image(atlas,0,0);
          newBuffer.endDraw();
          
          atlas = newBuffer;
        }
      }
    }
    atlas.beginDraw();
    atlas.image(pg,pos.x,pos.y);
    atlas.endDraw();
    altasids.add(name,altasDict.size());
    altasDict.add(pos);
    altasSizeDict.add(new IntVec(pg.width,pg.height));
    
  }
  
  void addDrawOrder(String sprite,int x,int y){
    queue[csize][0] = altasids.get(sprite);
    queue[csize][1] = x;
    queue[csize][2] = y;
    queue[csize][3] = altasSizeDict.get(queue[csize][0]).x;
    queue[csize][4] = altasSizeDict.get(queue[csize][0]).y;
    queue[csize][5] = color(255);
    csize++;
  }
  void addDrawOrder(String sprite,int x,int y,int w,int h){
    queue[csize][0] = altasids.get(sprite);
    queue[csize][1] = x;
    queue[csize][2] = y;
    queue[csize][3] = w;
    queue[csize][4] = h;
    queue[csize][5] = color(255);
    csize++;
  }
  void addDrawOrder(String sprite,int x,int y,int w,int h,int col){
    queue[csize][0] = altasids.get(sprite);
    queue[csize][1] = x;
    queue[csize][2] = y;
    queue[csize][3] = w;
    queue[csize][4] = h;
    queue[csize][5] = col;
    csize++;
  }
  
  void draw(PGraphics buffer){
    buffer.fill(255);
    buffer.noStroke();
    if(csize==0){return;}
    buffer.beginShape(QUADS);
    buffer.texture(atlas);
    IntVec tl,dim;
    int fullc = color(255);
    for(int i = 0;i<csize;i++){
      if(queue[i][5]!=fullc){
        buffer.tint(queue[i][5]);
      }
      tl = altasDict.get(queue[i][0]);
      dim = altasSizeDict.get(queue[i][0]);
      buffer.vertex(queue[i][1],              queue[i][2],              tl.x,        tl.y);
      buffer.vertex(queue[i][1]+queue[i][3],  queue[i][2],              tl.x+dim.x,  tl.y);
      buffer.vertex(queue[i][1]+queue[i][3],  queue[i][2]+queue[i][4],  tl.x+dim.x,  tl.y+dim.y);
      buffer.vertex(queue[i][1],              queue[i][2]+queue[i][4],  tl.x,        tl.y+dim.y);
      if(queue[i][5]!=fullc){
        buffer.noTint();
      }
    }
    buffer.endShape();
  }
  
  
  PImage getSingle(String spriteid){
    int sprite = altasids.get(spriteid);
     return  getSingle(sprite);
  }
  PImage getSingle(int sprite){
    
    IntVec tl,dim;
    tl = altasDict.get(sprite);
      dim = altasSizeDict.get(sprite);
     return  atlas.get( tl.x,        tl.y,dim.x,dim.y);

  }
   void drawSingle(int sprite, float x,float y,PGraphics buffer){
    buffer.fill(255);
    buffer.noStroke();
    if(csize==0){return;}
    buffer.beginShape(QUADS);
    buffer.texture(atlas);
    IntVec tl,dim;
    tl = altasDict.get(sprite);
      dim = altasSizeDict.get(sprite);
    buffer.vertex(x,        y,              tl.x,        tl.y);
    buffer.vertex(x+dim.x,  y,              tl.x+dim.x,  tl.y);
    buffer.vertex(x+dim.x,  y+dim.y,  tl.x+dim.x,  tl.y+dim.y);
    buffer.vertex(x,        y+dim.y,  tl.x,        tl.y+dim.y);
    buffer.endShape();
  } 
  void drawSingle(int sprite, float x,float y,float w,float h, PGraphics buffer){
    buffer.fill(255);
    buffer.noStroke();
    if(csize==0){return;}
    buffer.beginShape(QUADS);
    buffer.texture(atlas);
    IntVec tl,dim;
    tl = altasDict.get(sprite);
      dim = altasSizeDict.get(sprite);
    buffer.vertex(x,    y,              tl.x,        tl.y);
    buffer.vertex(x+w,  y,              tl.x+dim.x,  tl.y);
    buffer.vertex(x+w,  y+h,  tl.x+dim.x,  tl.y+dim.y);
    buffer.vertex(x,    y+h,  tl.x,        tl.y+dim.y);
    buffer.endShape();
  }
  

}




String replaceAll(String regex,String replaceWith,String input){
  String st = "";
  for(int i = 0;i<input.length();i++){
    if(i+regex.length()<=input.length()&&regex.equals(input.substring(i,i+regex.length()))){
      
      st+=replaceWith;
      i+=regex.length()-1;
    }else{
      st+=input.charAt(i);
    }
    
  }
  return st;
}
File StringToFile(String s,String fname){
  PrintWriter pr = createWriter("data/tempShader/"+fname);
  
  pr.println(s);
  pr.flush();
  pr.close();
  
  return new File(dataPath("data/tempShader/"+fname));

}
String fileToString(String file){
  BufferedReader br = createReader(file);
  String out="";
  try{
    String p="";
    
    while((p=br.readLine())!=null){
      out+=p+"\n";
    }
    out=out.substring(0,out.length()-1);
    br.close();
  }catch(Exception e){}
  
  return out;

}

boolean isTouching(float qx,float qy,float qx2,float qy2,float gx,float gy,float gx2,float  gy2){
  return (!(gx2<=qx||gy2<=qy||gx>=qx2||gy>=qy2));
}
boolean isTouchingwh(float qx,float qy,float qx2,float qy2,float gx,float gy,float gx2,float  gy2){
  return isTouching(qx,qy,qx+qx2,qy+qy2, gx,gy,gx+gx2,gy+gy2);
}

void drawSprite(PGraphics pg,PImage currentTexture,int tx,int ty,int tw,int th,float x,float y,float w,float h){
  pg.noStroke();
  pg.beginShape(QUADS);
  pg.texture(currentTexture);
  pg.vertex(x,   y,   tx,    ty);
  pg.vertex(x+w, y,   tx+tw, ty);
  pg.vertex(x+w, y+h, tx+tw, ty+th);
  pg.vertex(x,   y+h, tx,    ty+th);
  pg.endShape();
}

File[] getAllFiles(String folder){
  File foldere = new File(dataPath(folder));
  return foldere.listFiles();
}

int gfloor(float coord,int gsize){
  return floor(coord/gsize)*gsize;
} 
float sqrd(float x){
      return (x*x);
  }
  float distsqrd(float x,float y,float x2,float y2){
      return sqrd(x-x2)+sqrd(y-y2);
  }
  
class IntVec{
  int x,y;
  IntVec(int x,int y){
    this.x=x;
    this.y=y;
  }
  @Override
  public boolean equals(Object o){
    if(o instanceof IntVec){
      return equals((IntVec)o);
    }
    return false;
  }
  
  boolean equals(IntVec o){
    return x==o.x&&o.y==y;
  }
  
  void set(int x,int y){
    this.x=x;
    this.y=y;
  }
  
  @Override
  public int hashCode() {
    return (x<<16)^y;
  }
}
float nDot(float x,float y,float x2,float y2){
  float d1 = sqrt(x*x+y*y);
  float d2 = sqrt(x2*x2+y2*y2);
  return (x*x2 + y*y2)/(d1*d2); 
}
boolean between(float x,float min,float max){
  return x>=min&&x<=max;
}
float sdBox( float px,float py, float bx,float by )
{
  PVector d = new PVector(abs(px) - bx,abs(py)-by);
  return min(max(d.x,d.y),0.0) + dist(max(0,d.x),max(0,d.y),0.0,0.0);
}
