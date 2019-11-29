import java.util.*;
abstract class FunctionExecutor{
  abstract String[] execute(String cmd, String[] params);
}


void injectVariable(String[] variableName, String[] values, Program program) {
    for (int i=0; i<variableName.length; i++) {
      JSONObject jo = new JSONObject();
          jo.setString("value",values[i]);
          jo.setInt("depth",0);
          program.memory.setJSONObject(variableName[i],jo);
    }
}
FunctionExecutor defaultFunctions = new FunctionExecutor(){
    public String[] execute(String cmd, String[] params){
      //println(cmd,Arrays.toString(params));
      switch(cmd){
        case "PRINT":
          println("SCRIPT:   "+(params.length==1?params[0]:deliminate(params," ")));
          return new String[]{"",""};
        case "charAt":
          boolean aint = isInt(params[0]);
          String str = params[0];
          if(!aint){
            str = trimEnds(str);
          }
          if(!isInt(params[1])){
            return new String[]{"","| error in charAt, "+params[1]+" cannot be recognised as number|"};
          }
          try{
            return new String[]{"\""+str.charAt(int(params[1]))+"\"",""};
          }catch(Exception e){return new String[]{"","| error in charAt,"+e.toString()+"|"};}
        case "sign":
          aint = isInt(params[0]);
          if(!aint){
            return new String[]{"","| error in sign, "+params[0]+" cannot be recognised as number|"};
          }
          if(int(params[1])==0){
            return new String[]{"0",""};
          }
          return new String[]{""+int(params[0])/abs(int(params[0])),""};
        case "abs":
          aint = isInt(params[0]);
          if(!aint){
            return new String[]{"","| error in abs, "+params[0]+" cannot be recognised as number|"};
          }
          
          return new String[]{""+abs(int(params[0])),""};  
        case "constrain":
          aint = isInt(params[0])&&isInt(params[1])&&isInt(params[2]);
          if(!aint){
            return new String[]{"","| error in constrain, one or more paramters: "+params[0]+params[1]+params[2]+" cannot be recognised as a number|"};
          }
          return new String[]{""+constrain(int(params[0]),int(params[1]),int(params[2])),""};  
        case "min": //expand to be 2 or more later
          aint = isInt(params[0])&&isInt(params[1]);
          if(!aint){
            return new String[]{"","| error in min, one or more paramters: "+params[0]+params[1]+" cannot be recognised as a number|"};
          }
          return new String[]{""+min(int(params[0]),int(params[1])),""};    
        case "max": //expand to be 2 or more later
          aint = isInt(params[0])&&isInt(params[1]);
          if(!aint){
            return new String[]{"","| error in max, one or more paramters: "+params[0]+params[1]+" cannot be recognised as a number|"};
          }
          return new String[]{""+max(int(params[0]),int(params[1])),""};      
        case "arrayFill":
          aint = isInt(params[0]);
          if(!aint){
            return new String[]{"","| error in arrayFill , "+params[0]+" cannot be recognised as number  for array length|"};
          }
          if(int(params[0])<=0){
            return new String[]{"","| error in arrayFill , array length cannot be "+params[0]+"|"};
          }
          
          String[] tf = new String[int(params[0])];
          for(int i = 0;i<tf.length;i++){
            tf[i] = params[1];
          }
          
          return new String[]{"["+deliminate(tf,",")+"]",""};
        case "setLength":
          //println("setlength",Arrays.toString(params));
          if(!isArray(params[0])){
            return new String[]{"","| error in setLength , "+params[0]+" cannot be recognised as an array|"};
          }
        
          aint = isInt(params[1]);
          if(!aint){
            return new String[]{"","| error in setLength , "+params[1]+" cannot be recognised as number  for array length|"};
          }
          if(int(params[1])<=0){
            return new String[]{"","| error in setLength , array length cannot be "+params[1]+"|"};
          }
          String array[] = splitArray(params[0]);
          tf = new String[int(params[1])];
          for(int i = 0;i<tf.length;i++){
            if(i>= array.length){
              tf[i]=params.length>2?params[2]:"\"\"";
              continue;
            }
            tf[i] =  array[i];
          }
          
          return new String[]{"["+deliminate(tf,",")+"]",""};  
        case "arrayMergeOperate":
          //println("setlength",Arrays.toString(params));
          if(!isArray(params[0])){
            return new String[]{"","| error in setLength , "+params[0]+" cannot be recognised as an array|"};
          }
          array = splitArray(params[0]);
          if(array.length<=1){
            return new String[]{array[0],""};    
          }
          String current=evalArtithmetic(array[0],params[1],array[1]);
          if(array.length>2){
            for(int i = 2;i<array.length;i++){
              current=evalArtithmetic(current,params[1],array[1]);
            }
          }
          return new String[]{current,""};    
          
          
        case "len":
          //println("setlength",Arrays.toString(params));
          if(params.length<1){
            return new String[]{"","| error in len , insufficent arguments|"};
          }
          if(!isArray(params[0])){
            return new String[]{"","| error in count , "+params[0]+" cannot be recognised as an array|"};
          }
          array = splitArray(params[0]);
          int len = array[0].length()>0?array.length:0;
          return new String[]{""+len,""};  
        case "count":
          //println("setlength",Arrays.toString(params));
          if(params.length<2){
            return new String[]{"","| error in count , insufficent arguments|"};
          }
          if(!isArray(params[0])){
            return new String[]{"","| error in count , "+params[0]+" cannot be recognised as an array|"};
          }
          array = splitArray(params[0]);
          int count = 0;
          for(int i = 0;i< array.length;i++){
            if(array[i].equals(params[1])){
              count++;
            }
          }
          return new String[]{""+count,""};
        case "contains":
          //println("setlength",Arrays.toString(params));
          if(params.length<2){
            return new String[]{"","| error in contains , insufficent arguments|"};
          }
          if(!isArray(params[0])){
            return new String[]{"","| error in contains , "+params[0]+" cannot be recognised as an array|"};
          }
          array = splitArray(params[0]);
          
          for(int i = 0;i< array.length;i++){
            if(array[i].equals(params[1])){
              return new String[]{"\"true\"",""};  
            }
          }
          return new String[]{"\"false\"",""};   
        case "toCharArray":
          String raw = toRaw(params[0]);
          tf = new String[raw.length()];
          for(int i = 0;i<tf.length;i++){
            tf[i] = raw.charAt(i)+"";
          }
          
          return new String[]{"[\""+deliminate(tf,"\",\"")+"\"]",""};
        case "split":
          if(params.length<2){
            return new String[]{"","| error in contains , insufficent arguments|"};
          }
          return params[0].split(params[1]);
        case "script":
          String prog=getFile(params[0],false);
          Program p=new Program(prog);
          if (params.length%2==0) {
              return new String[]{"Incorrect number of arguments"};
          }
          String[] arguments=new String[(params.length-1)/2];
          for (int i=1; i<(params.length-1)/2+1; i++) {
              arguments[i-1]=params[i];
          }
          String[] parameters=new String[(params.length-1)/2];
          for (int i=(params.length-1)/2+1; i<params.length; i++) {
              arguments[i-((params.length-1)/2+1)]=params[i];
          }
          injectVariable(arguments,parameters,p);
          p.functions.add(gameFunctions);
          while (!p.finished||!p.errored) {
              p.runCycle();
          }
          return new String[]{p.returnvalue};
      }
      
      return null;
    }
  };
