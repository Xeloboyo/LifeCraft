

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
    public String desc;
    public int priority;
    //active as in is it on
    public boolean activated;
    public int index;
    public String filename;
    ArrayList < Parameter> paramChanges=new ArrayList();
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
            println(sysdir+""+filename+".json");
            f = new File(sysdir+""+filename+".json");

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
        JSONArray traiters = all.getJSONArray("traits");
        JSONObject trait= traiters.getJSONObject(index);
        
           String name = getStringJSON(trait, "name_not_found", "name");
           String desc= getStringJSON(trait, "desc_not_found", "desc");
           Boolean hasAbilities= getBooleanJSON(trait, false, "has abilities");
           if (hasAbilities) {
             int count=1;
             JSONObject nextAbility= (JSONObject) trait.get("ability "+count);
             while (nextAbility!=null) {
                 Ability a=new Ability();
                 //todo ability loading
                 count+=1;
                 nextAbility= (JSONObject) trait.get("ability "+count);
             }
           }
           //Parameter loading
           JSONArray parameters = (JSONArray) trait.getJSONArray("parameters");
           for (int i=0; i< parameters.size(); i++) {
              //Recommended: use _change to indicate that an already existing parameter is to be changed. 
              Parameter p=new Parameter((JSONObject)parameters.get(i));
              p.changeParameter=true;
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
    String desc;
    String dataType;
    //Used for trait parameters to see if they've already changed another parameter in question.
    boolean changed=false;
    boolean changeParameter=false;
    //Optional. think of this as a "velocity" for the parameter in question (e.g. hpregen for hp etc.)
    Parameter updateParameter;
    //How often the update occurs in terms of ticks.
    int updateTick;
    long startTime;
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
          desc=getStringJSON(obj,"desc_not_found","desc");
          String paramDataType=getStringJSON(obj,"string","data type");
          String parameterValueChange=getStringJSON(obj,"0","value");
          dataType=paramDataType;
          try {
              switch (dataType) {
                case "Integer":
                    paramValue=Integer.parseInt(parameterValueChange);
                    break;
                case "Double":
                    paramValue=Double.parseDouble(parameterValueChange);
                    break;
                case "Float":
                    paramValue=Float.parseFloat(parameterValueChange);
                    break;
                case "Boolean":
                    paramValue=Boolean.parseBoolean(parameterValueChange);
                    break;
                case "String": 
                    //Default will replace
                    paramValue=(String)paramValue;
                    break;
                default:
                    
                    break;
             }
          } catch (Exception e) {
              //something with integer casting from string not being viable most likely.
              //not sure how to fix this without annoying switch statements. if necessary add in switch statements.
             println("waow cannot cast or find class name");
             e.printStackTrace();
          }
          Boolean hasUpdateParameter=obj.getBoolean("has update parameter");
          Boolean hasMaxParameter=obj.getBoolean("has max parameter");
          startTime=time; 
          if (hasUpdateParameter) {
              updateTick=obj.getInt("update tick");
              JSONObject updateParameterDetails=(JSONObject)obj.get("update parameter");
              updateParameter=new Parameter(updateParameterDetails);
          }
          if (hasMaxParameter) {
              JSONObject maxParameterDetails=(JSONObject)obj.get("max parameter");
              maxParameter=new Parameter(maxParameterDetails);
          }
          Boolean hasGui=obj.getBoolean("has gui");
          if (hasGui) {
              String displayLocation=obj.getString("gui location","file not found");
              int displayIndex=obj.getInt("gui location index");
              loadDisplay(displayLocation,displayIndex);
          }
    }
    void changeBy(Parameter p) {
         if (p.dataType==this.dataType&&!p.changed&&p.changeParameter) {
             //good
             switch (dataType) {
                case "Integer":
                    paramValue=(Integer)p.paramValue+(Integer)paramValue;
                    if (maxParameter!=null) {
                        maxParameter.paramValue=(Integer)p.maxParameter.paramValue+(Integer)maxParameter.paramValue;
                    }  
                    if (updateParameter!=null) {
                        updateParameter.paramValue=(Integer)p.updateParameter.paramValue+(Integer)updateParameter.paramValue;
                    } 
                    break;
                case "Double":
                    paramValue=(Double)p.paramValue+(Double)paramValue;
                    if (maxParameter!=null) {
                        maxParameter.paramValue=(Double)p.maxParameter.paramValue+(Double)maxParameter.paramValue;
                    }  
                    if (updateParameter!=null) {
                        updateParameter.paramValue=(Double)p.updateParameter.paramValue+(Double)updateParameter.paramValue;
                    } 
                    break;
                case "Float":
                    paramValue=(Float)p.paramValue+(Float)paramValue;
                    if (maxParameter!=null) {
                        maxParameter.paramValue=(Float)p.maxParameter.paramValue+(Float)maxParameter.paramValue;
                    }  
                    if (updateParameter!=null) {
                        updateParameter.paramValue=(Float)p.updateParameter.paramValue+(Float)updateParameter.paramValue;
                    } 
                    break;
                case "Boolean":
                    paramValue=(Boolean)p.paramValue;
                    break;
                case "String": 
                    //Default will replace
                    paramValue=(String)p.paramValue;
                    break;
                default:
                    try {
                        paramValue=(Class.forName(dataType).cast(p.paramValue));
                    } catch (Exception e) {
                       e.printStackTrace(); 
                    }
                    break;
             }
             p.changed=true;
         }
    }
    void update() {
        switch (dataType) {
                case "int":
                    if (updateParameter!=null) {
                        if ((time-startTime)%updateTick==0) {
                            paramValue=(Integer)paramValue+(Integer)updateParameter.paramValue;
                        }
                    }
                    if (maxParameter!=null) {
                        if ((Integer)paramValue>(Integer)maxParameter.paramValue) {
                           paramValue= maxParameter.paramValue;
                        }
                    }
                    break;
                case "double":
                    if (updateParameter!=null) {
                        if ((time-startTime)%updateTick==0) {
                            paramValue=(Double)paramValue+(Double)updateParameter.paramValue;
                        }
                    }
                    if (maxParameter!=null) {
                        if ((Double)paramValue>(Double)maxParameter.paramValue) {
                           paramValue= maxParameter.paramValue;
                        }
                    }
                    break;
                case "float":
                    if (updateParameter!=null) {
                        if ((time-startTime)%updateTick==0) {
                            paramValue=(Float)paramValue+(Float)updateParameter.paramValue;
                        }
                    }
                    if (maxParameter!=null) {
                        if ((Float)paramValue>(Float)maxParameter.paramValue) {
                           paramValue= maxParameter.paramValue;
                        }
                    }
                    break;
                default:
                    break;
             }
    }
}
class Interaction {
   //This class details the interactions between two traits. skeleton for later
   String name;
   ArrayList<Trait> interactingTraits=new ArrayList();
   //Used to determine whether an interaction is more likely to occur based on certain interacting values.
   HashMap<Parameter,Object> paramInteractingValues=new HashMap();
   ArrayList <Boolean> overOrUnder=new ArrayList();
   //useful for example if an effect occurs upon the presence of one trait and absence of another.
   //If true, then the absence of that trait confers a modifier.
   ArrayList<Boolean> traitAbsenceReq=new ArrayList();
   //Useful in creating autoupgrade traits which cause traits to combine upon specific combinations to form powerful combinations. 
   //(adding traits then removing the precursors)
   //Also useful for removing incompatible traits.
   ArrayList <Boolean> removeEffect;
   ArrayList<Trait> effect;
   public int index;
   //Useful for prioritising competing interactions. The lower the more likely to occur over other competing interactions
   // as specified by interaction manager. 
   //If the interaction's priority is higher than 10 it will not occur.
   public int priority;
   public String filename;
   public Interaction(String filename, int index) {
       this.filename=filename;
       this.index=index;
       load();
   }
   //Whether a particular interaction will be present within an organism.
   public Boolean isActive(Organism o) {
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
            f = new File(sysdir+"\\data\\prop"+filename+".json");
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
//This is used to manage the priority of interactions (e.g. whether an interaction will occur as dependent on the location of an organism etc.)
class InteractionManager {
      
}
class Ability {
    String name;
    String desc;
      Ability () {
          //Contains animations, modifiers on another organism within a certain radius/cone/region etc. 
      }
    //Exclusively for active abilities
    public float cooldown; 
    public void enact(Organism o) {
        
    }   
}
