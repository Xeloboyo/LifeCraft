

boolean CONTROLPRESSED;

class GUIHandler{
  ArrayList<Component> comps = new ArrayList();
  ArrayList<Component> compsToAdd = new ArrayList();
  Component active = null;
  
  InputEvent ie = new InputEvent(){
    void onMousePressed(Component c){}
    void onKeyPressed(Component c){}
  };
  
  void add(Component c){
    compsToAdd.add(c);
    c.ie=ie;
  }
  Component get(String id){
    for(Component c:comps){
      if(c.id.equals(id)){
        return c;
      }
    }
    return null;
  }
  void remove(String id){
    Component cd=null;
    for(Component c:comps){
      if(c.id.equals(id)){
        cd= c;
      }
    }
    if(cd!=null){
      comps.remove(cd);
      if(active==cd){
        active = null;
      }
    }
    
  }
  boolean onclick(int button, int mx, int my){
    boolean gotOne = false;
    if(active!=null&& active.onclick(button,mx,my)){
      return true;
    }
    for(Component c:comps){
      if(c.onclick(button,mx,my)&&c!=active){
        active = c;
        gotOne=true;
        
        break;
      }
    }
    if(!gotOne){
      active=null;
      return false;
    }else{
      comps.remove(comps.get(comps.indexOf(active)));
      comps.add(0,active);
      return true;
    }
  }
  void onhover(int mx, int my){
    for(Component c:comps){
      if(c.onhover(mx,my)){
        
      }
    }
  }
  boolean onMouseWheel(int wheel){
    //println(wheel);
     for(Component c:comps){
      //c.onMouseWheel(wheel);
    }
     return false;
   }
  void onKeyPress(char key, int keycode){
    if(active!=null){
      active.onKeyPress(key, keyCode);
    }
  }
  void update(){
    for(Component c:comps){
      c.update();
    }
    comps.addAll(compsToAdd);
    compsToAdd.clear();
  }
  void draw(){
    for(Component c:comps){
      c.draw();
    }
  }

}


interface InputEvent{
  abstract void onMousePressed(Component c);
  abstract void onKeyPressed(Component c);
}

interface SyncEvent{
  abstract void onSync(Object value, Component  c);
}

abstract class Component{
  float x,y,w,h;
  String id;
  InputEvent ie = new InputEvent(){
  void onMousePressed(Component c){}
  void onKeyPressed(Component c){}
  };
  SyncEvent se = new SyncEvent(){
    void onSync(Object value, Component  c){ c.value = value;}
  };
  String label;
  color base = color(235),contrast = color(50),saturate=color(255,100,100);
  boolean active;
  boolean visible = true;
  boolean enabled = true;
  Object value=null;
  boolean valid = false;
   Component(String id){
     this.id=id;
   }
  
  abstract void draw();
  abstract void update();
  
  abstract boolean onclick(int button, int mx, int my);
  abstract boolean onhover(int mx, int my);
  abstract boolean onKeyPress(char key, int keycode);
  abstract void updateValid();
  String stringify(){return value.toString();}
  void drawOntop(){};
  boolean onDrag(int button, int mx, int my){return false;
};
  abstract Component clone();
  void collapse(){};
  
}

class TextBox extends Component{
  String allowedchars;
  int cursorpos;
  int state;
  float anistate=0;
  String type;
  String ovalue = "";
  JSONObject dummymemmory = new JSONObject();
  
  String error="";
  
  TextBox(String id,String allowed,float x,float y,float w,float h,String[] allowedvars){
     super(id);
     this.x=x;
     this.y=y;
     this.w=w;
     this.h=h;
     this.label="";
     this.type = "Expression";
     this.allowedchars=allowed;
     
      dummymemmory = new JSONObject();
      for(String s:allowedvars){
        JSONObject dummyx = new JSONObject();
        dummyx.setString("value","1");
         dummymemmory.setJSONObject(s,dummyx);
      }
     
    
       label = "x*x";
      updateValid();
     
     
  }
  