FunctionExecutor gameFunctions = new FunctionExecutor(){
    public String[] execute(String cmd, String[] params){
      //println(cmd,Arrays.toString(params));
      switch(cmd){
        case "PRINT":
          println("SCRIPT:   "+(params.length==1?params[0]:deliminate(params," ")));
          return new String[]{"",""};
        case "charAt":
          boolean aint = isInt(params[0]);
          String str = params[0];
          if(!aint){
            str = trimEnds(str);
          }
          if(!isInt(params[1])){
            return new String[]{"","| error in charAt, "+params[1]+" cannot be recognised as number|"};
          }
          try{
            return new String[]{"\""+str.charAt(int(params[1]))+"\"",""};
          }catch(Exception e){return new String[]{"","| error in charAt,"+e.toString()+"|"};}
        case "sign":
          aint = isInt(params[0]);
          if(!aint){
            return new String[]{"","| error in sign, "+params[0]+" cannot be recognised as number|"};
          }
          if(int(params[1])==0){
            return new String[]{"0",""};
          }
          return new String[]{""+int(params[0])/abs(int(params[0])),""};
        case "abs":
          aint = isInt(params[0]);
          if(!aint){
            return new String[]{"","| error in abs, "+params[0]+" cannot be recognised as number|"};
          }
          
          return new String[]{""+abs(int(params[0])),""};  
        case "constrain":
          aint = isInt(params[0])&&isInt(params[1])&&isInt(params[2]);
          if(!aint){
            return new String[]{"","| error in constrain, one or more paramters: "+params[0]+params[1]+params[2]+" cannot be recognised as a number|"};
          }
          return new String[]{""+constrain(int(params[0]),int(params[1]),int(params[2])),""};  
        case "min": //expand to be 2 or more later
          aint = isInt(params[0])&&isInt(params[1]);
          if(!aint){
            return new String[]{"","| error in min, one or more paramters: "+params[0]+params[1]+" cannot be recognised as a number|"};
          }
          return new String[]{""+min(int(params[0]),int(params[1])),""};    
        case "max": //expand to be 2 or more later
          aint = isInt(params[0])&&isInt(params[1]);
          if(!aint){
            return new String[]{"","| error in max, one or more paramters: "+params[0]+params[1]+" cannot be recognised as a number|"};
          }
          return new String[]{""+max(int(params[0]),int(params[1])),""};      
        case "arrayFill":
          aint = isInt(params[0]);
          if(!aint){
            return new String[]{"","| error in arrayFill , "+params[0]+" cannot be recognised as number  for array length|"};
          }
          if(int(params[0])<=0){
            return new String[]{"","| error in arrayFill , array length cannot be "+params[0]+"|"};
          }
          
          String[] tf = new String[int(params[0])];
          for(int i = 0;i<tf.length;i++){
            tf[i] = params[1];
          }
          
          return new String[]{"["+deliminate(tf,",")+"]",""};
        case "setLength":
          //println("setlength",Arrays.toString(params));
          if(!isArray(params[0])){
            return new String[]{"","| error in setLength , "+params[0]+" cannot be recognised as an array|"};
          }
        
          aint = isInt(params[1]);
          if(!aint){
            return new String[]{"","| error in setLength , "+params[1]+" cannot be recognised as number  for array length|"};
          }
          if(int(params[1])<=0){
            return new String[]{"","| error in setLength , array length cannot be "+params[1]+"|"};
          }
          String array[] = splitArray(params[0]);
          tf = new String[int(params[1])];
          for(int i = 0;i<tf.length;i++){
            if(i>= array.length){
              tf[i]=params.length>2?params[2]:"\"\"";
              continue;
            }
            tf[i] =  array[i];
          }
          
          return new String[]{"["+deliminate(tf,",")+"]",""};  
        case "arrayMergeOperate":
          //println("setlength",Arrays.toString(params));
          if(!isArray(params[0])){
            return new String[]{"","| error in setLength , "+params[0]+" cannot be recognised as an array|"};
          }
          array = splitArray(params[0]);
          if(array.length<=1){
            return new String[]{array[0],""};    
          }
          String current=evalArtithmetic(array[0],params[1],array[1]);
          if(array.length>2){
            for(int i = 2;i<array.length;i++){
              current=evalArtithmetic(current,params[1],array[1]);
            }
          }
          return new String[]{current,""};    
          
          
        case "len":
          //println("setlength",Arrays.toString(params));
          if(params.length<1){
            return new String[]{"","| error in len , insufficent arguments|"};
          }
          if(!isArray(params[0])){
            return new String[]{"","| error in count , "+params[0]+" cannot be recognised as an array|"};
          }
          array = splitArray(params[0]);
          int len = array[0].length()>0?array.length:0;
          return new String[]{""+len,""};  
        case "count":
          //println("setlength",Arrays.toString(params));
          if(params.length<2){
            return new String[]{"","| error in count , insufficent arguments|"};
          }
          if(!isArray(params[0])){
            return new String[]{"","| error in count , "+params[0]+" cannot be recognised as an array|"};
          }
          array = splitArray(params[0]);
          int count = 0;
          for(int i = 0;i< array.length;i++){
            if(array[i].equals(params[1])){
              count++;
            }
          }
          return new String[]{""+count,""};
        case "contains":
          //println("setlength",Arrays.toString(params));
          if(params.length<2){
            return new String[]{"","| error in contains , insufficent arguments|"};
          }
          if(!isArray(params[0])){
            return new String[]{"","| error in contains , "+params[0]+" cannot be recognised as an array|"};
          }
          array = splitArray(params[0]);
          
          for(int i = 0;i< array.length;i++){
            if(array[i].equals(params[1])){
              return new String[]{"\"true\"",""};  
            }
          }
          return new String[]{"\"false\"",""};   
        case "toCharArray":
          String raw = toRaw(params[0]);
          tf = new String[raw.length()];
          for(int i = 0;i<tf.length;i++){
            tf[i] = raw.charAt(i)+"";
          }
          
          return new String[]{"[\""+deliminate(tf,"\",\"")+"\"]",""};
        //This is used to run another named script (by filename), and returns the return value of that script. 
        //The arguments are as follows: 
        //1st argument is filename
        //next (n-1)/2 arguments are variable names
        case "script":
          String prog=getFile(params[0],false);
          Program p=new Program(prog);
          if (params.length%2==0) {
              return new String[]{"","error| Incorrect number of arguments|"};
          }
          String[] arguments=new String[(params.length-1)/2];
          for (int i=1; i<(params.length-1)/2+1; i++) {
              arguments[i-1]=params[i];
          }
          String[] parameters=new String[(params.length-1)/2];
          for (int i=(params.length-1)/2+1; i<params.length; i++) {
              parameters[i-((params.length-1)/2+1)]=params[i];
          }
          injectVariable(arguments,parameters,p);
          p.functions.add(gameFunctions);
          while (!p.finished||!p.errored) {
              p.runCycle();
          }
          return new String[]{p.returnvalue,""};
          //Arguments:
          //1,2 are position
          //3 is whether to include 0 location.
        case "locationOfNearestOrganism":
          if (params.length<3){
             return new String[]{"","| error in distanceToNearestOrganismFrom , insufficent arguments|"};
          } else if (params.length>3){
             return new String[]{"","| error in distanceToNearestOrganismFrom , too many arguments|"};
          }
          if (!isNumber(params[0])||!isNumber(params[1])) {
              return new String[]{"","| error in distanceToNearestOrganismFrom , position is not a vector of numbers|"};
          } 
          float[] closestO=new float[2];
          for (int i=0; i<orgManager.species.size(); i++) {
              for (Organism o: orgManager.organisms.get(orgManager.species.get(i))) {
                  //Latter is to not fetch own organism.
                 if (pow(closestO[0]-int(params[0]),2)+pow(closestO[1]-int(params[1]),2)>pow(o.x-int(params[0]),2)+pow(o.y-int(params[1]),2)
                 &&(pow(closestO[0]-int(params[0]),2)+pow(closestO[1]-int(params[1]),2)!=0||!boolean(params[2]))){
                     closestO[0]=o.x;
                     closestO[1]=o.y;
                 }
              }
          }
          return new String[]{closestO[0]+","+closestO[1],""};
          //Returns distance to nearest organism from specified location.
        case "distanceToNearestOrganismFrom":
          if (params.length<2){
             return new String[]{"","| error in distanceToNearestOrganismFrom , insufficent arguments|"};
          } else if (params.length>2){
             return new String[]{"","| error in distanceToNearestOrganismFrom , too many arguments|"};
          }
          if (!isNumber(params[0])||!isNumber(params[1])) {
              return new String[]{"","| error in distanceToNearestOrganismFrom , position is not a vector of numbers|"};
          } 
          closestO=new float[]{orgManager.organisms.get(orgManager.species.get(0)).get(0).x,orgManager.organisms.get(orgManager.species.get(0)).get(0).y};
          String name=orgManager.species.get(0);
          for (int i=0; i<orgManager.species.size(); i++) {
              for (Organism o: orgManager.organisms.get(orgManager.species.get(i))) {
                  //Latter after && is to not fetch own organism.
                 if (pow(closestO[0]-int(params[0]),2)+pow(closestO[1]-int(params[1]),2)>pow(o.x-int(params[0]),2)+pow(o.y-int(params[1]),2)
                 &&pow(closestO[0]-int(params[0]),2)+pow(closestO[1]-int(params[1]),2)!=0){
                     closestO[0]=o.x;
                     closestO[1]=o.y;
                 }
              }
          }
          return new String[]{Float.toString(sqrt(pow(closestO[0]-int(params[0]),2)+pow(closestO[1]-int(params[1]),2))),""};
        case "nameOfNearestOrganism":
          if (params.length<2){
             return new String[]{"","| error in distanceToNearestOrganismFrom , insufficent arguments|"};
          } else if (params.length>2){
             return new String[]{"","| error in distanceToNearestOrganismFrom , too many arguments|"};
          }
          if (!isNumber(params[0])||!isNumber(params[1])) {
              return new String[]{"","| error in distanceToNearestOrganismFrom , position is not a vector of numbers|"};
          } 
          closestO=new float[]{orgManager.organisms.get(orgManager.species.get(0)).get(0).x,orgManager.organisms.get(orgManager.species.get(0)).get(0).y};
          name=orgManager.species.get(0);
          for (int i=0; i<orgManager.species.size(); i++) {
              for (Organism o: orgManager.organisms.get(orgManager.species.get(i))) {
                  //Latter after && is to not fetch own organism.
                 if (pow(closestO[0]-int(params[0]),2)+pow(closestO[1]-int(params[1]),2)>pow(o.x-int(params[0]),2)+pow(o.y-int(params[1]),2)
                 &&pow(closestO[0]-int(params[0]),2)+pow(closestO[1]-int(params[1]),2)!=0){
                     closestO[0]=o.x;
                     closestO[1]=o.y;
                     name=o.name;
                 }
              }
          }
          return new String[]{name,""};
        //Script functions to implement:
        //Get distance to nearest of visible named organisms from a point
        //x,y,name
        case "distanceToNearestNamedOrganismFrom":
          if (params.length<3){
             return new String[]{"","| error in distanceToNearestNamedOrganismFrom , insufficent arguments|"};
          } else if (params.length>3){
             return new String[]{"","| error in distanceToNearestNamedOrganismFrom , too many arguments|"};
          }
          if (!isNumber(params[0])||!isNumber(params[1])) {
              return new String[]{"","| error in distanceToNearestNamedOrganismFrom , position is not a vector of numbers|"};
          } 
          if (!orgManager.species.contains(params[2])) {
             return new String[]{"","| error in distanceToNearestNamedOrganismFrom , species not recognised|"};
          }
          float[] closest={orgManager.organisms.get(params[2]).get(0).x,orgManager.organisms.get(params[2]).get(0).y};
          for (Organism o: orgManager.organisms.get(params[2])) {
             if (pow(closest[0]-int(params[0]),2)+pow(closest[1]-int(params[1]),2)>pow(o.x-int(params[0]),2)+pow(o.y-int(params[1]),2)){
                 closest[0]=o.x;
                 closest[1]=o.y;
             }
          }
          
          return new String[]{Float.toString(sqrt(pow(closest[0]-int(params[0]),2)+pow(closest[1]-int(params[1]),2))),""};
        //Get location of nearest visible named organisms
        //First two arguments are the position which you are testing
        //Last argument is the species you're testing for.
        case "locationOfNearestNamedOrganism":
        if (params.length<3){
             return new String[]{"","| error in distanceToNearestNamedOrganismFrom , insufficent arguments|"};
          } else if (params.length>3){
             return new String[]{"","| error in distanceToNearestNamedOrganismFrom , too many arguments|"};
          }
          if (!isNumber(params[0])||!isNumber(params[1])) {
              return new String[]{"","| error in distanceToNearestNamedOrganismFrom , position is not a vector of numbers|"};
          } 
          if (!orgManager.species.contains(params[2])) {
             return new String[]{"","| error in distanceToNearestNamedOrganismFrom , species not recognised|"};
          }
          float[]closestCreature={orgManager.organisms.get(params[2]).get(0).x,orgManager.organisms.get(params[2]).get(0).y};
          for (Organism o: orgManager.organisms.get(params[2])) {
             if (pow(closestCreature[0]-int(params[0]),2)+pow(closestCreature[1]-int(params[1]),2)>pow(o.x-int(params[0]),2)+pow(o.y-int(params[1]),2)){
                 closestCreature[0]=o.x;
                 closestCreature[1]=o.y;
             }
          }
          return new String[]{Float.toString(closestCreature[0])+","+Float.toString(closestCreature[1]),""};
        //Get velocities and locations of visible named organisms within a certain radius of a point.
        //Return arguments are first location, first velocity, second location, second velocity etc.
        //Arguments are:
        //x,y,species name,range.
        case "getNamedCreaturesWithinRange":
          ArrayList<String> returnValues=new ArrayList();
          if (params.length<4){
             return new String[]{"","| error in distanceToNearestNamedOrganismFrom , insufficent arguments|"};
          } else if (params.length>4){
             return new String[]{"","| error in distanceToNearestNamedOrganismFrom , too many arguments|"};
          }
          if (!isNumber(params[0])||!isNumber(params[1])) {
              return new String[]{"","| error in distanceToNearestNamedOrganismFrom , positions are not numbers|"};
          } 
          if (!orgManager.species.contains(params[2])) {
             return new String[]{"","| error in distanceToNearestNamedOrganismFrom , species not recognised|"};
          }
          if (!isNumber(params[3])) {
             return new String[]{"","| error in distanceToNearestNamedOrganismFrom , range is not number!|"};
          }
          for (Organism o: orgManager.organisms.get(params[2])) {
             if (pow(o.x-int(params[0]),2)+pow(o.y-int(params[1]),2)<int(params[3])){
               returnValues.add("["+o.x+","+o.y+","+o.velX+","+o.velY+"],");
             }
          }
          String returnArray="";
          for (int i=0; i<returnValues.size(); i++) {
            returnArray=returnArray+returnValues.get(i);
          }
          return new String[]{returnArray,""};
        //returns all organisms within a specified range, with names in the array like so:
        // 20,30,1,1,Wolf;20,43,2,2,Wolf;
        case "getOrganismsWithinRange":
          returnValues=new ArrayList();
          if (params.length<3){
             return new String[]{"","| error in distanceToNearestNamedOrganismFrom , insufficent arguments|"};
          } else if (params.length>3){
             return new String[]{"","| error in distanceToNearestNamedOrganismFrom , too many arguments|"};
          }
          if (!isNumber(params[0])||!isNumber(params[1])) {
              return new String[]{"","| error in distanceToNearestNamedOrganismFrom , positions are not numbers|"};
          } 
          if (!isNumber(params[2])) {
             return new String[]{"","| error in distanceToNearestNamedOrganismFrom , range is not number!|"};
          }
          for (int i=0; i<orgManager.species.size(); i++) {
              for (Organism o: orgManager.organisms.get(orgManager.species.get(i))) {
                 if (pow(o.x-int(params[0]),2)+pow(o.y-int(params[1]),2)<int(params[2])){
                     returnValues.add("["+o.x+","+o.y+","+o.velX+","+o.velY+","+o.name+"]");
                 }
              }
          }
          returnArray="";
          for (int i=0; i<returnValues.size(); i++) {
            returnArray=returnArray+returnValues.get(i);
          }
          return new String[]{returnArray,""};
        //Get terrain type in visible location.
        case "getTerrain":
          if (params.length<2){
             return new String[]{"","| error in getTerrain, insufficent arguments|"};
          } else if (params.length>2) {
            return new String[]{"","| error in getTerrain, too many arguments|"};
          }
          if (!isNumber(params[0])||!isNumber(params[1])) {
            return new String[]{"","| error in getTerrain, positions are not numbers|"};
          }
          return new String[]{getTile(int(params[0]),int(params[1])).tp.name,""};
        //Get whether named species has named trait
        //Argument 1=species
        //Argument 2=name of trait
        case "hasTrait":
          if (!orgManager.species.contains(params[0])) {
             return new String[]{"","| error in distanceToNearestNamedOrganismFrom , species not recognised|"};
          }
          if (!orgManager.organisms.get(params[0]).get(0).species.contains(params[1])){
              return new String[]{"\"false\"",""};
          }
          return new String[]{"\"true\"",""};
        //for organism nearest to specified location. includes 
        //argument 1/2: position
        //argument 3: parameter name
        case "getParameterForOrganismAt":
          if (params.length<3){
             return new String[]{"","| error in getParameter, insufficent arguments|"};
          } else if (params.length>3) {
            return new String[]{"","| error in getParameter, too many arguments|"};
          }
          if (!isNumber(params[0])||!isNumber(params[1])) {
              return new String[]{"","| error in distanceToNearestOrganismFrom , position is not a vector of numbers|"};
          } 
          closestO=new float[]{orgManager.organisms.get(orgManager.species.get(0)).get(0).x,orgManager.organisms.get(orgManager.species.get(0)).get(0).y};
          name=orgManager.species.get(0);
          Organism get=orgManager.organisms.get(orgManager.species.get(0)).get(0);
          for (int i=0; i<orgManager.species.size(); i++) {
              for (Organism o: orgManager.organisms.get(orgManager.species.get(i))) {
                  //Latter after && is to not fetch own organism.
                 if (pow(closestO[0]-int(params[0]),2)+pow(closestO[1]-int(params[1]),2)>pow(o.x-int(params[0]),2)+pow(o.y-int(params[1]),2)){
                     closestO[0]=o.x;
                     closestO[1]=o.y;
                     get=o;
                 }
              }
          }
          if (!get.parameters.containsKey(params[2])) {
              return new String[]{"null",""};
          } else {
              switch (get.parameters.get(params[2]).dataType) {
                case "Integer":
                    return new String[]{get.parameters.get(params[2]).paramValue.toString(),""};
                case "Double":
                    return new String[]{""+((int)(Double.parseDouble(get.parameters.get(params[2]).paramValue.toString()))),""};
                case "Float":
                    return new String[]{""+((int)(Float.parseFloat(get.parameters.get(params[2]).paramValue.toString()))),""};
                case "Boolean":
                    return new String[]{get.parameters.get(params[2]).paramValue.toString(),""};
                case "String": 
                    return new String[]{get.parameters.get(params[2]).paramValue.toString(),""};
                default:
                    return new String[]{get.parameters.get(params[2]).paramValue.toString(),""};
             } 
          }
      }
      
      return null;
    }
  };


