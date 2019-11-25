

//import org.json.simple.*;
import java.util.logging.Logger;
import java.util.logging.Level;


//Base params needed to add to organism: stuff like health etc. want to add here to add modularity and avoid hardcoding.
public final String[] critical_params={};
class Organism {

    //This will be the base starting species. Includes default Traits and starting Traits associated with species.
    JSONObject species; 
    String filename;
    int evopoints;
    //If goes to zero creature dies.
    
    //Traits/body parts determine how the thing works: the specific trait
    //influences gameplay
    //Different parts -> different energy requirements
    //Sleep/day-night cycle core part of gameplay 
    ArrayList <Trait> traits=new ArrayList();
    HashMap <String, Parameter> parameters=new HashMap();
    public void importTraits() {
        
    }
    public void importSpecies() {
        
    }
    public void saveOrganism() {
        
    }
    public void update(){
       
    }
}



class Ability {
    String name;
    String desc;
    
    Ability () {
        
    }
    public float cooldown; 
    public void enact(Organism o) {
        
    }   
}