  TextBox(String id,String allowed,float x,float y,float w,float h,String type){
     super(id);
     this.x=x;
     this.y=y;
     this.w=w;
     this.h=h;
     this.label="";
     this.type = type;
     this.allowedchars=allowed;
     
    dummymemmory = new JSONObject();
        JSONObject dummyx = new JSONObject();
        dummyx.setString("value","1");
        JSONObject dummyy = new JSONObject();
        dummyy.setString("value","1");
        JSONObject dummyz = new JSONObject();
        dummyz.setString("value","1");
              //{memory.getJSONObject(line).getString("value"),""};
        dummymemmory.setJSONObject("x",dummyx);
        dummymemmory.setJSONObject("y",dummyy);
        dummymemmory.setJSONObject("z",dummyz);
     
     switch(type){
       case "Number":
       case "Integer":
       label = "0";
       cursorpos=1;
       valid = true;
       break;
       case "Color":
       label = "AAAAAA";
       valid = true;
       break;
       case "Expression":
       label = "x*x";
       valid = true;
       break;
      
       
     }
     
     se = new SyncEvent(){
      void onSync(Object value, Component  cont){ 
        println("textbox sync", value); 
        TextBox cws = (TextBox)cont;
        if(value==null){
          return;
        }
        switch(cws.type){
          case "Color":
          if(value instanceof String){
            
            String avalue = (String)value;
            if(isNumber(avalue)){
              onSync(int(avalue),cont);
              return;
            }
            cws.value= unhex((avalue.length()==6?"FF":"")+avalue);
            cws.valid = true;
          }else if(value instanceof Integer){
            cws.value=value;
            cws.valid = true;
            if(alpha((Integer)value)<255){
              label = hex((Integer)value);
            }else{
              label = hex((Integer)value).substring(2);
            }
          }
          break;
          default:
            label = value.toString();
            cws.updateValid();
          break;
        }
        
        
        
      }
     };
  }
  
  Component clone(){
    TextBox t =  new TextBox(id,allowedchars,x,y,w,h,type);
    t.dummymemmory = dummymemmory;
    return t;
  }
  
   boolean onclick(int button, int mx, int my){
     if(!enabled){
       return false;
     }
     if(isIn(mx,my,x,y,w,h)){
       state=max(state,2);
       anistate=2.2;
       ie.onMousePressed(this);
       return true;
     }else{
       state = 0;
       active = false;
     }
     return false;
   }
   boolean onhover(int mx, int my){
     if(!enabled){
       return false;
     }
     if(isIn(mx,my,x,y,w,h)){
       state=max(state,1);
       return true;
     }else if(state==1){
       state = 0;
     }
     return false;
   }
   
   boolean onKeyPress(char key, int keycode){
     ie.onKeyPressed(this);
     

     if(CONTROLPRESSED){
       println(key,keycode);
       if(key == 'c'){
         copyToClip(label);
         anistate=0;
       }
       if(key == 'v'){
         String plabel = label;
         label=getClip();
         anistate=0;
         cursorpos=label.length();
         updateValid();
       }
       if(key == 'x'){
         copyToClip(label);
         anistate=3;
         label="";
         cursorpos=1;
         updateValid();
       }
       
       return true;
     }
     if(key == CODED){
       switch(keycode){
         case LEFT:
           cursorpos = constrain(cursorpos-1,0,label.length());
         break;
         case RIGHT:
           cursorpos = constrain(cursorpos+1,0,label.length());
         break;
       }
     }
     String olabel = label;
   // println("tbox insde",key,keycode,CONTROLPRESSED,allowedchars);
     if(key=='\b'&&label.length()>0&&cursorpos>0){
       label=label.substring(0,min(label.length(),cursorpos-1))+label.substring(min(label.length(),cursorpos),label.length());
       cursorpos--;
       
     }else if(allowedchars.contains(key+"")){
        
       label=label.substring(0,min(label.length(),cursorpos))+key+label.substring(min(label.length(),cursorpos),label.length());
       cursorpos++;
     }
     
     updateValid();
     return true;
   }
   void update(){
     anistate+=(state-anistate)*0.3;
     updateValid();
     
   }
   String stringify(){return label;}  
   void updateValid(){
     valid = true;
     switch(type){
       case "Integer":
         try{
           Integer.parseInt(label);
         }catch(Exception e){
           valid = false;
           error="Invalid whole number";
         }
       break;
       case "Number":
         try{
           Float.parseFloat(label);
         }catch(Exception e){
           valid = false;
           error="Invalid decimal number";
         }
       break;
       
       case "Color":
         if(label.length()!=6&&label.length()!=8){
            valid = false;
            error="Invalid hex colour value";
         }
       break;
      
     }
     if(!valid){
       anistate = 3.0;
     }else{
       switch(type){
       case "Number":
         value = float(label);
       break;
       case "Integer":
         value = int(label);
       break;
       case "Color":
         value = unhex((label.length()==6?"FF":"")+label);
       break;
        default:
          value = label;
       
       }
     }
   }
   
