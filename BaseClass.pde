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


abstract class EntityEventInterceptor{
  abstract boolean onAdd(GameEntity e); // return false to cancel the add
  abstract boolean onRemove(GameEntity e); // return false to cancel a removal.
  //etc
}

class EntityManager {
   public HashMap<String,GameEntity> entities=new HashMap();
   ArrayList<EntityEventInterceptor> interceptionEvents = new ArrayList();
   //Reckon implement a quadtree system for efficiency of getting nearest species etc.
   public void addOrganism(GameEntity o) {
       for(EntityEventInterceptor ev: interceptionEvents){
         if(!ev.onAdd(o)){
           return;
         }
       }
       entities.put(o.id,o);
   }
   public void removeOrganism(Organism o) {
       for(EntityEventInterceptor ev: interceptionEvents){
         if(!ev.onRemove(o)){
           return;
         }
       }
       entities.remove(o.id);
      
   }
   public void initialise() {
       //First of all, get all initial species in the game
   }
   public void update() {
     for (String s: entities.keySet()) {
          //Update
          GameEntity o = entities.get(s);
          o.update();
          o.draw();
       }
   }
}
