//Whether you are in game or not.
boolean inGame;
//This is the code for menu GUI
/*
  0=main menu
  1=credits
  Settings will not exist in our game jam version.
*/
int menuState=0;
//Main menu GUI
CButton newGameMenu;
CButton continueGameMenu;
CButton creditsMenu;
CButton quitMenu;
//Credits GUI
Label creditsStuff;
CButton creditsBackButton;

//This is data for the in-game GUI. selectedOrganism is used for both species and individual organisms.
Organism selectedOrganism;
boolean organismIsSelected=false;
//These will be displayed upon selecting an organism.
ArrayList<Component> displayUponSelected;
//These will be displayed when a specific organism is not selected.
ArrayList<Component> displayNormal;
CContainer bottomBar;
CContainer topRightBar; 
CDropdown inGameMenuDropdown;
String[] labels={"Main menu","Credits","Quit"};
CListSelect menu;
//Label to display actual HP value. Image will be inside Textbox location as well which will change size depending on parameter.
Label hpBar;
//Label to display actual Energy value. Image will be inside Textbox location as well which will change size depending on parameter.
Label energyBar;
//Container to contain all the components necessary for display of other parameters. Most likely at this stage I will just display these as text.
CContainer parameterContainer;
public void initialiseGUI() {
    //This is the main menu GUI
    newGameMenu=new CButton("newMenu","New game", 50,50,300,60) {
      {
        this.ie = new InputEvent() {
             
            public void onMousePressed(Component c){
                inGame=true;
                menuState=0;
                //TODO: add method to start new game using title-created species.
            }
            public void onKeyPressed(Component c){
            
            }  
          };
      }
    };
    continueGameMenu=new CButton("continueMenu","Continue game (Note: no local save, doesn't exist yet)", 50,150,300,60){
      {
        this.ie = new InputEvent() {
             @Override
          public void onMousePressed(Component c){
              inGame=true;
              menuState=0;
          }
          @Override
          public void onKeyPressed(Component c){
          
          }  
        };
      }
    };
    creditsMenu=new CButton("creditsMenu","Credits", 50,250,300,60){
      {
        this.ie = new InputEvent() {
             @Override
          public void onMousePressed(Component c){
              menuState=1;
          }
          @Override
          public void onKeyPressed(Component c){
          
          }  
        };
      }
    };
    quitMenu=new CButton("quitMenu","Quit", 50,350,300,60){
      {
        this.ie = new InputEvent() {
             @Override
          public void onMousePressed(Component c){
              exit();
          }
          @Override
          public void onKeyPressed(Component c){
          
          }  
        };
      }
    };
    //This is the credits GUI
    creditsStuff=new Label("credits",350,150,300,300,"Credits go here");
    creditsBackButton=new CButton("backCredits", "Back", 350, 550,300,100) {
      {
        this.ie = new InputEvent() {
             @Override
          public void onMousePressed(Component c){
              menuState=0;
          }
          @Override
          public void onKeyPressed(Component c){
          
          }  
        };
      }
    };
    //This is the ingame GUI
    bottomBar=new CContainer("bottomBar",0,435,1000,65);
    topRightBar=new CContainer("topRightBar",800,40,150,200);
    inGameMenuDropdown=new CDropdown("inGameMenuDropDown",10,10,120,50,20,20);
    menu=new CListSelect("menu",labels,0,0,120,200);
    
}

void displayGUI() {
  if (inGame) {
    if (organismIsSelected) {
        
    } else {
        
    }
  } else {
      switch (menuState) {
          case 0:
            //Main menu
            break;
          case 1:
            //Credits
          break;
          
      }
  }
     
}
