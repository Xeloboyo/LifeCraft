


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
    if(!altasids.hasKey(sprite)){
      return;
    }
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
    if(!altasids.hasKey(sprite)){
      return;
    }
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

String[] splitofSameLevel(String input, String begin, String terminator, String delim) {
  return splitofSameLevel(input,begin, terminator,delim, false, false);
}

HashMap<String,String[]> splitCache = new HashMap();
String[] cachedSplitofSameLevel(String input, String begin, String terminator, String delim, boolean includeGrouping, boolean quotations) {
  String key = input+begin+terminator+delim+includeGrouping+quotations;
  if(splitCache.containsKey(key)){
    return splitCache.get(key);
  }
  String []res = splitofSameLevel(input, begin, terminator, delim, includeGrouping, quotations);
  splitCache.put(key,res);
  return res;
}

String[] cachedMultiSplitofSameLevel(String input, String begin, String terminator, String delim, boolean includeGrouping, boolean quotations) {
  String key = input+begin+"||"+terminator+delim+includeGrouping+quotations;
  if(splitCache.containsKey(key)){
    return splitCache.get(key);
  }
  String []res = multiSplitofSameLevel(input, begin, terminator, delim, includeGrouping, quotations);
  splitCache.put(key,res);
  return res;
}

//includes the query
String readForCharOnSameLevel(String input, String begin, String terminator,char search, int start,int direction){
  int[] depth = multiSplitDepth(input,begin,terminator,0);
  int beginLevel = depth[start];
  String out = "";
  for(int i = start;i<input.length()&&i>=0;i+=direction){
    out=direction>0?out+input.charAt(i):input.charAt(i)+out;
    if(input.charAt(i)==search&&depth[i]==beginLevel){
      break;
    }
  }
  return out;
}
  int multiSplitSectors(String input, String begin, String terminator,int level) {
    int[] depth = multiSplitDepth(input,begin,terminator,1);
    boolean inTarget = false;
    int sectors = 0;
    for(int i = 0;i<input.length();i++){
      if(depth[i]==level&&!inTarget){
        sectors++;
        inTarget=true;
      }else if(depth[i]!=level&&inTarget){
        inTarget=false;
      }
    }
    return sectors;
  }
int[] multiSplitDepth(String input, String begin, String terminator, int offset) {
  int level = 0;
  //input=" "+input;
  boolean inQuotes = false;
  int[] depth = new int[input.length()];
  boolean useGrouping = !(begin.length()==0||terminator.length()==0);
  for (int i =-1; i<input.length(); i++) {
    if(i>=0){
      depth[i]=level;
    }
    if(i>=0&&input.charAt(i)=='"'){
      inQuotes=!inQuotes;
    }
    boolean g = false;
    do{
      g = false;
    if(useGrouping ){
      for(int z = 0;z<begin.length();z++){
        if (i<input.length()-1&& //prevent outofbounds
          input.charAt(i+1)==(begin.charAt(z))) {
          level++;
          i++;
          depth[i] = level-1+offset;
          g=true;
    
        }
      }
      for(int z = 0;z<terminator.length();z++){
        if (i<input.length()-1&& 
          input.charAt(i+1)==(terminator.charAt(z))) {
            
          level--;
          i++;
          depth[i] = level+offset;
          g=true;
        }
      }
    }
    
    }while(g);
  }
  return depth;
}