class ProgramLine{
  String text;
  int depth;
  int lineNo;
  String[] lineProp;
  
  int blockExitJump=-1;
  ProgramLine(String line,int depth,int lineNo){
     this.text=line;
     this.depth=depth;
     this.lineNo=lineNo;
  }
  String toString(){
    return fill('\t',depth)+text;
  }
}
class Program{
  ArrayList<ProgramLine> lines = new ArrayList();
  String name;
  JSONObject memory = new JSONObject();
  ArrayList<FunctionExecutor> functions = new ArrayList(Arrays.asList(new FunctionExecutor[]{defaultFunctions}));
  
  
  String operators[] = {"&","|","==","!=",">=","<=",">","<","+","-","/","*","%"}; //split by these in order 
  String allowedvarChars = "abcdefghijklmnopqrstuvwxyz_ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  String reserved[] = {"if","while","elif","else","for","break","continue","return","wait"};
  int programcounter = 0;
  
  boolean finished = false;
  boolean resetMemory = true;
  boolean runOnce = true;
  String returnvalue = "";
  int wait=0;
  
  //envrionment
  boolean allowConcurrent;
  boolean errored = false;
  String error;
  
  
  
  
  
  Program(Program p){
    lines=p.lines;
    name=p.name;
    functions=p.functions;
    allowConcurrent= p.allowConcurrent;
  }
  Program(String programLines){
    println(functions);
    ArrayList<String> rawlines = new ArrayList(Arrays.asList(programLines.split("\n")));
    int cdepth = 0;
    int alineNo = 0;
    for(int i = 0;i<rawlines.size();i++){
      String cline = rawlines.get(i).trim();
      if(cline.length()==0||cline.charAt(0)=='#'){
        continue;
      }
      
      String newline="";
      
      if(countAll(cline,"}")>0||countAll(cline,"{")>0){
        boolean brackets = false;
        for(int j = 0;j<cline.length();j++){
          if("{}".contains(cline.charAt(j)+"")){
            brackets = true;
          }else if(brackets){
            break;
          }
          newline+=cline.charAt(j);
        }
        //println("nl",newline);
        
        String nextLine = cline.substring(newline.length());
        cline = newline;
        //println("nxl",nextLine);
        if(nextLine.length()>1)
          rawlines.add(i+1,nextLine);
      }
      String formatted = replaceAll(replaceAll(cline,"{",""),"}","");
      if(formatted.length()>0){
        lines.add(new ProgramLine(formatted,cdepth,alineNo));
        //println(formatted,cdepth,"cline",cline);
        alineNo++;
      }
      cdepth+=countAll(cline,"{");
      cdepth-=countAll(cline,"}");
    }
    for(ProgramLine l:lines){
      //println(l.toString());
    }
  }
  
