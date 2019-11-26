float sRandom(float r){
  return random(-r,r);
}







public boolean DotCircleIntersect(float x,float y,float px,float py,float r){
  return distsqrd(x,y,px,py)<r*r;
  
}
public boolean LineCircleIntersect(float x,float y,float x2,float y2,float px,float py,float r){
  return isTouching(px-r,py-r,px+r,py+r,min(x,x2),min(y,y2),max(x,x2),max(y,y2))&&getLinePointDisSqrd(x,y,x2,y2,px,py)<r*r;
  
}

public float LineLineIntersect(float x,float y,float x2,float y2,float Ax,float Ay,float Bx,float By, PVector output){
  if(!isTouching(min(x,x2),min(y,y2),max(x,x2),max(y,y2),min(Ax,Bx),min(Ay,By),max(Bx,Ax),max(Ay,By))){
    return Float.NaN;
  }
  PVector p=new PVector(x,y);
  PVector q=new PVector(Ax,Ay);
  
  PVector r=new PVector(x2-x,y2-y);
  //r=r.normalize();
  PVector s=new PVector(Bx-Ax,By-Ay);
  //s=s.normalize();
  
  PVector diff = (q .sub(p));
  
  float rs = twoDCross(r.x,r.y , s.x,s.y);
  float u =  twoDCross(diff.x,diff.y,r.x,r.y)/rs;
  float t =  twoDCross(diff.x,diff.y,s.x,s.y)/rs;
  //println(t);
  output .set( p.add(r.mult(t)));
  if((t<=0||t>=1)||(u<=0||u>=1)||
     (rs==0&&twoDCross(diff.x,diff.y,r.x,r.y)!=0)){
     u=Float.NaN;
  }
  
  return u;
}
public PVector LineRayIntersect(float x,float y,float x2,float y2,float rx, float ry,float deg){
  return LineRayIntersect(x,y,x2,y2,rx,ry,rx+cos(deg),ry+sin(deg));
}
public PVector LineRayIntersect(float x,float y,float x2,float y2,float Ax,float Ay,float Bx,float By){
  if(orientation(Ax,Ay,x,y,Bx,By)+
   orientation(Ax,Ay,x2,y2,Bx,By)!=3){
     return null;
   }
  PVector output = null;
  PVector p=new PVector(x,y);
 // PVector q=new PVector(Ax,Ay);
  
  PVector r=new PVector(x2-x,y2-y);
  //r=r.normalize();
  PVector s=new PVector(Bx-Ax,By-Ay);
  //s=s.normalize();
  
  PVector diff = new PVector(Ax-x,Ay-y);
  float rs = twoDCross(r.x,r.y , s.x,s.y);
  float t =  twoDCross(diff.x,diff.y,s.x,s.y)/rs;
  //println(t);
  output=( p.add(r.mult(t))).copy();
  if((t<=0||t>=1)||twoDCross(diff.x,diff.y,r.x,r.y)/rs<0||
     (rs==0&&twoDCross(diff.x,diff.y,r.x,r.y)!=0)){
     return null;
  }
  
  return output;
}

  public float getLinePointDisSqrd(float lx,float ly,float lx2,float ly2, float px,float py){
    
      
    float u = ((px-lx)*(lx2-lx) + (py-ly)*(ly2-ly))/(distsqrd(lx,ly,lx2,ly2));
    u = constrain(u, 0, 1);
    return distsqrd(lx+u*(lx2-lx),ly+u*(ly2-ly),px,py);
  }
  public PVector getClosestPointOnLine(float lx,float ly,float lx2,float ly2, float px,float py){
    float u = ((px-lx)*(lx2-lx) + (py-ly)*(ly2-ly))/(distsqrd(lx,ly,lx2,ly2));
    u = constrain(u, 0, 1);
    return new PVector(lx+u*(lx2-lx),ly+u*(ly2-ly));
  }
  public float getDisRatio(float lx,float ly,float lx2,float ly2, float px,float py){
    return ((px-lx)*(lx2-lx) + (py-ly)*(ly2-ly))/(distsqrd(lx,ly,lx2,ly2));
  }
  public float getLinePointDis(float lx,float ly,float lx2,float ly2, float px,float py){
    
    
    return sqrt(getLinePointDisSqrd(lx, ly, lx2, ly2, px, py));
  }
  
  float cosToSin(float c){
    return sqrt(1-c*c);
  }
  
  PVector constrainCollinear(PVector x,PVector a,PVector b){
    return new PVector(constrain(x.x,min(a.x,b.x),max(a.x,b.x)),constrain(x.y,min(a.y,b.y),max(a.y,b.y)));
  }
  
  PVector solveQuadratic(float a,float b,float c){
    float delta = sqrt(b*b-4*a*c);
    return Float.isNaN(delta)?null:(new PVector(-b+delta,-b-delta)).div(2*a);
  }
  
  public float twoDCross(float aX,float aY,float bX,float bY){
  
  return aX*bY - aY*bX;
  }
  
  
  // A C++ program to check if two given line segments intersect

 
// Given three colinear points p, q, r, the function checks if
// point q lies on line segment 'pr'
    public boolean onSegment(float px,float py, float qx,float qy, float rx,float ry)
    {
        if (qx <= max(px, rx) && qx >= min(px, rx) &&
            qy <= max(py, ry) && qy >= min(py, ry))
           return true;

        return false;
    }
 
// To find orientation of ordered triplet (p, q, r).
// The function returns following values
// 0 --> p, q and r are colinear
// 1 --> Clockwise
// 2 --> Counterclockwise
    public int orientation(float px,float py, float qx,float qy, float rx,float ry)
    {
        
        float val = (qy - py) * (rx - qx) -
                  (qx - px) * (ry - qy);

        if (val == 0) return 0;  // colinear
        
        return (val > 0)? 1: 2; // clock or counterclock wise
    }
    
    public float targetAng(float oAng,float tAng){
      int thing = orientation(0,0,cos(oAng),sin(oAng),cos(tAng),sin(tAng));
      if(thing==1){
        return tAng>oAng?tAng:tAng+(2*PI);
      }else if(thing==2){
        return tAng<oAng?tAng:tAng-(2*PI);
      }
      return tAng;
    }
    
    public float wrapToPositive(float x,float interval){
      return (x%interval+interval)%interval;
    }
    
    
    public String repeat(String t,int time){
      String d="";
      while(d.length()<t.length()*time){d+=t;};
      return d;
    }
    
    int getRandom(int[] e){
      return e[(int)random(e.length)];
    }
