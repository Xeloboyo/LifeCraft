class Interaction {
   //This class details the interactions between two traits. 
   String name;
   String desc;
   ArrayList<Trait> interactingTraits=new ArrayList();
   ArrayList<String> interactingParameters=new ArrayList();
   
   //Used to determine whether an interaction is more likely to occur based on certain interacting values.
   
   //useful for example if an effect occurs upon the presence of one trait and absence of another.
   //If true, then the absence of that trait confers a modifier.
   ArrayList<Boolean> traitAbsenceReq=new ArrayList();
   //Useful in creating autoupgrade traits which cause traits to combine upon specific combinations to form powerful combinations. 
   //(adding traits then removing the precursors)
   //Also useful for removing incompatible traits.
   ArrayList <Boolean> removeEffect;
   ArrayList<Trait> effect=new ArrayList();
   public int index;
   //Useful for prioritising competing interactions. The lower the more likely to occur over other competing interactions
   // as specified by interaction manager. 
   //If the interaction's priority is higher than 10 it will not occur.
   public int priority;
   public String filename;
   String activeProgram;
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
      ArrayList<String> comparisonValues=new ArrayList();
      for (int i=0; i<interactingParameters.size();i++) {
          //TODO to add script. These will be added into script
          comparisonValues.add(o.parameters.get(interactingParameters.get(i)).paramValue.toString());
          
      } 
      //Custom active script here based on whether parameters pass test for the interaction activating.
      //Passes in parameters into script by replacing "value" keywords with actual values.
      String prog=getFile(activeProgram);
      Program p=new Program(prog);
      String[] passin=new String[interactingParameters.size()];
      String[] passinnames=new String[interactingParameters.size()];
      for (int i=0; i<passin.length; i++) {
          passin[i]=o.parameters.get(interactingParameters.get(i)).paramValue.toString();
          passinnames[i]=o.parameters.get(interactingParameters.get(i)).name;
      }
      injectVariable(passinnames,passin,p);
      p.functions.add(defaultFunctions);
      while (!p.finished||!p.errored) {
          p.runCycle();
      }
      if (p.returnvalue=="true") {
         return true; 
      }
      
      return false;
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

        try{ 

       BufferedReader br=new BufferedReader(new FileReader(f));
       //Get trait 1 and trait 2 indices to load
       String t;
        String JSONWHOLE="";
        while((t=br.readLine())!=null){
            JSONWHOLE=JSONWHOLE.concat(t+"\n");
        } 
        br.close();
        JSONArray interactions = parseJSONArray("interactions");
        
        JSONObject interaction = (JSONObject) interactions.get(index);
        name=interaction.getString("name");
        desc=interaction.getString("desc");
        JSONArray interactionTraitReqs=(JSONArray) parseJSONArray("trait reqs");
        String traitfilename=interaction.getString("trait file");
        priority=interaction.getInt("priority");
        activeProgram=interaction.getString("active");
        
        for (int i=0; i<interactionTraitReqs.size(); i++) {
            String name=((JSONObject) interactionTraitReqs.get(i)).getString("trait name");
            traitAbsenceReq.add(((JSONObject) interactionTraitReqs.get(i)).getBoolean("trait absence req"));
            interactingTraits.add(getTraitByName(name,traitfilename));
        }
        JSONArray effectTraits=(JSONArray) parseJSONArray("effects");
        for (int i=0; i<effectTraits.size(); i++) {
            String name=((JSONObject) effectTraits.get(i)).getString("trait name");
            removeEffect.add(((JSONObject) effectTraits.get(i)).getBoolean("remove trait"));
            effect.add(getTraitByName(name,traitfilename));
        }
        JSONArray paramReqs=(JSONArray) parseJSONArray("parameter reqs");
        for (int i=0; i<paramReqs.size(); i++) {
            interactingParameters.add(((JSONObject) paramReqs.get(i)).getString("name"));
        }  

         } catch (Exception e) {
            e.printStackTrace(); 
           
         }

   }
}