  void drawError(){
    if(errored){
      //println("yayyy");
      int yoff = 0;
      for(int i = max(0,programcounter-3);i<min(programcounter+3,lines.size());i+=1){
        float tw = textWidth(lines.get(i).text)+lines.get(i).depth*30+40;
        if(i==programcounter){
          //draw the error code
          fill(255,0,0);
          rect(0,yoff*30,textWidth(error),30);
          fill(255);
          text(error,0,yoff*30+15);
          yoff++;
          //draw the line
          fill(50);
          rect(0,yoff*30,max(300,tw),30);
          fill(255,100,100);
          text(nf(i,2,0)+"|",5,yoff*30+15);
          text(lines.get(i).text,lines.get(i).depth*30+35,yoff*30+15);
        }else{
          fill(255);
          rect(0,yoff*30,max(300,tw),30);
          fill(50);
          text(nf(i,2,0)+"|",5,yoff*30+15);
          text(lines.get(i).text,lines.get(i).depth*30+35,yoff*30+15);
        }
        yoff++;
      }
      
    }
  }
  
  
  int getNextofLevel(int line,int level,int direction){
    for(int i = line;i>=0&&i<lines.size();i+=direction){
      //println("nxt of level",level,lines.get(i));
      if(lines.get(i).depth<=level){
        return i;
      }
    }
    return constrain(line+direction*lines.size(),0,lines.size()-1);
  }
  
  
  