String[] multiSplitofSameLevel(String input, String begin, String terminator, String delim, boolean includeGrouping, boolean quotations) {
  StringBuilder out=new StringBuilder();
  int level = 0;
  input=" "+input;
  ArrayList<String> output = new ArrayList();
  boolean inQuotes = false;
  boolean useGrouping = !(begin.length()==0||terminator.length()==0);
  for (int i =-1; i<input.length(); i++) {
    if(i>=0){
      out.append(input.charAt(i));
    }
    if(i>=0&&quotations&&input.charAt(i)=='"'){
      inQuotes=!inQuotes;
    }
    boolean g = false;
    do{
      g = false;
    if(useGrouping ){
      for(int z = 0;z<begin.length();z++){
        if (i<input.length()-1&& //prevent outofbounds
          input.charAt(i+1)==(begin.charAt(z))) {
          level++;
          if(level==1){
            if(includeGrouping){
              out.append(input.charAt(i+1));
            }
            i++;
          }else{
            continue;
          }
          g=true;
    
        }
      }
      for(int z = 0;z<begin.length();z++){
        if (i<input.length()-1&& 
          input.charAt(i+1)==(terminator.charAt(z))) {
          level--;
          if(level==0){
            if(includeGrouping){
              out.append(input.charAt(i+1));
            }
            i++;
            
          }else{
            continue;
          }
          g=true;
        }
      }
    }
    if ((!inQuotes&&quotations)&&i<input.length()-delim.length()&& 
      input.substring(i+1, i+1+delim.length()).equals(delim)) {
      if(level==0){
        i+=delim.length();
        output.add(out.toString());
        out.setLength(0);
        g=true;
      }
     
    }
    }while(g);
  }
  output.add(out.toString());
  return output.toArray(new String[]{});
}
String[] splitofSameLevel(String input, String begin, String terminator, String delim, boolean includeGrouping, boolean quotations) {
  StringBuilder out=new StringBuilder();
  int level = 0;
  input=" "+input;
  ArrayList<String> output = new ArrayList();
  boolean inQuotes = false;
  boolean useGrouping = !(begin.length()==0||terminator.length()==0);
  for (int i =-1; i<input.length(); i++) {
    if(i>=0){
      out.append(input.charAt(i));
    }
    if(i>=0&&quotations&&input.charAt(i)=='"'){
      inQuotes=!inQuotes;
    }
    boolean g = false;
    do{
      g = false;
    if(useGrouping ){
      if (i<input.length()-begin.length()&& //prevent outofbounds
        input.substring(i+1, i+1+begin.length()).equals(begin)) {
        level++;
        if(level==1){
          if(includeGrouping){
            out.append(input.substring(i+1,1+i+begin.length()));
          }
          i+=begin.length();
        }else{
          continue;
        }
        g=true;
  
      }
      if (i<input.length()-terminator.length()&& 
        input.substring(i+1, i+1+terminator.length()).equals(terminator)) {
        level--;
        if(level==0){
          if(includeGrouping){
            out.append(input.substring(i+1,1+i+terminator.length()));
          }
          i+=terminator.length();
          
        }else{
          continue;
        }
        g=true;
      }
    }
    if ((!inQuotes||!quotations)&&i<input.length()-delim.length()&& 
      input.substring(i+1, i+1+delim.length()).equals(delim)) {
        //println("FOUND DELIM: ",out);
      if(level==0){
        
        i+=delim.length();
        output.add(out.toString());
        out.setLength(0);
        g=true;
      }
     
    }
    }while(g);
  }
  output.add(out.toString());
  return output.toArray(new String[]{});
}

String[] splitWithQuotes(String input, String delim,boolean keepquotes) {
  String out="";
  ArrayList<String> output = new ArrayList();
  boolean insideQuote = false;
  for (int i =-1; i<input.length(); i++) {
    
    if(i<input.length()-1&&input.charAt(i+1)=='"'){
        insideQuote=!insideQuote;
        
    }
    if(i>=0&&(input.charAt(i)!='"'||keepquotes)){
      out+=input.charAt(i);
    }
    boolean g = false;
    do{
      g = false;
    
      if (!insideQuote&&i<input.length()-delim.length()&& 
        input.substring(i+1, i+1+delim.length()).equals(delim)) {
        i+=delim.length();
        output.add(out);
        out="";
        g=true;
      
        if(i<input.length()-1&&input.charAt(i+1)=='"'){
          insideQuote=!insideQuote;
        }
      }
    }while(g);
  }
  output.add(out);
  return output.toArray(new String[]{});
}
String readToNext(String input, String match, int start) {
  //println("debug:",input,match,start);
  int am=0;
  for (int i =start; i<input.length(); i++) {
    if(i>=0){
    am++;
    }
    if (input.substring(i+1, i+1+match.length()).equals(match)) {
      break;
    }
  }
  start = max(start,0);
  return input.substring(start,start+am);
}


/*
e.g. 
 Example 1:
 input = ab[cdef]gh
 terminator = ]
 begin = [
 start at 'c' 's location
 returns 'cdef'
 
 Example 2:
 input = ab[cdef[bee]ad]gh
 terminator = ]
 begin = [
 start at 'c' 's location
 returns 'cdef[bee]ad'
 
 */
String readToNextofSameLevel(String input, String begin, String terminator, int start) {
  String out="";
  int level = 1;
  for (int i =start; i<input.length(); i++) {
    out+=input.charAt(i);

    if (i<input.length()-begin.length()&& //prevent outofbounds
      input.substring(i+1, i+1+begin.length()).equals(begin)) {
      level++;
    }
    if (i<input.length()-terminator.length()&& 
      input.substring(i+1, i+1+terminator.length()).equals(terminator)) {
      level--;
      if (level==0) {
        break;
      }
    }
  }

  return out;
}



boolean isArray(String line){
  return('['==line.charAt(0)&& ']'==line.charAt(line.length()-1));
}

String[] splitArray(String scriptline){
  String s = trimEnds(scriptline);
  if(contains(s,"[")){
    return cachedSplitofSameLevel(s,"[","]",",",true,true);
  }
  return splitWithQuotes(s,",",true);
}
String changeNthSplit(String input,String begin, String terminator, String delim,int no,String newString){
  String[] s= splitofSameLevel(input,begin,terminator,delim);
  s[no] = newString;
  return deliminate(s,delim);
}

