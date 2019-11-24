
//import org.json.simple.*;
import java.util.logging.Logger;
import java.util.logging.Level;

class Organism {

    //This will be the base starting species
    JSONObject species; 
    String filename;
    int evopoints;
    HashMap <String, Object> parameters;
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
    public int index;
    public String filename;
    ArrayList <Trait> compatibleTraits;
    HashMap <String, Object> paramChanges;
    Trait(String filename, int index) {
        this.index=index;
    }
    public void enact(Organism o) {
        //Below is part of code enacting change in organism. this was from loadTrait originally but probably more suitable in here for later.
        /*if (!o.parameters.containsKey(paramName)) {
            //Add parameter, describe parameter data type.
            Class paramClass=Class.forName(paramDataType);
            Object parameter= paramClass.newInstance();
            o.parameters.put(paramName,parameter);
        }
        //implement param value change as dictated by data type. 
        //This is probably gonna result in some weird behavior since I tried to avoid using switch statements.
        //This directly changes the trait itself rather than increasing or decreasing it. This may prove a liability a bit later.
        //Maybe using _change as part of parameters internally to indicate that it is changing the value.
        String parameterValueChange=getStringJSON((JSONObject)parameters.get(i),"0","value change");
        Object parameterChange = (o.parameters.get(paramName).getClass().newInstance());
        parameterChange=o.parameters.get(paramName).getClass().cast(parameterValueChange);
        o.parameters.put(paramName,parameterChange);*/
    }
    public void loadTrait() {
        // Actual format:
        /* 
            - Name
            - Has abilities boolean
                - Abilities JSON names
            
            -Other optional parameters
                - e.g. Range, behavior etc.
                - Affecting variable
            - Interacting traits
                - Names
                - Effect on own parameters if exist
            - Compatible traits
                - May combine if exist
                - New trait name outlined   
        */
        File f;
        BufferedReader pr;
     
        if(folder.equals("main")){
            f = dataFile("/prop/"+filename+".json");

        }else {
            f = new File(sysdir+"\\mod\\"+folder+"\\data\\prop\\"+filename+".json");
        }   
        
        if(!f.exists()){System.err.println("FILE NOT FOUND: mod\\"+folder+","+filename+".json");return; }
        
       
        try {
           pr = new BufferedReader(new FileReader(f));
        String t;
        String JSONWHOLE="";
        while((t=pr.readLine())!=null){
            JSONWHOLE=JSONWHOLE.concat(t+"\n");
        } 
        System.out.println(JSONWHOLE);
        JSONObject all = parseJSONObject(JSONWHOLE);
        JSONArray traiters = parseJSONArray("traits");

        JSONObject trait= (JSONObject) traiters.get(index);
        
           String name = getStringJSON(trait, "name_not_found", "name");
           Boolean hasAbilities= getBooleanJSON(trait, false, "hasAbilities");
           if (hasAbilities) {
             int count=1;
             JSONObject nextAbility= (JSONObject) trait.get("ability"+count);
             while (nextAbility!=null) {
                 Ability a=new Ability();
                 //todo ability loading
                 count+=1;
                 nextAbility= (JSONObject) trait.get("ability"+count);
             }
           }
           //Parameter loading
           JSONArray parameters = (JSONArray) trait.get("parameters");
           for (int i=0; i< parameters.size(); i++) {
              //Recommended: use _change to indicate that an already existing parameter is to be changed. 
              String paramName=getStringJSON((JSONObject)parameters.get(i),"name_not_found","name");
              String paramDataType=getStringJSON((JSONObject)parameters.get(i),"string","data type");
              String parameterValueChange=getStringJSON((JSONObject)parameters.get(i),"0","value change");
              Object parameterChange;
              try {
                  parameterChange=Class.forName(paramDataType).cast(parameterValueChange);
              } catch (Exception e) {
                  //something with integer casting from string not being viable most likely.
                  //not sure how to fix this without annoying switch statements. if necessary add in switch statements.
                  println("waow cannot cast");
              }
              paramChanges.put(paramName, paramDataType);
           }
           //Compatible Trait + Interaction loading
           
        } catch (Exception e) {
          Logger.getLogger(Organism.class.getName()).log(Level.SEVERE, null, e);
        }
    }
    public void saveTrait() {
      
    }
}
class Interaction {
   //This class details the interactions between two traits. skeleton for later
   Trait t1;
   Trait t2;
   Trait effectOft2ont1;
   Trait effectOft1ont2;
}
class Ability {
      Ability () {
          //Contains animations, 
      }
    //Exclusively for active abilities
    public float cooldown; 
    public void enact(Organism o) {
        
    }   
}
