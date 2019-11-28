
class Trait {
    JSONObject traitSave;
    //-1=passive 
    //>1=active ability
    public String name;
    public String desc;
    //If not null, runs a particular script every tick.
    //Typically used for modifying behavior of a creature and checks on parameters.
    ArrayList<String>programs=new ArrayList();
    ArrayList<String>programType=new ArrayList();
    HashMap<String,Integer>intervals=new HashMap();
    HashMap<String,Ability>abilities=new HashMap();
    Boolean isEvolvable;
    int evoPointsCost;
    ArrayList<Trait> evoReqs=new ArrayList();
    int period;
    public int priority;
    //active as in is it on
    public boolean activated=true;
    public int index;
    public String filename;
    ArrayList < Parameter> paramChanges=new ArrayList(); 
    Trait(String filename, int index) {
        this.index=index;
        this.filename=filename;
        loadTrait();
    }
   /* public void enact(Organism o) {
        for (int i=0; i<paramChanges.size(); i++) {
            if (o.parameters.containsKey(paramChanges.get(i).name)) {
                o.parameters.get(paramChanges.get(i).name).changeBy(paramChanges.get(i));
            }
        }
    }*/
    
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
           isEvolvable=getBooleanJSON(trait,false,"is evolvable");
           if (isEvolvable) {
               evoPointsCost=getIntJSON(trait,0,"evo points cost");
               JSONArray evolutionReqs=trait.getJSONArray("evo requirements");
               for (int i=0; i<evolutionReqs.size(); i++) {
                    JSONObject evolutionReq=(JSONObject) evolutionReqs.get(i);
                    String evolutionReqName=evolutionReq.getString("name");
                    evoReqs.add(getTraitByName(evolutionReqName,"data\\traits"));
               }
           }
           activated=getBooleanJSON(trait,true,"active");
           Boolean hasPrograms=trait.getBoolean("has programs",false);
           JSONArray programsArray=trait.getJSONArray("programs");
           if (hasPrograms) {
              for (int i=0; i<programsArray.size(); i++) {
                 JSONObject program=(JSONObject)programsArray.get(i);
                 programs.add(program.getString("name"));
                 programType.add(program.getString("program role"));
                 Boolean hasInterval=program.getBoolean("has interval",false);
                 if (hasInterval) {
                     intervals.put(program.getString("name"),program.getInt("tick interval"));
                 }
              }
           }
           Boolean hasAbilities= getBooleanJSON(trait, false, "has abilities");
           //This is the resulting scripted behavior for getting next target position.
           JSONArray abilities=trait.getJSONArray("abilities");
           if (hasAbilities) {
             for (int i=0; i<abilities.size(); i++) {
                 JSONObject nextAbility= (JSONObject) abilities.get(i);
                 String abilityName=nextAbility.getString("ability name");
                 Ability a=getAbilityByName(abilityName,"data\\abilities");
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
           
           
        } catch (Exception e) {
          Logger.getLogger(Organism.class.getName()).log(Level.SEVERE, null, e);
        }
        } catch (Exception e) {
          e.printStackTrace(); 
        }
    }
    public void update(Organism o) {
       //Add methods here. 
       //First of all, update all parameters.
       for (Parameter p: paramChanges) {
            p.update(); 
       }
       //Next, use programs to update organism.
       //For programs, input will consist of an organism and programs will have a flag as to their operation.
       //Based on their flag, a particular operation will occur.
       
       //FLAGS:
       //update (parameter)
       //    This program will change the value of a particular named parameter with the return value of a program.
       //movement
       //    This program will output an array of movement coordinates with a priority.
       //ability (abilityname)
       //    This program will return whether a named ability should be cast
       //    and also returns the coordinates in which to cast.
       //All these programs will have an initial input of the organism parameters.
       for (int i=0; i<programs.size(); i++) {
           String progName=programs.get(i);  
           String prog=getFile(progName);
           Program p=new Program(prog);
           //Since everything can be fetched from the position, only the position is necessary.
           injectVariable(new String[]{"x","y"},new String[]{(int)o.x+"",(int)o.y+""},p);
           if (programType.get(i).startsWith("update")) {
               String [] parameters=programType.get(i).split(" ");
               String parameter="";
               for (int j=1; j<parameters.length; j++) {
                   parameter.concat(parameters[i]+" ");
               }
               p.functions.add(gameFunctions);
               while (!p.finished||!p.errored) {
                   p.runCycle();
               }
               o.parameters.get(parameter).paramValue=p.returnvalue;
               switch (o.parameters.get(parameter).dataType) {
                  case "Integer":
                      o.parameters.get(parameter).paramValue=Integer.parseInt(o.parameters.get(parameters).paramValue.toString());
                      break;
                  case "Double":
                      o.parameters.get(parameter).paramValue=Double.parseDouble(o.parameters.get(parameters).paramValue.toString());
                      break;
                  case "Float":
                      o.parameters.get(parameter).paramValue=Float.parseFloat(o.parameters.get(parameters).paramValue.toString());
                      break;
                  case "Boolean":
                      o.parameters.get(parameter).paramValue=Boolean.parseBoolean(o.parameters.get(parameters).paramValue.toString());
                      break;
                  case "String": 
                      o.parameters.get(parameter).paramValue=o.parameters.get(parameters).paramValue.toString();
                      break;
                  default:
                      break;
               }
           } else if (programType.get(i).startsWith("movement")) {
               p.functions.add(gameFunctions);
               while (!p.finished||!p.errored) {
                   p.runCycle();
               }
               //Program returns 3 arguments in returnvalue as an array in the following format:
               
               //x,y,priority;x,y,priority.
               //o.targets.add();
           } else if (programType.get(i).startsWith("ability")) {
               String [] abilities=programType.get(i).split(" ");
               String ability="";
               for (int j=1; j<abilities.length; j++) {
                   ability.concat(abilities[i]+" ");
               }
               p.functions.add(gameFunctions);
               while (!p.finished||!p.errored) {
                   p.runCycle();
               }
               //This type of program will return a position as well if the program returns to cast
               //[Boolean toCast, int x, int y]
               String toCast=p.returnvalue.split(",")[0];
               toCast=toCast.substring(1);
               if (!Boolean.parseBoolean(toCast)) {
                  //Do not cast ability 
                  println(o.name+" thought about casting ability "+ability+", but decided against it.");
               } else {
                  //Cast ability
                  println(o.name+" is trying to cast "+ability+"!");
                  int x=Integer.parseInt(p.returnvalue.split(",")[1]);
                  String yStr=p.returnvalue.split(",")[2].substring(0,(p.returnvalue.split(",")[2]).length()-2);
                  int y=Integer.parseInt(yStr);
                  o.castAbility(ability,x,y);
               }
           }
       }
    }
}
//This is loading. If already loaded, fetch from HashMap.
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
        switch (name) {
          case "Health":
            break; 
          case "Sustenance":
            break;
          case "Energy":
            break;
          case "Meat":
            break;
          case "Thirst":
            break;
          case "Hunger":
            break;
          default:
            break;
        }
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
