

//import org.json.simple.*;
import java.util.logging.Logger;
import java.util.logging.Level;


//Base params needed to add to organism: stuff like health etc. want to add here to add modularity and avoid hardcoding.
public final String[] critical_params={"Health","Energy","Weight","Age","Health multiplier","Energy multiplier"};
int evopoints;
class Organism extends GameEntity {
    //This will be the base starting species. Includes default Traits and starting Traits associated with species.
    ArrayList<Trait> species=new ArrayList();
    ArrayList<Trait> temporaryStatuses=new ArrayList();
    ArrayList<Float> timesOfTemporaryStatuses=new ArrayList();
    ArrayList<Float> removeTime=new ArrayList();
    String filename;
    Boolean playerSpecies;
    //These are necessary for position.
    
    //Used in behaviors to describe where the organism should be going.
    ArrayList<float[]> targets=new ArrayList();
    //Used to specify the priority of a particular target to reach.
    ArrayList<Integer> priorities=new ArrayList();
    
    
    //Used to identify species for display.
    String name;
    public Organism(Trait[] traits, float x, float y,String species) {
        this.x=x;
        this.y=y;
        for (Trait trait:traits) {
          addTrait(trait);
        }
        name=species;
    }
    //Traits/body parts determine how the thing works: the specific trait
    //influences gameplay
    //Different parts -> different energy requirements
    //Sleep/day-night cycle core part of gameplay 
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
        Trait toBeRemoved=temporaryStatuses.get(index);
        //First of all, remove trait.
        temporaryStatuses.remove(toBeRemoved);
        //Refresh parameters
        refreshParameters();
    }
    //This is for removal of species traits, not statuses. Removes one.
    public void removeTrait(String name) {
        int toRemove=-1;
        for (int i=0; i<species.size(); i++) {
             if (species.get(i).name==name) {
                  toRemove=i;
             }
        }
        if (toRemove!=-1) {
             species.remove(toRemove);
        }
        refreshParameters();
    }
    //removes all instances of a species trait.
    public void removeAllPermanent(String name) {
        while (species.contains(getTraitByName(name,"data\\traits"))){
            removeTrait(name);
        }
    }
    public void refreshParameters() {
        parameters.clear();
        for (Trait t: species) {
            for (Parameter p: t.paramChanges) {
                if (!parameters.containsKey(p.name)){
                    parameters.put(p.name,p);
                } else {
                    parameters.get(p.name).changeBy(p); 
                }
            } 
        }
        for (Trait t: temporaryStatuses) {
            for (Parameter p: t.paramChanges) {
                if (!parameters.containsKey(p.name)){
                    parameters.put(p.name,p);
                } else {
                    parameters.get(p.name).changeBy(p); 
                }
            }
        }
    }
    public void castAbility(String abilityName,int x,int y) {
        boolean hasAbility=false;
        Trait abilityTrait=null;
        for (Trait t: species) {
           if (t.abilities.containsKey(abilityName)) {
               hasAbility=true;
               abilityTrait=t;
           }
        }
        for (Trait t: temporaryStatuses) {
           if (t.abilities.containsKey(abilityName)) {
               hasAbility=true;
               abilityTrait=t;
           }
        }
        if (hasAbility&&abilityTrait!=null) {
            abilityTrait.abilities.get(abilityName).cast(this,x,y,time);
        }
    }
    
    public void testInteraction(Interaction i) {
        i.update(this);
    }
    public void update(){
       //Update temporary statuses based on gametick
       for (Trait t: species) {
          if (t.activated) {
              t.update(this); 
          }
          refreshParameters();
       }
    }
    public void draw() {
       rect(x,y,2,2);
    }
    @Override
    public Organism clone(){
      return new Organism(species.toArray(new Trait[]{}), x, y,name);
    }
    void onDeath(){}
    
}

//remove later.
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