  String[] getLineProp(ProgramLine line){
    if(line.lineProp!=null){
      return line.lineProp;
    }
    String[] prop= {"","",""};
    String mode ="subject";
    
    for(int i = 0;i<line.text.length();i++){
      char c = line.text.charAt(i);
      switch(mode){
        case "subject":
          if(prop[0].isEmpty()&&c==' '){
            continue;
          }
          if((allowedvarChars+".").contains(c+"")){
            prop[0]+=c;
            if(i==line.text.length()-1){
              mode="operation";
              i--;
              continue;
            }
          }else{
            mode="operation";
            i--;
            continue;
          }
        break;
        case "operation":
        
          if(prop[0].isEmpty()&&c==' '){
            continue;
          }
          //println("prop eval",c,prop[0]);
          boolean found = false;
          //reserved
          for(String s:reserved){
            if(s.equals(prop[0])){
              found=true;
              prop[1] = "keyword";
              mode = "params";
              break; 
            }
          }
          if(found){ i--; continue;}
           //variables
          if(memory.hasKey(prop[0])){
            found=true;
            prop[1] = "assignment";
            mode = "params"; 
          }
          if(found){ i--; continue;}
          
          if(c=='('){
            
            prop[1] = "function";
          }else{
            prop[1] = "assignment";
          }
          mode = "params";
           i--;
          //functions
          
        break;

        default:
          prop[2]=line.text.substring(i);
          i=line.text.length();
          
      }
      
    }
    line.lineProp = prop;
    return prop;
  }
  
  
  void runCycle(){
    //println("_____________BEGIN CYCLE of", name);
    if(errored){
      return;
    }
    if(finished&&!runOnce){
      reset();
    }
    wait = max(0,wait-1);
    while(!finished&&wait==0){
      runLine();
    }
    
    
  }
  