   void draw(){
     textAlign(LEFT,CENTER);
     if(!enabled){
       stroke(0,50);
       fill(0,20);
       rect(x,y,w,h);
       fill(50);
       text(ovalue+"",x+5,y,w-10,h);
       return;
     }
     float ah = h;
     color acol = anistate>=1?lerpColor(base,contrast,(anistate-1)*0.8+0.2):lerpColor(base,contrast,anistate*0.2);
     if(anistate>2){
       acol = lerpColor(contrast,saturate,(anistate-2));
     }
     color txtcol = anistate>=1?lerpColor(contrast,base,anistate-1):contrast;
     
     float textWidth = textWidth(label);
     float textoffset = max(0,textWidth-(w-10));
     float acursorpos = textWidth(label.substring(0,min(label.length(),cursorpos)));

     fill(acol);
     rect(x,y,w,h);
     
     fill(txtcol);
     if(type!="Color"){
       text(label,x+5-textoffset,y, w-10+textoffset, h);
     }else{
       float hashsize = textWidth("#");
       acursorpos +=hashsize;
       text("#",x+5-textoffset,y, w-10+textoffset, h);
       
       text(label,x+5-textoffset+hashsize,y, w-10+textoffset, h);
       if(valid){
         float h2 = (h-10);
         //checkerboard for alpha
         fill(200);
         rect(x+10-textoffset+hashsize+textWidth(label),y+5,h2,h2);
         fill(50);
         rect(x+10-textoffset+hashsize+textWidth(label),y+5,h2*0.5,h2*0.5);
         rect(x+10-textoffset+hashsize+textWidth(label)+h2*0.5,y+5+h2*0.5,h2*0.5,h2*0.5);
         
         
         fill(unhex((label.length()==6?"FF":"")+label));
         rect(x+10-textoffset+hashsize+textWidth(label),y+5,h2,h2);
       }
     }
     //fill(acol);
     //rect(x+textWidth+5-textoffset,y, w-10+textoffset -textWidth,h);
     
     
     
     if(active){
       fill(base,state*120);
       rect(x+5+acursorpos-textoffset,y+5,2,h-10);
     }
     
     if(!valid && error!=null){
       float ew = textWidth(error);
       fill(base);
       rect(x+w,y,ew+20,h);
       fill(contrast);
       text(error,x+w+10,y,ew+5,h);
     }
     
   }
}

boolean isIn(float px,float py,float x,float y,float w,float h){
  return px>x&&py>y&&px<x+w&py<y+h;
}

class CContainer extends Component{
  ArrayList<Component> comps = new ArrayList();
  boolean syncvalue = true;
  
  CContainer(String id,float x,float y,float w,float h){
    super(id);
     this.x=x;
     this.y=y;
     this.w=w;
     this.h=h;
     base = color(50);
     se = new SyncEvent(){
      void onSync(Object value, Component  cont){ 
         CContainer con = (CContainer)cont;
         if(con.syncvalue){
           cont.valid = true;
           for(Component c: con.comps){
             println(c.getClass().toString());
             c.se.onSync(value,c);
             if(c.valid){
               cont.value = c.value;
             }else{
               cont.valid = false;
             }
           }
           
           
           println(value);
         }
      }
    };
  }
  void addComp(Component c){
    comps.add(c);
    if(c.valid){
      se.onSync(c.value,this);
    }
    c.ie=ie;
  }
  void collapse(){
    for(Component c: comps){
      c.collapse();
    }
  }
  Component clone(){
    CContainer cc =  new CContainer(id,x,y,w,h);
    cc.se=se;
    cc.base = base;
    cc.syncvalue = syncvalue;
    for(Component c: comps){
      cc.addComp(c.clone());
    }
    return cc;
  }
  Component active = null;
  boolean onclick(int button, int mx, int my){
    println("container",mx,my);
      Component pactive = active;
      if(active!=null && active.onclick(button,int(mx-x),int(my-y))){
         return true;
      }
     if(visible){
       
       ie.onMousePressed (this);
       
       if(active!=null){
         active.active=false;
       }
       active=null;
       for(Component c: comps){
         if(c==pactive){
           continue;
         }
         if(c.onclick(button,int(mx-x),int(my-y))){
           active = c; 
           active.active =true;
           if(active.valid){
             se.onSync(active.value,this);
           }
           break;
         }
       }
       if(active!=null){
         comps.remove(comps.get(comps.indexOf(active)));
         comps.add(active);
         return true;
       }
     }
     return isIn(int(mx-x),int(my-y),x,y,w,h);
   }
   @Override
   boolean onDrag(int button, int mx, int my){
     if(active!=null && active.onDrag(button,int(mx-x),int(my-y))){
       if(active.valid){
         println("cc valid drag insde");
             se.onSync(active.value,this);
       }
       return true;
     }
     return false;
   }
   boolean onhover(int mx, int my){
     if(visible){
       for(Component c: comps){
         c.onhover(int(mx-x),int(my-y));
       }
     }
     return false;
   }
   boolean onKeyPress(char key, int keycode){
     ie.onKeyPressed(this);
     if(active!=null && active.onKeyPress(key,keycode)){
       
       if(active.valid){
         
             se.onSync(active.value,this);
       }
       return true;
     }
     //mask(
     
     return false;
   }
   void updateValid(){
     if(active!=null &&active.valid){     
           se.onSync(active.value,this);
           return;
     }
     for(Component c: comps){
       if(c.valid){
         se.onSync(c.value,this);
         return;
       }
     }
   }
   void update(){
     for(Component c: comps){
       c.update();
     }
     if(active!=null && active.valid){
       value = active.value;
     }
   }
   
