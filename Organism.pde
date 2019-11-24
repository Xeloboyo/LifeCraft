class Organism {
    //This will be the base starting species
    JSONObject species; 
    String filename;
    int evopoints;
    
    //If goes to zero creature dies.
    float energy;
    final float MAX_ENERGY=100f;
    
    //Traits/body parts determine how the thing works: the specific trait
    //influences gameplay
    //Different parts -> different energy requirements
    //Sleep/day-night cycle core part of gameplay 
    ArrayList <Trait> traits;
    public void importTraits() {
        
    }
    public void importSpecies() {
        
    }
    public void saveOrganism() {
        
    }
    public void update(){
       
    }
    public void updateBehavior() {
      
    }
}
abstract class Trait {
    JSONObject traitSave;
    //-1=passive 
    //>1=active ability
    public int priority;
    //Exclusively for active abilities
    public float cooldown; 
    public void enact(Organism o) {
        
    }   
}