  void reset(){
    if(resetMemory){
      memory = new JSONObject();
    }
    finished=false;
    programcounter=0;
    wait=0;
  }
  
  void runLine(){
    if(programcounter>=lines.size()){
      finished = true;
      return;
    }
    ProgramLine line = lines.get(programcounter);
    int depth = line.depth;
    Iterator<String> iter = memory.keyIterator();
    ArrayList<String> toRemove = new ArrayList();
    while(iter.hasNext()){
      String key = iter.next();
      if(memory.getJSONObject(key).getInt("depth")>depth){
        toRemove.add(key);
        
        println("GC   removing: "+key);
      }
    }
    for(String key:toRemove){
      memory.remove(key);
    }
    
    
    
    String prop[] = getLineProp(line);
    String subject=prop[0];
    String operation=prop[1];
    //println("processing line:",fill(' ',depth*2)+line.text);
    switch(operation){
      case "function":
        //println("-Running function: "+line.text);
        String[] out = evalExpression(line.text);
        if(out[1].trim().length()>1){
          println("ERROR in function: ", out[1]);
          finished = true;
          errored = true;
          error = out[1];
          return;
        }
        programcounter++;
      break;
      case "assignment":
        //println("-"+subject+"-");
        if(!memory.hasKey(subject)){
          JSONObject jo = new JSONObject();
          jo.setString("value","");
          jo.setInt("depth",depth);
          memory.setJSONObject(subject,jo);
        }
        if(!line.text.contains("=")){
          println("ERROR in assignment: missing assignment operator '='");
          finished = true;
          errored = true;
          error = "ERROR in assignment: missing assignment operator '='";
          return;
        }
        int t = readToNext(line.text,"=",0).length();
        out = evalExpression(line.text.substring(t+1));
        if(out[1].length()>1){
          println("ERROR in assignment: ", out[1]);
          finished = true;
          errored = true;
          error = out[1];
          return;
        }
        String diff = line.text.substring(subject.length(),t).trim();
        if(diff.length()>0){
          
          
          //println("diff detected",t,line.text,diff);
          if(diff.charAt(0)!='['||diff.charAt(diff.length()-1)!=']'){
            println("Invalid assignment: ", subject+diff);
            finished = true;
          errored = true;
          error = out[1];
            return;
          }
          String[] o = evalExpression(trimEnds(diff));
          if(!o[1].isEmpty()||!isInt(o[0])){
            println("Invalid index assignment: ", o[1], ",",o[0]);
            finished = true;
          errored = true;
          error = out[1];
            return;
          }
          memory.getJSONObject(subject).setString("value",changeNthSplit(memory.getJSONObject(subject).getString("value"),",",int(o[0]),out[0]));
          programcounter++;
          break;
        }
        
        memory.getJSONObject(subject).setString("value",out[0]);
        
        //println("-assignment",t,line.text,line.text.substring(t+1),"value",out[0]);
        //println("subject",memory.getJSONObject(subject));
        
        
        programcounter++;
      break;
      case "keyword":
        switch(subject){
          case "wait":
            if(0==countAll(line.text," ")){
              wait=1;
              programcounter++;
              break;
            }
            out = evalExpression(line.text.split(" ",2)[1]);
            if(out[1].length()>1){
              println("ERROR in wait: ", out[1]);
              finished = true;
              errored = true;
              error = "ERROR in wait: "+out[1];
            }else if(!isInt(out[0])){
              println("ERROR in wait: wait time not number");
              finished = true;
              errored = true;
              error = "|ERROR in wait: wait time not number|"+out[1];
            }else{
              if(int(out[0])<0){
                finished = true;
                errored = true;
                error = "|Wait time cannot be negative|"+out[1];
                return;
              }
              wait=int(out[0]);
              programcounter++;
            }
            
          break;
          case "return":
           //println("returned!");
           if(0==countAll(line.text," ")){
             programcounter = lines.size();
              finished=true;
              break;
           }
           out = evalExpression(line.text.split(" ",2)[1]);
           if(out[1].length()>1){
              println("ERROR in return: ", out[1]);
              finished = true;
          errored = true;
          error = out[1];
            }else{
              returnvalue = out[0];
              programcounter = lines.size();
              finished=true;
              
            }
            
          break;
          case "else":
            println("|else requires if statement|");
            finished = true;
            errored = true;
            error = "|else requires if statement of same block level|";
            return;
          
          case "while":
          case "elif":
          case "if":
            String field = "";
            try{
              field = readToNext(line.text,"(",0);
            }catch(Exception e){
              println("|no conditional found|");
              finished = true;
              errored = true;
              error = "|no conditional found|";
              return;
            }
            String rawp = line.text.substring(field.length()+1,line.text.length()-1);
            //println("conditional field",subject,rawp);
            out = evalExpression(rawp);
            if(out[1].trim().length()>1){
              println("ERROR in if: ", out[1], "got", out[0]);
              finished = true;
              errored = true;
              error = out[1];
            }else if((!out[0].equals("\"true\"")&&!out[0].equals("\"false\""))){
              println("ERROR not a boolean expression: ", out[1], "got", out[0]);
              finished = true;
              errored = true;
              error = out[1];
              return;
            }
            else{
              //println("result of conditional",out[0]);
              if(out[0].equals("\"true\"")){
                programcounter++;
              }else{
                int i = getNextofLevel(line.lineNo+1,line.depth,1);
                String prop2[] = getLineProp(lines.get(i));
                if(!subject.equals("while")){
                  if(prop2[0].equals("else")&&lines.get(i).depth==line.depth){
                    i++;
                  }
                }
                //println(lines.get(i));
                /*while(prop2[0].equals("else")&&!subject.equals("while")){
                  i = getNextofLevel(i+1,line.depth,1);
                  prop2 = getLineProp(lines.get(i));
                }*/
                programcounter = i;
              }
            }
            
          break;
        }
      break;
      
    }
    if(!finished&&programcounter!=line.lineNo){
        //if program is eof in a nottop level block or is exiting from a lower level block...
        //println("current depth",depth, "moved depth",lines.get(programcounter).depth);
        if((programcounter>=lines.size()&&depth>0)||(programcounter<lines.size()&&lines.get(programcounter).depth<depth)){
          
          
          if(programcounter<lines.size()){
           ProgramLine origin = lines.get(programcounter);
           String newprop[] = getLineProp(lines.get(programcounter));
           if((newprop[0].equals("else")||newprop[0].equals("elif"))&&origin.blockExitJump!=-1){
            // programcounter=origin.blockExitJump;
           }
            //println("program counter properties:");
            //println(newprop);
            
            
            //if entering into an elif of else block from a lower block, skip the block.
            int mindepth = max(1,min(line.depth,lines.get(programcounter).depth));
            while(newprop[0].equals("else")||newprop[0].equals("elif")){
              //println("searching for next jump:",programcounter,lines.get(programcounter));
              programcounter = getNextofLevel(programcounter+1,mindepth-1,1);
              origin.blockExitJump = programcounter;
              if(lines.get(programcounter).depth>line.depth-1){
                finished = true;
                programcounter=lines.size();
                origin.blockExitJump = programcounter;
                break;
              }
              newprop = getLineProp(lines.get(programcounter));
              mindepth = max(1,min(mindepth,lines.get(programcounter).depth));
              //println("new location",programcounter);
              
            }
          }
          
          //scan backwards to check for loop conditions
          //println("hmm reached end of block, block header: "+ lines.get(getNextofLevel(line.lineNo,depth-1,-1)).text);
          for(int level = depth-1;level>=(programcounter>=lines.size()?0:lines.get(programcounter).depth);level--){
            ProgramLine head = lines.get(getNextofLevel(line.lineNo,level,-1));
            String[] headprop = getLineProp(head);
            if(headprop[0].equals("while")){
              programcounter = head.lineNo;
              return;
            }
          }
          
          
        }
        return;
      }
  }
  
  
  
  
  