   void draw(){
     fill(base);
     rect(x,y,w,h,2);
     pushMatrix();
     translate(x,y);
     for(Component c: comps){
       c.draw();
     }
     popMatrix();
   }
}
class CButton extends Component{
  int state = 0;
  float anistate=0;
  boolean toggle = true;
  CButton(String id,String label,float x,float y,float w,float h){
     super(id);
     this.x=x;
     this.y=y;
     this.w=w;
     this.h=h;
     this.label=label;
     se = new SyncEvent(){
      void onSync(Object value, Component  cont){ 
        CButton cb = (CButton) cont;
        if(value instanceof String){
          state = boolean((String)value)?2:0;
        }
      }};
  }
  Component clone(){
    return new CButton(id,label,x,y,w,h);
  }
  
   boolean onclick(int button, int mx, int my){
     if(isIn(mx,my,x,y,w,h)){
       if(!toggle){
         state=max(state,2);
         anistate=2.5;
       }else{
         state=state>1?1:2;
         anistate=2.5;
       }
       ie.onMousePressed (this);
       return true;
     }
     return false;
   }
   boolean onhover(int mx, int my){
     if(state<2||!toggle){
       if(isIn(mx,my,x,y,w,h)){
         state=1;
         return true;
       }else{
         state = 0;
       }
       return false;
     }
     return false;
   }
   boolean onKeyPress(char key, int keycode){
     if(key=='\n'&&isIn(mouseX,mouseY,x,y,w,h)){
       ie.onKeyPressed(this);
       return true;
     }
     return false;
   }
   void updateValid(){
     value = state ==2;
     valid = true;
   }
   void update(){
     anistate+=(state-anistate)*0.3;
     updateValid();
     //println(value);
   }
   void draw(){
     float ah = h;
     color acol = anistate>=1?lerpColor(base,contrast,(anistate-1)*0.8+0.2):lerpColor(base,contrast,anistate*0.2);
     color txtcol = anistate>=1?lerpColor(contrast,base,anistate-1):contrast;
     
     fill(acol);
     rect(x,y,w,ah);
     textAlign(LEFT,CENTER);
     fill(txtcol);
     text(label,x+5,y+5,w-10,h-10);
     if(toggle){
       float size = constrain(map(anistate, 0.8,2.4,0,1),0.0,1.0)*0.5;
       pushMatrix();
       translate(x+w-ah*0.5,y+h*0.5);
       rect(-size*h,-size*h,size*h*2,size*h*2,3);
       popMatrix();
       
     }
   }
}

class CListSelect extends Component{
  int[] state;
  float[] anistate;
  boolean toggle = false;
  boolean multiselect=false;
  
  String labels[];
  CListSelect(String id,String labels[],float x,float y,float w,float h){
     super(id);
     this.x=x;
     this.y=y;
     this.w=w;
     this.h=h;
     this.label=labels[0];
     this.labels = labels;
      state = new int[labels.length];
     anistate = new float[labels.length];
      
  }
  Component clone(){
    CListSelect cl =  new CListSelect(id,labels,x,y,w,h);
    cl.toggle =toggle;
    cl.multiselect = multiselect;
    return cl;
  }
  
   boolean onclick(int button, int mx, int my){
     
     if(isIn(mx,my,x,y,w,h)){
       int index = floor(labels.length*(my-y)/h);
       if(!toggle){
         state[index]=max(state[index],2);
         anistate[index]=2.5;
       }else{
         if(!multiselect){
           for(int i = 0;i<labels.length;i++){
             if(i!=index){
               state[i] = 1;
             }
           }
         }
         state[index]=state[index]>1?1:2;
         anistate[index]=2.5;
         
       }
       ie.onMousePressed (this);
       return true;
     }
     return false;
   }
   boolean onhover(int mx, int my){
     if(isIn(mx,my,x,y,w,h)){
       int index = floor(labels.length*(my-y)/h);
       if(state[index]<2||!toggle){
         state[index]=1;
         
         
       }
       for(int i = 0;i<labels.length;i++){
         if(state[i] ==1&&i!=index){
           state[i]=0;
         }
       }
       return true;
         
       
     }else{
       for(int i = 0;i<labels.length;i++){
         if(state[i] ==1){
           state[i]=0;
         }
       }
     }
     return false;
     
   }
   boolean onKeyPress(char key, int keycode){
     if(key=='\n'&&isIn(mouseX,mouseY,x,y,w,h)){
       ie.onKeyPressed(this);
       return true;
     }
     return false;
   }
   void updateValid(){
     String selected = "";
     for(int i = 0;i<labels.length;i++){
       
       if(state[i]==2){
         selected += labels[i]+",";
       }
     }
     if(selected.length()>0){
       value = selected.substring(0,selected.length()-1);
       valid = true;
     }
   }
   void update(){
     String selected = "";
     for(int i = 0;i<labels.length;i++){
       anistate[i]+=(state[i]-anistate[i])*0.3;
     }
     updateValid();
     //println(value);
   }
   void draw(){
     float ah = h/labels.length;
     pushMatrix();
     for(int i = 0;i<labels.length;i++){
       color acol = anistate[i]>=1?lerpColor(base,contrast,(anistate[i]-1)*0.8+0.2):lerpColor(base,contrast,anistate[i]*0.2);
       color txtcol = anistate[i]>=1?lerpColor(contrast,base,anistate[i]-1):contrast;
       
       fill(acol);
       rect(x,y,w,ah);
       textAlign(LEFT,CENTER);
       fill(txtcol);
       
       text(labels[i],x+5,y+5,w-10,ah-10);
       if(toggle){
         float size = constrain(map(anistate[i], 0.8,2.4,0,1),0.0,1.0)*0.5;
         pushMatrix();
         translate(x+w-ah*0.5,y+ah*0.5);
         rect(-size*ah,-size*ah,size*ah*2,size*ah*2,3);
         popMatrix();
         
       }
       translate(0,ah);
     }
     popMatrix();
   }
}

