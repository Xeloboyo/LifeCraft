

//import org.json.simple.*;
import java.util.logging.Logger;
import java.util.logging.Level;


//Base params needed to add to organism: stuff like health etc. want to add here to add modularity and avoid hardcoding.
public final String[] critical_params={"Health","Energy","Weight","Age","Health multiplier","Energy multiplier"};
int evopoints;
class Organism {
    //This will be the base starting species. Includes default Traits and starting Traits associated with species.
    ArrayList<Trait> species=new ArrayList();
    ArrayList<Trait> temporaryStatuses=new ArrayList();
    ArrayList<Float> timesOfTemporaryStatuses=new ArrayList();
    ArrayList<Float> removeTime=new ArrayList();
    String filename;
    Boolean playerSpecies;
    //These are necessary for position.
    float x;
    float y;
    float velX=0;
    float velY=0;
    //Used in behaviors to describe where the organism should be going.
    float targets[][];
    //Used to specify the priority of a particular target to reach.
    int priority[];
    //Used to identify species for display.
    String speciesName;
    public Organism(Trait[] traits, float x, float y,String species) {
        this.x=x;
        this.y=y;
        for (Trait trait:traits) {
          addTrait(trait);
        }
        speciesName=species;
    }
    //Traits/body parts determine how the thing works: the specific trait
    //influences gameplay
    //Different parts -> different energy requirements
    //Sleep/day-night cycle core part of gameplay 
    ArrayList <Trait> traits=new ArrayList();
    HashMap <String, Float> abilityCooldowns=new HashMap();
    HashMap <String, Float> abilityDurations=new HashMap();
    HashMap <String, Parameter> parameters=new HashMap();
    public void addTrait(Trait t) {
        this.species.add(t);
        for (Parameter p: t.paramChanges) {
            if (!parameters.containsKey(p.name)){
                parameters.put(p.name,p);
            } else {
                parameters.get(p.name).changeBy(p); 
            }
        } 
        //TODO: Check for interactions through interaction manager.
        
    }
    public void addTraitTemp(Trait t, float time) {
        this.temporaryStatuses.add(t);
        this.removeTime.add(time);
        this.timesOfTemporaryStatuses.add(0f);
        for (Parameter p: t.paramChanges) {
            if (!parameters.containsKey(p.name)){
                parameters.put(p.name,p);
            } else {
                parameters.get(p.name).changeBy(p); 
            }
        }
    }
    //Removal of temporary statuses.
    public void removeTraitTemp(int index) {
        
    }
    //This is for removal of permanent traits, not statuses
    public void removeTrait(String name) {
        
    }
    public void useInteraction(Interaction i) {
        i.update(this);
    }
    public void update(){
       //Update temporary statuses based on gametick
    }
    public void draw() {
       rect(x,y,2,2);
    }
    
}
static class OrganismManager {
   public static HashMap<String,ArrayList<Organism>> organisms=new HashMap();
   public static ArrayList<String> species;
   //Reckon implement a quadtree system for efficiency of getting nearest species etc.
   public static void update() {
     for (ArrayList<Organism> orgs: organisms.values())
     {
       for (Organism o: orgs) {
          //Update
          o.update();
          o.draw();
       }
     }
   }
}