  //output[0] - result, output[1] - errors
  
  String[] evalExpression(String line){
    
    //println("--evaluating",line);
    line=line.trim();
    if(line.length()==0){
      return new String[]{"\"\"",""};
    }
    if(memory.hasKey(line)){
      //println("--- mem",line);
      //println("subject",memory.getJSONObject(line));
      return new String[]{memory.getJSONObject(line).getString("value"),""};
    }
    if(isInt(line)){
      return new String[]{line,""};
    }
    //multisplit sectors filters out lines such as  [xxxx] abcd [yyy] but keeps lines lke [abcd[deeda]] and wow[aa][aad]
    if(']'==line.charAt(line.length()-1)&& multiSplitSectors(line,"([",")]",0)<=2){
      //println("---array reference",line);
      //if the variable is an array
      if('['==line.charAt(0)){
        String[] val = cachedMultiSplitofSameLevel(trimEnds(line),"([",")]",",",true,true);//test this function
        String[] val2 = new String[val.length];
        for(int i = 0;i<val.length;i++){
          String[] a = evalExpression(val[i]);
          if(a[1].length()!=0){return new String[]{"","array evaluation error: "+a[1]};}
          val2 [i] = a[0];
        }
        return new String[]{"["+deliminate(val2 ,",")+"]",""};
      }
      
      //if the variable is an array index reference
      // if line = abcd[0], arrayparams  = []
      // if line = abcd[0][sc[d]], arrayparams  = [sc[d]]
      String arrayparams = readForCharOnSameLevel(line,"([",")]",'[',line.length()-1,-1);
      //println("---array params",arrayparams);
      // if line = abcd[0][sc[d]], part  = abcd[0],sc[d]]
      String[] part = {line.substring(0,line.length()-arrayparams.length()),arrayparams.substring(1)}; 
      
      if(!contains(part[0],'[')&&!memory.hasKey(part[0])){
        if(!containsAny(part[0]," =+-*/%<>!&|")){
          return new String[]{"","array not found: "+part[0]};
        }
      }else{
        String index = part[1];
        index = index.substring(0,index.length()-1);
        
        String ires[];
        if(isInt(index)){ires=new String[]{""+index,""};}
        else{ires= evalExpression(index);}
        
        if(ires[1].length()!=0){return new String[]{"","index evaluation error: "+ires[1]};}
        if(!isInt(ires[0])){return new String[]{"","index not number: "+ires[0]};}
       //;
        String[] val = splitArray(evalExpression(part[0])[0]);
        //println("---",deliminate(val,"||"));
        String out = val[constrain(int(toRaw(ires[0])),0,val.length-1)];  //constrain index so no out of bounds error
        return new String[]{out,""};
      }
    }
    
    
    for(int z = 0;z<operators.length;z++){
      String op = operators[z]+"";
      if(op.length()==1){
        if(!contains(line,op.charAt(0))){
          continue;
        }
      }else{
        if(!contains(line,op)){
          continue;
        }
      }
      
      String[] plus =cachedMultiSplitofSameLevel(line,"([",")]",op,true,true); //bug was, it was splitting the things inside [ ]
      //
      if(plus.length>1){
        //println("Operator split:",Arrays.toString(plus));
        String[] a = evalExpression(plus[0]);
        String[] b = evalExpression(plus[1]);
        if(a[1].length()!=0||b[1].length()!=0){return new String[]{"","evaluation error: "+a[1]+b[1]};}
        if(a[0].length()==0||b[0].length()==0){return new String[]{"","|an arithmetic operator is missing a second argument: ("+plus[0]+op+plus[1]+")|"};}
        
        String sum = evalArtithmetic(a[0],op,b[0]);
        for(int i = 2;i<plus.length;i++){
          String[] c = evalExpression(plus[i]);
          if(c[1].length()!=0){return new String[]{"","evaluation error: "+c[1]};}
          sum = evalArtithmetic(sum,op,c[0]);
        }
        //println(sum);
        return new String[]{sum,""};
      }
    }
    if(line.charAt(0)=='"'&&line.charAt(line.length()-1)=='"'){
      return new String[]{line,""};
    }
    if(line.charAt(0)=='('&&line.charAt(line.length()-1)==')'){
      return evalExpression(line.substring(1,line.length()-1));
    }
    if(!contains(line,'(')){
      if(countAll(line,")")==1){
        return new String[]{"","|possible missing bracket: "+line+" |"};
      }
      return new String[]{"","|unknown identifier: "+line+" |"};
    }
    String field = readToNext(line,"(",0);
    String rawp = line.substring(field.length()+1,line.length()-1);   //////////------------------ returns errors on missing brackets.
    field = field.trim();
    //println("RAWP",rawp);
    String[] oparams = (cachedSplitofSameLevel(rawp,"(",")",",",true,true));
    String[] params = new String[oparams.length];
    arrayCopy(oparams,params);
    for(int i = 0;i<params.length;i++){
      String[] s = evalExpression(params[i]);
      if(s[1].length()!=0){println("error",s[1]); return new String[]{"",s[1]+"|Error in function call:"+field+"(...)|"};}
      params[i] = s[0];
    }
    String[] out = {"",""};
    //println(functions);
    for(FunctionExecutor fe:functions){
      out =  fe.execute(field,params);
      if(out!=null){
        //println("function out:",deliminate(out,","));
        break;
      }
    }
    if(out==null){return new String[]{"","|field '"+line+"' not found/supported|"};}
    if(out[1].length()!=0){return new String[]{"",out[1]+"|Error in function call:"+field+"(...)|"};}
    return out;
    
  }
  
  

}