import java.awt.Color;
import java.util.HashSet;



class Slider extends Component{
  float num;
  boolean integer = true;
  
  PVector ovalue = new PVector(0,0);
  float min,max;
  float tw;
  Slider (String id,float x,float y,float w,float h, float min,float max,float c,boolean intrger){
    super(id);
     this.x=x;
     this.y=y;
     this.w=w;
     this.h=h;
     valid = true;
     se = new SyncEvent(){
      void onSync(Object value, Component  cont){ 
        Slider cws = (Slider)cont;
        if(value instanceof String){
          num = float((String)value);
        }else{
          if(cws.integer){
            num = (int)(value);
          }else{
            num = (float)value;
          }
        }
        cws.valid = true;
        cws.update();
      }
     };
     integer = intrger;
     num = constrain(c,min,max);
     this.min=min;
     this.max=max;
     if(!intrger){
      tw = max(textWidth(nf(min,0,2)),textWidth(nf(max,0,2)))+10;
     }else{
       tw = max(textWidth(round(min)+""),textWidth(round(max)+""))+10;
     }
     
  }
  Component clone(){
    Slider  vs = new Slider ( id,x, y,w, h,min,max,num,integer);
    return vs;                                                                                                                                          
  }
  
  boolean pressedsb = false;
  boolean onclick(int button, int mx, int my){
     if(!enabled){
       return false;
     }
     if(isIn(mx,my,x,y,w,h)){
       
       num = map(mx-x,tw*0.5,w-tw*0.5,min,max);
       num = constrain(num,min,max);
       if(integer){
         num = round(num);
       }
       ie.onMousePressed(this);
       valid = true;
       return true;
     }
     return false;
   }
   float hovered = 0, hoveredAni = 0;;
   boolean onhover(int mx, int my){
     if(isIn(mx,my,x,y,w,h)){
       hovered =1;
       return true;
     }
     hovered =0;
     return false;
   }
   
   boolean onDrag(int button, int mx, int my){
    num = map(mx-x,tw*0.5,w-tw*0.5,min,max);
    num = constrain(num,min,max);
     if(integer){
       num = round(num);
     }
     valid = true;
     hovered =1;
     return true;
   };
   
   boolean onKeyPress(char key, int keycode){
     ie.onKeyPressed(this);
     return false;
   }
   void update(){
     updateValid();
     hoveredAni += (hovered-hoveredAni)*0.2;
   }
    void updateValid(){
      if(integer){
       value = round(num);
     }else{
        value = num;
     }
     valid =true;
    }
   
   void draw(){
     pushMatrix();
     translate(x,y);
     noStroke();
     fill(contrast);
     rect(0,0,w,h);
     float sliderpos = map(num,min,max,tw*0.5,w-tw*0.5);
     if(enabled){
       fill(base);
       
       rect(sliderpos-tw*0.5,0-hoveredAni*3,tw,h+hoveredAni*6);
       textAlign(CENTER,CENTER);
       fill(contrast);
       text(nf(num,0,integer?0:2)+"",sliderpos-tw*0.5,0-hoveredAni*3,tw,h+hoveredAni*6);
       if(hoveredAni>0.1){
         fill(base);
         float sidew = hoveredAni*(textWidth(max+"")+10);
         rect(w,0,sidew,h);
         rect(0,0,-sidew,h);
         fill(contrast);
         text((integer?nf(max,0,0):max)+"",w,0,sidew,h);
         text((integer?nf(min,0,0):min)+"",-sidew,0,sidew,h);
       }
       textAlign(LEFT,CENTER);
       
     }else{
       fill(lerpColor(base,contrast,0.5));
       rect(sliderpos-tw*0.5,0,tw,h);
       textAlign(CENTER,CENTER);
       fill(contrast);
       text(nf(num,0,3)+"",sliderpos-tw*0.5,0,tw,h);
       textAlign(LEFT,CENTER);
     }
     popMatrix();
   }
}


class Vector2DSelect extends Component{
  float vx,vy;
  float scal=1.0,dx,dy;
  boolean lockmag = true;
  
