class Trait {
    JSONObject traitSave;
    //-1=passive 
    //>1=active ability
    public String name;
    public String desc;
    //If not null, runs a particular script every tick.
    //Typically used for modifying behavior of a creature and checks on parameters.
    String runEveryTick;
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
        
           name = getStringJSON(trait, "name_not_found", "name");
           desc= getStringJSON(trait, "desc_not_found", "desc");
           Boolean hasAbilities= getBooleanJSON(trait, false, "has abilities");
           //This is the resulting scripted behavior for getting next target position.
           runEveryTick=getStringJSON(trait, "", "run every tick");
           
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
           if (parameters!= null){
               for (int i=0; i< parameters.size(); i++) {
                  //Recommended: use _change to indicate that an already existing parameter is to be changed. 
                  Parameter p=new Parameter((JSONObject)parameters.get(i));
                  p.changeParameter=true;
                  paramChanges.add(p);
               }
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
public Trait getTraitByName(String name, String filename) {
     
    String JSONWHOLE=getFile(filename);
    System.out.println(JSONWHOLE);
    JSONObject all = parseJSONObject(JSONWHOLE);
    JSONArray traiters = all.getJSONArray("traits");
    for (int i=0; i<traiters.size(); i++) {
        JSONObject trait= traiters.getJSONObject(i);
        String testName = getStringJSON(trait, "name_not_found", "name");
        if (name==testName) {
           return new Trait(filename,i); 
        }
    }
    println("Trait "+name+" not found!");
    return null;
   
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
                    paramValue=paramValue.toString();
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
          Boolean hasUpdateParameter=obj.getBoolean("has update parameter",false);
          Boolean hasMaxParameter=obj.getBoolean("has max parameter",false);
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
          Boolean hasGui=obj.getBoolean("has gui",false);
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