String evalArtithmetic(String a,String operator,String b){
    a = trim(a);
    b = trim(b);
    boolean aint = isInt(a);
    boolean bint = isInt(b);
    boolean aarray = false,barray=false;
    //println("EVAL ARITH",a,operator,b);
    if(!aint){
      aarray = isArray(a);
      a = trimEnds(a);
      
    }
    if(!bint){
      barray = isArray(b);
      b = trimEnds(b);
    }
    
    if(aarray&&barray){
      
      String[] alist = {a};
      if(aarray){
        alist = splitArray("["+a+"]");
      }
      String[] blist = {b};
      if(barray){
        blist = splitArray("["+b+"]");
      }
      switch(operator){
        case "+":
        return "["+a+","+b+"]";
        case "-":
          ArrayList<String> subtract = new ArrayList();
          
          for(int i = 0;i<alist.length;i++){
            boolean inB=false;
            for(int j = 0;j<blist.length;j++){
              if(alist[i].equals(blist[j])){
                inB = true;
                break;
              }
            }
            if(inB){continue;}
            subtract.add(alist[i]);
          }
        return "["+deliminate(subtract.toArray(new String[]{}),",")+"]";
        case "*":
          ArrayList<String> mul = new ArrayList();
          
          for(int i = 0;i<alist.length;i++){
            boolean inB=false;
            for(int j = 0;j<blist.length;j++){
              if(alist[i].equals(blist[j])){
                inB = true;
                break;
              }
            }
            if(!inB){continue;}
            mul.add(alist[i]);
          }
        return "["+deliminate(mul.toArray(new String[]{}),",")+"]";
        
        case "/":
          ArrayList<String> anti = new ArrayList();
          
          for(int i = 0;i<alist.length;i++){
            boolean inB=false;
            for(int j = 0;j<blist.length;j++){
              if(alist[i].equals(blist[j])){
                inB = true;
                break;
              }
            }
            if(inB){continue;}
            anti.add(alist[i]);
          }
          for(int i = 0;i<blist.length;i++){
            boolean inA=false;
            for(int j = 0;j<alist.length;j++){
              if(blist[i].equals(alist[j])){
                inA = true;
                break;
              }
            }
            if(inA){continue;}
            anti.add(blist[i]);
          }
        return "["+deliminate(anti.toArray(new String[]{}),",")+"]";
        case "==":
          return "\""+(a.equals(b))+"\"";
        
      }
    }else if(aarray||barray){
      ArrayList<String> res = new ArrayList();
      String[] alist = splitArray("["+a+"]");
      String[] blist = splitArray("["+b+"]");
      for(int i = 0;i<max(blist.length,alist.length);i++){
        res.add(evalArtithmetic(alist[constrain(i,0,alist.length-1)],operator,blist[constrain(i,0,blist.length-1)]));
      }
      return "["+deliminate(res.toArray(new String[]{}),",")+"]";
    }
    switch(operator){
      case "+":
      if(aint&&bint){
        return ""+(int(a)+int(b));
      }else{
        return "\""+a+b+"\"";
      }
      
      case "-":
      if(aint&&bint){
        return ""+(int(a)-int(b));
      }else{
        String intersection ="";
        for(int i = 0;i<a.length();i++){
          for(int j = 0;j<b.length();j++){
            if(a.charAt(i)==b.charAt(j)){
              intersection+=a.charAt(i);
              break;
            }
          }
        }
        return intersection;
      }
      
      case "*":
      if(aint&&bint){
        return ""+(int(a)*int(b));
      }else{
        String output ="";
        if(aint&&!bint){
          for(int j = 0;j<int(a);j++){
            output+=b;
          }
        }
        else if(bint&&!aint){
          for(int j = 0;j<int(b);j++){
            output+=a;
          }
        }else{
          return "\""+a+"*"+b+"\"";
        }
        return "\""+output+"\"";
      }
      case "/":
      if(aint&&bint){
        return ""+(int(a)/int(b));
      }else{
        return "\""+a+"/"+b+"\"";
      }
      
      case "%":
      if(aint&&bint){
        return ""+(int(a)%int(b));
      }else{
        return "\""+a+"%"+b+"\"";
      }
      case ">":
      if(aint&&bint){
        return "\""+(int(a)>int(b))+"\"";
      }else{
        return "\""+a+">"+b+"\"";
      }
      case "<":
      if(aint&&bint){
        return "\""+(int(a)<int(b))+"\"";
      }else{
        return "\""+a+"<"+b+"\"";
      }
      case ">=":
      if(aint&&bint){
        return "\""+(int(a)>=int(b))+"\"";
      }else{
        return "\""+a+">="+b+"\"";
      }
      case "<=":
      if(aint&&bint){
        return "\""+(int(a)<=int(b))+"\"";
      }else{
        return "\""+a+"<="+b+"\"";
      }
      case "==":
      return "\""+(a.equals(b))+"\"";
      case "!=":
      return "\""+(!a.equals(b))+"\"";
      case "&":
      return "\""+(a.equals("true")&&b.equals("true"))+"\"";
      case "|":
      
      return "\""+(a.equals("true")||b.equals("true"))+"\"";
      
      
    }
    return "";
  }