  PVector ovalue = new PVector(0,0);
  
  Vector2DSelect (String id,float x,float y,float w,float h){
    super(id);
     this.x=x;
     this.y=y;
     this.w=w;
     this.h=h;
     valid = true;
     se = new SyncEvent(){
      void onSync(Object value, Component  cont){ 
        Vector2DSelect cws = (Vector2DSelect)cont;
        if(value instanceof PVector){
          cws.value=value;
          cws.valid = true;
          
          PVector val = (PVector)cws.value;
          cws.vx=val.x;
          cws.vy=val.y;
          cws.scal = val.mag();
          PVector nval = val.copy().normalize();
          cws.dx = nval.x;
          cws.dy = nval.y;
        }else if(value instanceof String){
          String s = (String)value;
          s = s.trim().substring(1,s.length()-1);
          String[] pp = s.split(",");
          onSync(new PVector(float(pp[0]),float(pp[1]),float(pp[2])),cont);
        }
      }
     };
     scal = 1.0;
     dx=0;
     dy=-1;
     
  }
  Component clone(){
    Vector2DSelect vs = new Vector2DSelect( id,x, y,w, h);
    vs.lockmag = lockmag;
    return vs;                                                                                                                                          
  }
  
  boolean pressedsb = false;
  boolean onclick(int button, int mx, int my){
     if(!enabled){
       return false;
     }
     if(isIn(mx,my,x,y,w,h)){
       
       float rx = (mx-x)/w;
       float ry = (my-y)/(h);
       vx = (rx-0.5)*2.0;
       vy = (ry-0.5)*2.0;
       float pscal = dist(0,0,vx,vy);
       dx = vx/pscal;
       dy = vy/pscal;
       ie.onMousePressed(this);
       
       if(!lockmag){
         scale = pscal;
       }
       valid = true;
       return true;
     }
     return false;
   }
   float hovered = 0, hoveredAni = 0;;
   boolean onhover(int mx, int my){
     if(isIn(mx,my,x,y,w,h)){
       hovered =1;
       return true;
     }
     hovered =0;
     return false;
   }
   
   boolean onDrag(int button, int mx, int my){
     float rx = (mx-x)/w;
     rx = constrain(rx,0,1);
     float ry = (my-y)/(h-10);
     ry = constrain(ry,0,1);
     vx = (rx-0.5)*2.0;
     vy = (ry-0.5)*2.0;
     float pscal = dist(0,0,vx,vy);
     dx = vx/pscal;
     dy = vy/pscal;
     if(!lockmag){
       scale =pscal;
     }
     valid = true;
     return true;
   };
   
   boolean onKeyPress(char key, int keycode){
     ie.onKeyPressed(this);
     return false;
   }
   void update(){
     value = new PVector(dx*scal,dy*scal);
     hoveredAni += (hovered-hoveredAni)*0.2;
   }
   void updateValid(){
     value = new PVector(dx*scal,dy*scal);
     valid = true;
   }
   
   void draw(){
     pushMatrix();
     translate(x,y);
     fill(contrast);
     rect(0,0,w,h);
     stroke(lerpColor(base,contrast,0.5));
     line(0,h/2,w,h/2);
     line(w/2,0,w/2,h);
     noFill();
     ellipse(w/2,h/2,w,h);
     
     if(enabled){
       stroke(base);
       ellipse(w/2,h/2,5,5);
       line(w/2,h/2,w/2+dx*w*scal*0.5,h/2+dy*h*scal*0.5);
     }else{
       line(w/2,h/2,w/2+ovalue.x*0.5,h/2+ovalue.y*0.5);
     }
     popMatrix();
   }
}
class ColourWheelSelect extends Component{
  float hue=0,sat=0.5,bright=0.5;
  ColourWheelSelect(String id,float x,float y,float w,float h){
    super(id);
     this.x=x;
     this.y=y;
     this.w=w;
     this.h=h;
     valid = true;
     se = new SyncEvent(){
      void onSync(Object value, Component  cont){ 
        ColourWheelSelect cws = (ColourWheelSelect)cont;
        if(value instanceof String){
          String avalue = (String)value;
          if(isNumber(avalue)){
            onSync(int(avalue),cont);
            return;
          }
          int val = unhex((avalue.length()==6?"FF":"")+avalue);;
          hue = hue(val);
          sat = saturation(val);
          bright = brightness(val);
          cws.value= val;
          cws.valid = true;
        }else if(value instanceof Integer){
          cws.value=value;
          cws.valid = true;
          
          int val = (Integer)cws.value;
          hue = hue(val);
          sat = saturation(val);
          bright = brightness(val);
        }
      }
     };
  }
  Component clone(){
    return new ColourWheelSelect( id,x, y,w, h);                                                                                                                                          
  }
  String stringify(){
    String label;
    if(alpha((Integer)value)<255){
      label = hex((Integer)value);
    }else{
      label = hex((Integer)value).substring(2);
    }
    return label;
  }
  
