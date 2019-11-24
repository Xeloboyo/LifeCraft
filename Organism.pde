

//import org.json.simple.*;
import java.util.logging.Logger;
import java.util.logging.Level;


//Base params needed to add to organism: stuff like health etc. want to add here to add modularity and avoid hardcoding.
public final String[] critical_params={};
class Organism {

    //This will be the base starting species
    JSONObject species; 
    String filename;
    int evopoints;
    HashMap <String, Object> parameters;
    //If goes to zero creature dies.
    
    //Traits/body parts determine how the thing works: the specific trait
    //influences gameplay
    //Different parts -> different energy requirements
    //Sleep/day-night cycle core part of gameplay 
    ArrayList <Trait> traits;
    HashMap <String, Parameter> parameters;
    public void importTraits() {
        
    }
    public void importSpecies() {
        
    }
    public void saveOrganism() {
        
    }
    public void update(){
       
    }
}

class Trait {
    JSONObject traitSave;
    //-1=passive 
    //>1=active ability
    public String name;
    public int priority;
    //active as in is it on
    public boolean activated;
    public int index;
    public String filename;
    ArrayList < Parameter> paramChanges;
    //This is to indicate whether a particular trait is temporary, and is useful for effects on organisms such as injury, being on fire or famine.
    boolean isModifier; 
    Trait(String filename, int index) {
        this.index=index;
        this.filename=filename;
        loadTrait();
    }
    public void enact(Organism o) {
        for (int i=0; i<paramChanges.size(); i++) {
            if (o.parameters.containsKey(paramChanges.get(i).name)) {
                o.parameters.get(paramChanges.get(i).name).changeBy(paramChanges.get(i));
            }
        }
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
              Parameter p=new Parameter((JSONObject)parameters.get(i));
              paramChanges.add(p);
           }
           //Compatible Trait loading
           
        } catch (Exception e) {
          Logger.getLogger(Organism.class.getName()).log(Level.SEVERE, null, e);
        }
        } catch (Exception e) {
          e.printStackTrace(); 
        }
    }
    public void saveTrait() {
      
    }
}
class Parameter {
    Object paramValue;
    String name;
    String dataType;
    //Used for trait parameters to see if they've already changed another parameter in question.
    boolean changed=false;
    //Optional. think of this as a "velocity" for the parameter in question (e.g. hpregen for hp etc.)
    Parameter updateParameter;
    //Optional. If there is a cap value (e.g. for hp or energy) then this is used.
    Parameter maxParameter;
    