String changeNthSplit(String input, String delim,int no,String newString){
  String[] s= splitWithQuotes(input,delim,true);
  s[no] = newString;
  return deliminate(s,delim);
}



String getSingle(String input[][], String key) {
  String out="";
  for (String[] s : input) {
    if (s[0].equals(key)) {
      return s[1];
    }
  }
  return out;
}  

String[]  getAll(String input[][], String key) {
  ArrayList<String> out=new ArrayList();
  for (String[] s : input) {
    if (s[0].equals(key)) {
      out.add(s[1]);
    }
  }
  return out.toArray(new String[]{});
}  
String fill(char c,int am){
  String s="";
  while(s.length()<am){s+=c;}
  return s;
}
String fill(String c,int am){
  String s="";
  while(s.length()<am*c.length()){s+=c;}
  return s;
}
String replaceAll(String input,String regex,String replaceWith){
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
int countAll(String input,String regex){
  int st =0;
  for(int i = 0;i<input.length();i++){
    if(i+regex.length()<=input.length()&&regex.equals(input.substring(i,i+regex.length()))){
      st++;
      i+=regex.length()-1;
    }
    
  }
  return st;
}
boolean contains(String input,String regex){
  for(int i = 0;i<input.length();i++){
    if(i+regex.length()<=input.length()&&regex.equals(input.substring(i,i+regex.length()))){
      return true;
    }
  }
  return false;
}
boolean contains(String input,char regex){
  for(int i = 0;i<input.length();i++){
    if(input.charAt(i)==regex){
      return true;
    }
  }
  return false;
}
boolean containsAny(String input,String regex){
  for(int i = 0;i<input.length();i++){
    for(int z=0;z<regex.length();z++){
    if(input.charAt(i)==regex.charAt(z)){
      return true;
    }
    }
  }
  return false;
}
String deliminate(String input[], String delim) {
  //println("deliminting", Arrays.toString(input), delim, "    -----");
  if (input.length==1) {
    return input[0];
  }
  String out="";
  for (String s : input) {
    out+=(out.length()==0?"":delim)+s;
  }
  return out;
}

String trimEnds(String line){
  if(line.length()<=2){return"";}
  return line.substring(1,line.length()-1);
}

boolean isInt(String s){
  if(s.isEmpty()){return false;}
  for(int i = 0;i<s.length();i++){
    if(s.charAt(i)<'0'||s.charAt(i)>'9'){
      if(i==0&&s.charAt(i)=='-'&&s.length()>1){
        continue;
      }
      return false;
    }
  }
  return true;
}
String toRaw(String scriptformat){
  boolean aint = isInt(scriptformat);
  String str = scriptformat;
  if(!aint){
    str = trimEnds(str);
  }
  return str;
}

int hash(int tick){
  int x = ((tick>>16) ^ tick)*0x45d9f3b;
   x = ((x>>16) ^ x)*0x45d9f3b;
   x = ((x>>16) ^ x);
  return x;
}
String dfGetString(JSONObject s, String id,String defaultstr){
  return s.hasKey(id)?s.getString(id):defaultstr;
}

int dfGetInt(JSONObject s, String id,int defaultstr){
  return s.hasKey(id)?s.getInt(id):defaultstr;
}

boolean inclusiveBetween(int x,int min,int max){
  return x>=min&&x<=max;
}
boolean exclusiveBetween(int x,int min,int max){
  return x>min&&x<max;
}

boolean dfGetBoolean(JSONObject s, String id,boolean defaultstr){
  //println(id);
  return s.hasKey(id)?s.getBoolean(id):defaultstr;
}
String generateId(){
  String id="";
  for(int i = 0;i<10;i++){
      id+=(char)random('a','z');
    }
    for(int i = 0;i<5;i++){
      id+=(char)random('1','9');
    }
    return id;
}

HashMap<String, Integer> actionWeights = new HashMap();

float[] rand = new float[100];

boolean isNumber(String s){
  if(s.isEmpty()){return false;}
  for(int i = 0;i<s.length();i++){
    if(s.charAt(i)<'0'||s.charAt(i)>'9'){
      if(i==0&&s.charAt(i)=='-'&&s.length()>1){
        continue;
      }
      if(i>0&&s.charAt(i)=='.'&&s.length()>1){
        continue;
      }
      return false;
    }
  }
  return true;
}

String getClip(){

  Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
  try{
  return (String)clipboard.getData(DataFlavor.stringFlavor);
  }catch(Exception e){}
  return "";
 
 }
 

 
void copyToClip(String s){
   StringSelection selection = new StringSelection(s);
  Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
  clipboard.setContents(selection, selection);
 
 }