  boolean pressedsb = false;
  boolean onclick(int button, int mx, int my){
     if(!enabled){
       return false;
     }
     if(isIn(mx,my,x,y,w,h)){
       
       float rx = (mx-x)/w;
       float ry = (my-y)/(h-10);
       if(ry>1){
         hue = rx*255;
         pressedsb = false;
       }else{
         sat = rx*255;
         bright = (1.0-ry)*255;
         pressedsb = true;
       }
       colorMode(HSB);
       value = color(hue, sat,bright);
       colorMode(RGB);
       
       ie.onMousePressed(this);
       
       
       
       return true;
     }
     return false;
   }
   float hovered = 0, hoveredAni = 0;;
   boolean onhover(int mx, int my){
     if(isIn(mx,my,x,y,w,h)){
       hovered =1;
       return true;
     }
     hovered =0;
     return false;
   }
   
   boolean onDrag(int button, int mx, int my){
     float rx = (mx-x)/w;
     float ry = (my-y)/(h-10);
     if(pressedsb){
       sat = constrain(rx,0,1)*255;
       bright = (1.0-constrain(ry,0,1))*255;
     }else {
       hue = constrain(rx,0,1)*255;
     }
     colorMode(HSB);
     value = color(hue, sat,bright);
     colorMode(RGB);
     return true;
   };
   void updateValid(){
     value = color(hue, sat,bright);
     valid = true;
   }
   boolean onKeyPress(char key, int keycode){
     ie.onKeyPressed(this);
     return false;
   }
   void update(){
     hoveredAni += (hovered-hoveredAni)*0.2;
   }
   
   void draw(){
     colorMode(HSB);
     beginShape();
     fill(255);
     vertex(x,y);
     fill(hue,255,255);
     vertex(x+w,y);
     fill(hue,255,0);
     vertex(x+w,y+h);
     fill(hue,0,0);
     vertex(x,y+h);
     endShape();
     
     fill(255);
     ellipse(x+w*sat/255f,y+(h-10)*(1-bright/255f),5+hoveredAni*3,5+hoveredAni*3);
     int amount = (int)constrain(scale*30,6,120);
     for(int i =0; i<amount ;i++){
       fill(i*255f/amount ,255,255);
       rect(x+i*w/float(amount),y+h-10,w/float(amount),10);
     }
     fill(255);
     ellipse(x+w*hue/255f,y+h-5,5+hoveredAni*3,5+hoveredAni*3);
     
     colorMode(RGB);
   }
}
class CDropdown extends CContainer{
  float buttonx,buttony,bw=25,bh=25;
  boolean isOn = false;
  PImage icon = null;
  float openani = 0;
 
  
  CDropdown(String id,float x,float y,float w,float h, float buttonx,float buttony){
    super(id,x,y,w,h);
    this.buttonx=buttonx;
    this.buttony=buttony;
    base = color(200);
    icon = loadImage("/icons/dropdown_downarrow.png");
    
  }
  Component clone(){
    CDropdown cc =  new CDropdown(id,x,y,w,h, buttonx,buttony);
    cc.se=se;
    cc.base = base;
    for(Component c: comps){
      cc.addComp(c.clone());
    }
    return cc;
  }
  boolean onclick(int button, int mx, int my){
    println("dropdown",mx,my);
    if(isOn){
      if(isIn(mx,my,x+buttonx,y+buttony,bw,bh)){
        
        isOn = false;
        //active = null;
        super.onclick(button,mx,my);
        return true;
      }
      if(super.onclick(button,mx,my)){
        return true;
      }
      if(isIn(mx,my,x,y,w,h)){
        return true;
      }
      isOn = false;
      return false;
    }
    else if(isIn(mx,my,x+buttonx,y+buttony,bw,bh)){
      isOn = true;
     
      return true;
    }
    return false;
  }
  boolean onDrag(int button, int mx, int my){
    if(isOn){
      return super.onDrag(button,mx,my);
      
    }
    return false;
  }
  boolean onhover(int mx, int my){
    if(isOn){
      return super.onhover(mx,my);
    }
    if(isIn(mx,my,x+buttonx,y+buttony,bw,bh)){
      openani-=0.05;
      return true;
    }
    return false;
  }
  boolean onKeyPress(char key, int keycode){
    if(isOn){
      super.onKeyPress(key,keycode);
      return true;
    }
    return false;
  }
  void update(){
    super.update();
    openani+= ((isOn?1:0) - openani)*0.2;
  }
  void collapse(){
    super.collapse();
    isOn = false;
  }
  void draw(){
    fill(base);
    noStroke();
    rect(x+buttonx,y+buttony,bw,bh);
    pushMatrix();
    translate(buttonx+x+bw*0.5,buttony+y+bh*0.5);
    rotate(openani*PI);
    tint(50);
    image(icon,-bw*0.5,-bh*0.5);
    noTint();
    popMatrix();
    noStroke();
    if(openani>0.01){
      fill(50);
      rect(x,y,w,h*openani);
    }
    if(isOn){
      
      super.draw();
    }
  }
  
}


