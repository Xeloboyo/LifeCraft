abstract class GameEntity{
  float x;
  float y;
  float velX=0;
  float velY=0;
  String id = generateId();
  float hp,maxhp;
  
  abstract void update();
  
  abstract void draw();
  
  abstract void onDeath();
  
  void damage(float rawDamage){
     this.hp-=rawDamage;
  }
  
  public abstract GameEntity clone();
  
}
//quad tree grids are not good for dynamic objects, as they constantly need to be rebuilt.
//we will use a static grid, where itll have a average case of O(k*floor((R/G)^2+1)) search complexity for collisions, where R is the maximum allowed size of any entity & G is girdsize, and a worst case of O(N).