    Parameter(JSONObject obj) {
       loadParameter(obj);
    }
    void displayParameter() {
        //Used in GUI to display the parameter itself. 
    }
    //TODO
    void loadDisplay(String displayLocation, int displayIndex) {  
        //Load display details from JSON (e.g. GUI elements etc.)
        //Generic types such as hp bars, text statuses etc. will be handled in display parameter method.
        //Will also include type for displaying animations on organisms.
        //Will only display if particular species has this particular parameter.
    }
    void loadParameter(JSONObject obj) {
         //Recommended: use _change to indicate that an already existing parameter is to be changed. 
          name=getStringJSON(obj,"name_not_found","name");
          
          String paramDataType=getStringJSON(obj,"string","data type");
          String parameterValueChange=getStringJSON(obj,"0","value change");
          dataType=paramDataType;
          try {
              paramValue=Class.forName(paramDataType).cast(parameterValueChange);
          } catch (Exception e) {
              //something with integer casting from string not being viable most likely.
              //not sure how to fix this without annoying switch statements. if necessary add in switch statements.
             println("waow cannot cast or find class name");
             e.printStackTrace();
          }
          Boolean hasUpdateParameter=obj.getBoolean("has update parameter");
          Boolean hasMaxParameter=obj.getBoolean("has max parameter");
          if (hasUpdateParameter) {
              
          }
          if (hasMaxParameter) {
            
          }
          String displayLocation=obj.getString("gui location","file not found");
          int displayIndex=obj.getInt("gui location index");
          loadDisplay(displayLocation,displayIndex);
    }
    void changeBy(Parameter p) {
         if (p.dataType==this.dataType&&!p.changed) {
             //good
             switch (dataType) {
                case "int":
                    paramValue=(Integer)p.paramValue+(Integer)paramValue;
                    break;
                case "double":
                    paramValue=(Double)p.paramValue+(Double)paramValue;
                    break;
                case "float":
                    paramValue=(Float)p.paramValue+(Float)paramValue;
                    break;
                case "boolean":
                    paramValue=(Boolean)p.paramValue;
                    break;
                case "string": 
                    //Default will replace
                    paramValue=(String)p.paramValue;
                    break;
                default:
                    try {
                        paramValue=(Class.forName(dataType).cast(p.paramValue));
                    } catch (Exception e) {
                       e.printStackTrace(); 
                    }
             }
             p.changed=true;
         }
    }
    void update() {
        
    }
}
class Interaction {
   //This class details the interactions between two traits. skeleton for later
   String name;
   ArrayList<Trait> interactingTraits=new ArrayList();
   //useful for example if an effect occurs upon the presence of one trait and absence of another.
   //If true, then the absence of that trait confers a modifier.
   ArrayList<Boolean> traitAbsenceReq=new ArrayList();
   //Useful in creating autoupgrade traits which cause traits to combine upon specific combinations to form powerful combinations. 
   //(adding traits then removing the precursors)
   //Also useful for removing incompatible traits.
   ArrayList <Boolean> removeEffect;
   ArrayList<Trait> effect;
   public int index;
   //Useful for prioritising competing interactions.
   public int priority;
   public String filename;
   public Interaction(String filename, int index) {
       this.filename=filename;
       this.index=index;
       load();
   }
   //Whether a particular interaction will be present within an organism.
   public Boolean isActive(Organism o) {
      ArrayList <Boolean> present=new ArrayList(); 
      for (int i=0; i<interactingTraits.size(); i++) {
          if ((o.traits.contains(interactingTraits.get(i))&&traitAbsenceReq.get(i))||(!o.traits.contains(interactingTraits.get(i))&&!traitAbsenceReq.get(i))) {
              return false;
          }
      }
      return true;
   }
   public void update(Organism o) {
      if (isActive(o)) {
         for (int i=0; i<effect.size(); i++) {
              if (o.traits.contains(effect.get(i))&&!removeEffect.get(i)) {
                   o.traits.add(effect.get(i)); 
              } else if (!o.traits.contains(effect.get(i))&&removeEffect.get(i)) {
                   o.traits.remove(effect.get(i)); 
              }
         }
      }
   }
   public void load() {
       File f; 
       if(folder.equals("main")){
            f = new File(sysdir+"\\data\\prop\\"+filename+".json");
        }else {
            f = new File(sysdir+"\\mod\\"+folder+"\\data\\prop\\"+filename+".json");
        }   
         if(!f.exists()){System.err.println("FILE NOT FOUND: mod\\"+folder+","+filename+".json");return; }
         try {
       BufferedReader br=new BufferedReader(new FileReader(f));
       //Get trait 1 and trait 2 indices to load
       String t;
        String JSONWHOLE="";
        while((t=br.readLine())!=null){
            JSONWHOLE=JSONWHOLE.concat(t+"\n");
        } 
        JSONObject all = parseJSONObject(JSONWHOLE);
        JSONArray interactions = parseJSONArray("interactions");
        JSONObject interaction = (JSONObject) interactions.get(index);
        name=interaction.getString("name");
        JSONArray interactionTraitReqs=(JSONArray) parseJSONArray(name+" trait reqs");
        String traitfilename=interaction.getString("trait file");
        priority=interaction.getInt("priority");
        for (int i=0; i<interactionTraitReqs.size(); i++) {
            int index=((JSONObject) interactionTraitReqs.get(i)).getInt("trait "+i);
            traitAbsenceReq.add(((JSONObject) interactionTraitReqs.get(i)).getBoolean("trait "+i+" absence"));
            interactingTraits.add(new Trait(traitfilename,index));
        }
        JSONArray effectTraits=(JSONArray) parseJSONArray(name+" effects");
        for (int i=0; i<effectTraits.size(); i++) {
            int index=((JSONObject) effectTraits.get(i)).getInt("trait "+i);
            removeEffect.add(((JSONObject) effectTraits.get(i)).getBoolean("trait remove"));
            effect.add(new Trait(traitfilename,index));
        }
         } catch (Exception e) {
            e.printStackTrace(); 
           
         }
   }
}
class Ability {
      Ability () {
          //Contains animations, modifiers on another organism etc. 
      }
    //Exclusively for active abilities
    public float cooldown; 
    public void enact(Organism o) {
        
    }   
}