String numeric="-.1234567890";
String alphanumeric="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-.";
String all="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!@#$%^&*(){}[]|\\,./<>?';:\"~`_+-= ";

class PaletteView extends Component{
  Palette p;
  PaletteView(String id,float x,float y,float w,float h){
    super(id);
     this.x=x;
     this.y=y;
     this.w=w;
     this.h=h;
  }
  Component clone(){
    return new PaletteView(id,x,y,w,h);
  }
  boolean onclick(int button, int mx, int my){
    return false;
  }
  int duration = 0;
   boolean onhover(int mx, int my){
     if(isIn(mx,my,x,y,w,h)){
       duration++;
       return true;
     }
     duration-=2;
     return false;
   }
   boolean onKeyPress(char key, int keycode){
     ie.onKeyPressed(this);
     return false;
   }
   void update(){
     
     value = null;
   }
   void draw(){
     int i =0;
     stroke(50);
     noFill();
     rect(x,y,w,h);
     noStroke();
     if(p!=null){
       float tr = w/p.colors.size();
       for(color c:p.colors){
         fill(c);
         rect(x+i*tr,y,tr,h);
         i++;
       }
     }
   }
   void updateValid(){
     valid = false;
   }
}
class TextureSelect extends Component{
  PImage texture;
  String dir;
  PImage other;
  
  boolean reloadTexture = false;
  //selectInput("Select a tilesheet to process:", "fileSelected");
  TextureSelect(String id,float x,float y,float w,float h,boolean reloadTexture){
    super(id);
     this.x=x;
     this.y=y;
     this.w=w;
     this.h=h;
     this.reloadTexture=reloadTexture;
     se = new SyncEvent(){
      void onSync(Object value, Component  cont){ 
        if(value==null){
          return;
        }
        TextureSelect ts = (TextureSelect)cont;
        if(value instanceof String){
          ts.texture = loadImage((String) value);
          ts.dir = (String) value;
          ts.valid = true;
        }else if(value instanceof PImage || value instanceof PGraphics){
          ts.texture = (PImage)value;
          ts.valid = true;
        }
      }
    };
  }
  String stringify(){return dir;}
  Component clone(){
    return new TextureSelect(id,x,y,w,h,reloadTexture);
  }
  boolean onclick(int button, int mx, int my){
     if(!enabled){
       return false;
     }
     if(isIn(mx,my,x,y,w,h)){
       await = this;
       selectInput("Select a image:", "textureSelected");
       
       ie.onMousePressed(this);
       return true;
     }
     return false;
   }
   int duration = 0;
   boolean onhover(int mx, int my){
     if(isIn(mx,my,x,y,w,h)){
       duration++;
       return true;
     }
     duration-=2;
     return false;
   }
   
   boolean onKeyPress(char key, int keycode){
     ie.onKeyPressed(this);
     return false;
   }
   void update(){
     
     value = texture;
   }
   void updateValid(){
     if(reloadTexture||(dir!=null && texture==null)){
       texture = loadImage(dir);
       println("reloading!", dir);
     }
     valid = (texture!=null);
     value = texture;
     
   }
   void draw(){
     duration = constrain(duration,0,50);
     if(!enabled){
       stroke(0,70);
       fill(0,20);
       rect(x,y,w,h);
       if(other!=null){
         image(other,x+5,y+5,w-10,h-10);
       }
       
       return;
       
     }
     if(!valid||texture==null){
       stroke(0,50);
        noFill();
       rect(x,y,w,h);
       fill(0,50);
       textAlign(CENTER,CENTER);
       
       text("no texture selected",x,y,w,h);
     }else{
       image(texture,x,y,w,h);
     }
     
   }
   @Override
   void drawOntop(){
     noStroke();
     pushMatrix();
     translate(0,height-280);
     if(duration>30){
       tint(255,(duration-30)*24);
       fill(0,(duration-30)*3);
       rect(0,0,250,250);
       String text = "";
       ((PGraphicsOpenGL)g).textureSampling(2);
       if(texture!=null&&enabled){
         float big = (250f/max(texture.width,texture.height));
         
         image(texture,0,0,big*texture.width,big*texture.height);

         text = texture.width+" x "+texture.height;
         fill(50);
         rect(0,250,textWidth(text)+20,30);
         fill(255);
         text(text,10,260);
       }else if(other!=null){
         float big = (250f/max(other.width,other.height));

         image(other,0,0,big*other.width,big*other.height);

         text = other.width+" x "+other.height;
         fill(50);
         rect(0,250,textWidth(text)+20,30);
         fill(255);
         text(text,10,260);
       }else{
         fill(255);
         text("no texture...",20,20);
       }
       ((PGraphicsOpenGL)g).textureSampling(3);
       noTint();
       
     }
     popMatrix();
   }
}
