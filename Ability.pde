class Ability {
    String name;
    String desc;
    //Parameters
    boolean AOE;
    /*
      Only accepted AOE types are:
        - Cone: sprays a cone in front of creature in direction of position from current point
        - Spray: sprays in a circle in the indicated position from current point. 
    */
    String AOEType;
    float range;
    float angleSize;
    //Used to determine how long the creature the ability will remain there.
    float abilityDuration;
    //If the enemies remain inside the AOE, if this is a reasonable value then they will gain another stack of effects.
    float refreshDuration=Float.MAX_VALUE;
    ArrayList<String> effectsOnOthers=new ArrayList();
    ArrayList<String> effectsOnSelf=new ArrayList();
    ArrayList<Float> durationOnSelf=new ArrayList();
    ArrayList<Float> durationOnOthers=new ArrayList();
    ArrayList<Organism> targetOrganisms=new ArrayList();
    Organism caster;
    Ability (String filename, int index) {
        String JSONfile=getFile(filename);
        JSONObject json=parseJSONObject(JSONfile);
        JSONArray abilities=json.getJSONArray("abilities");
        JSONObject ability=(JSONObject)abilities.get(index);
        boolean selfTargetting=ability.getBoolean("self targetting",true);
        name=ability.getString("name");
        desc=ability.getString("desc");
        abilityDuration=ability.getFloat("ability duration",0);
        range=ability.getFloat("range",0);
        angleSize=ability.getFloat("angle size",0);
        AOE=ability.getBoolean("aoe",false);
        AOEType=ability.getString("aoe type","Circular");
        refreshDuration=ability.getFloat("refresh duration",Float.MAX_VALUE);
        JSONArray selfEffects=ability.getJSONArray("self effects");
        
        for (int i=0; i<selfEffects.size(); i++) {
            JSONObject effect=(JSONObject)(selfEffects.get(i));
            effectsOnSelf.add(effect.getString("name"));
            durationOnSelf.add(effect.getFloat("duration",0));
        }
        if (!selfTargetting) {
            JSONArray othersEffects=ability.getJSONArray("effects on others");
            for (int i=0; i<othersEffects.size(); i++) {
                JSONObject effect=(JSONObject)(othersEffects.get(i));
                effectsOnOthers.add(effect.getString("name"));
                durationOnOthers.add(effect.getFloat("duration",0));
            }
        }
    }
    //Self-targetting ability
    Ability (String name, String desc, String[] traitsOnSelf,float[] duration) {
        this.name=name;
        this.desc=desc;
        for (int i=0; i<traitsOnSelf.length; i++) {
           effectsOnSelf.add(traitsOnSelf[i]); 
           durationOnSelf.add(duration[i]);
        }
    }
    //Targetting others ability
    Ability (String name, String desc, String[] traitsOnSelf,String[] traitsOnOthers, float[] selfDuration, float[] othersDuration, boolean AOE, String AOE_type, float range, float abilityDuration,float refreshDuration) {
        this.refreshDuration=refreshDuration;
        this.abilityDuration=abilityDuration;
        this.AOE=AOE;
        this.AOEType=AOE_type;
        this.range=range;
        this.name=name;
        this.desc=desc;
        for (int i=0; i<traitsOnSelf.length; i++) {
           effectsOnSelf.add(traitsOnSelf[i]); 
           durationOnSelf.add(selfDuration[i]);
        }
        for (int i=0; i<traitsOnOthers.length; i++) {
           effectsOnSelf.add(traitsOnOthers[i]); 
           durationOnOthers.add(othersDuration[i]);
        }
    }
    //Targetting others ability with AOE
    Ability (String name, String desc, String[] traitsOnSelf,String[] traitsOnOthers, float[] selfDuration, float[] othersDuration, boolean AOE, String AOE_type, float range, float abilityDuration, float cone_angle,float refreshDuration) {
        this.refreshDuration=refreshDuration;
        this.abilityDuration=abilityDuration;
        this.AOE=AOE;
        this.AOEType=AOE_type;
        this.range=range;
        this.angleSize=cone_angle;
        this.name=name;
        this.desc=desc;
        for (int i=0; i<traitsOnSelf.length; i++) {
           effectsOnSelf.add(traitsOnSelf[i]); 
           durationOnSelf.add(selfDuration[i]);
        }
        for (int i=0; i<traitsOnOthers.length; i++) {
           effectsOnSelf.add(traitsOnOthers[i]); 
           durationOnOthers.add(othersDuration[i]);
        }
    }
    public float cooldown;
    //For self-casting and targetting
    public void cast(Organism o, ArrayList<Organism> targetOrganisms, float timeCast) {
        if ((time-timeCast)%refreshDuration==0) {
            for (int i=0; i<effectsOnSelf.size(); i++) {
                o.addTraitTemp(getTraitByName(effectsOnSelf.get(i),"data\traits"),durationOnSelf.get(i));
            }
            for (Organism org: targetOrganisms) {
                for (int i=0; i<effectsOnOthers.size(); i++) {
                    org.addTraitTemp(getTraitByName(effectsOnOthers.get(i),"data\traits"),durationOnOthers.get(i));
                }
            }
            
        }
        
    }   
    //For being castedUpon
    public void castAOE(Organism o) {
        for (int i=0;i<effectsOnOthers.size(); i++) {
           o.addTraitTemp(getTraitByName(effectsOnOthers.get(i),"data\traits"),durationOnOthers.get(i)); 
        }
    }
    //For casting in AOE
    public void cast(Organism o, float x, float y,float timeCast) {
        if (!o.abilityCooldowns.containsKey(name)) {
            if (AOE) {
              //Continue with AOE application.
              
                  if (AOEType=="Cone") {
                     float angleOfCast=atan2(y-o.y,x-o.x);
                     float[] origin=new float[2];
                     //Origin of cone
                     origin[0]=o.x+2*cos(angleOfCast);
                     origin[1]=o.y+2*sin(angleOfCast);
                     for (ArrayList<Organism> orgs: OrganismManager.organisms.values())
                     {
                       for (Organism organism: orgs) {
                           if (isInCone(origin[0],origin[1],organism.x,organism.y,range,angleOfCast,angleSize)&&(time-timeCast)%refreshDuration==0) {
                               castAOE(organism);
                           }
                       }
                     }
                  } else {
                      for (ArrayList<Organism> orgs: OrganismManager.organisms.values())
                       {
                         for (Organism organism: orgs) {
                             if ((organism.x-x)*(organism.x-o.x)+(organism.y-y)*(organism.y-o.y)<=range*range) {
                                castAOE(organism); 
                             }
                         }
                       }
                  }
            } else {
               cast(o,targetOrganisms,timeCast); 
            }
            if (time-timeCast>abilityDuration) {
                o.abilityCooldowns.put(this.name,cooldown);
            }
        } 
    }
    public boolean isInCone(float x,float y,float x2,float y2, float range, float angleOfCone, float angleSize) {
        float angleToPoint=atan2(y2-y,x2-x);
        float minAngle=angleOfCone-angleSize/2;
        float maxAngle=angleOfCone+angleSize/2;
        maxAngle=targetAng(minAngle,maxAngle);
        angleToPoint=targetAng(angleToPoint,maxAngle);
        float distsqrd=((y2-y)*(y2-y)+(x2-x)*(x2-x));
        
        return minAngle<angleToPoint&&angleToPoint<maxAngle&&(distsqrd<range*range);
    }
}
public Ability getAbilityByName(String filename,String name) {
  String JSONfile=getFile(filename);
  JSONObject json=parseJSONObject(JSONfile);
  JSONArray abilities=json.getJSONArray("abilities");
  for (int i=0; i<abilities.size(); i++) {
        JSONObject trait= abilities.getJSONObject(i);
        String testName = getStringJSON(trait, "name_not_found", "name");
        if (name==testName) {
           return new Ability(filename,i); 
        }
    }
  return null;
}
