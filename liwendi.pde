import gab.opencv.*;
import processing.video.*;
import java.awt.*;

Capture video;
OpenCV opencv;
ArrayList<myFolder> folderlist=new ArrayList<myFolder>();

int floderMoved=-1;      //memorize the document number ready to move
int move_x;      //momorize the born position of the document
int move_y;
int start_x;
int start_y;
boolean move=false;
boolean M=false;// pressment
boolean[] floders=new boolean[12];
PImage mouse;
PImage selectfloder;

void setup() {
  size(1200, 480);
  background(255);
  video = new Capture(this, 640, 480);
  opencv = new OpenCV(this, 640, 480);
  opencv.loadCascade("aGest.xml");  //load in the xml document for gesture monitoring
  for(int i=0;i<4;i++){
      folderlist.add(new myFolder(672+132*(i%4),50+150*(i/4),0,"folder "+(i+1)));
  }
  for(int i=0;i<12;i++){
    if (i<4) floders[i]=false; else floders[i]=true;
  }
  mouse=loadImage("mouse.png");
  selectfloder=loadImage("selectfloder.png");
  
  video.start();
}

void draw() {
  background(255);
   //document shoeing
  for(int i=0;i<folderlist.size();i++){
      myFolder floder=(myFolder)folderlist.get(i);
      floder.display();
  }
  opencv.loadImage(video);

  image(video, 0, 0 );
  //image(mouse,mouseX,mouseY,42,57);
  noFill();
  stroke(0, 255, 0);
  strokeWeight(3);
  Rectangle[] hands = opencv.detect();
  //println(faces.length);
 //print the gesture detection window
  for (int i = 0; i < hands.length; i++) {
    //println(hands[i].x + "," + hands[i].y);
    rect(hands[i].x, hands[i].y, hands[i].width, hands[i].height);
    mouseX=hands[i].x+640;
    mouseY=hands[i].y;
    image(mouse,mouseX,mouseY,42,57);
    checktouchfolder(mouseX,mouseY);
  }
  //checktouchfolder(mouseX,mouseY);
  image(mouse,mouseX,mouseY,42,57);
}

void captureEvent(Capture c) {
  c.read();
}



//
void movenewplace(){
  println("new position");
  int y=mouseY/150+1;
  int x=(mouseX-672)/132+1;
  int newxpoision=640+132*x-100;
  int newypoision=150*y-100;
  //check if there is any overlapping so that to put in next position
  int last=folderlist.size()-1;
  int last_x=folderlist.get(last).x;
  int last_y=folderlist.get(last).y;
  if(newxpoision==last_x&&newypoision==last_y){
    newxpoision=672+132*(last%4);
    newypoision=50+150*(last/4);
  }
  folderlist.get(floderMoved).x=newxpoision;
  folderlist.get(floderMoved).y=newypoision;
  
}

//when the folder is overlapping during moving
void movefolderwhileoverlapping(int over_floder){
   if(floderMoved<over_floder){
       String name=folderlist.get(floderMoved).name;
       for(int k=floderMoved;k<over_floder;k++){
         folderlist.get(k).name=folderlist.get(k+1).name;
       }
       folderlist.get(over_floder).name=name;
     }else{
       String name=folderlist.get(floderMoved).name;
       for(int k=floderMoved;k>over_floder;k--){
         folderlist.get(k).name=folderlist.get(k-1).name;
       }
       folderlist.get(over_floder).name=name;
       
     }
     
     folderlist.get(floderMoved).x=start_x;
     folderlist.get(floderMoved).y=start_y;
}
int checktouchfolder(int x,int y){
 for(int i=0;i<folderlist.size();i++){
  myFolder floder=folderlist.get(i);
  if(x>=floder.x&&x<=floder.x+100&&y>=floder.y&&y<=floder.y+100){
    image(selectfloder,floder.x,floder.y,100,100);
    start_x=floder.x;
    start_y=floder.y;
    return i;
  }
 }
 return -1;
}

int checkanothertouchfolder(int x,int y){
 for(int i=0;i<folderlist.size();i++){
  myFolder floder=folderlist.get(i);
  if(x>=floder.x&&x<=floder.x+100&&y>=floder.y&&y<=floder.y+100&&i!=floderMoved){
    return i;
  }
 }
 return -1;
}

void keyPressed(){
 int i=checktouchfolder(mouseX,mouseY);
 if(i!=-1){//when the mouse press a folder
  if(key=='c'||key=='C'){
   int num=folderlist.size();
   int minus=folderlist.get(i).copy;
   int bianhao=1;
   if(i+2<=num){//document ready to copy is in the middle
       folderlist.get(i).copy=minus+1;
       folderlist.add(new myFolder(672+132*(num%4),50+150*(num/4),0,"folder "+(num-minus)));
       folderlist.get(i+1).name="C_"+folderlist.get(i).name;
       for(int k=i+2;k<i+minus+2;k++){
         folderlist.get(k).name="C_"+folderlist.get(i).name+"("+bianhao+")";
         bianhao++;
       }
       for(int k=folderlist.size()-1;k>=i+minus+2;k--){
         folderlist.get(k).name="floder "+(num-minus); 
         num--;
       } 
   }else{
       if(minus==0){
         folderlist.add(new myFolder(672+132*(num%4),50+150*(num/4),0,"C_"+folderlist.get(i).name));
       }else{
         folderlist.add(new myFolder(672+132*(num%4),50+150*(num/4),0,"C_"+folderlist.get(i).name+"("+minus+")"));
       }

     
   }
 }else if(key=='m'||key=='M'){
   floderMoved=i;
   myFolder floder=folderlist.get(floderMoved);
   if(!M){
    start_x=floder.x;
    start_y=floder.y; 
   }
   move_x=mouseX;
   move_y=mouseY;
   floder.x=mouseX-50;
   floder.y=mouseY-50; 
   M=true;
 }else if(key=='d'||key=='D'){
   folderlist.remove(i);
 }  
 }
 if(key=='n'||key=='N'){
   int num=folderlist.size();
   int copies=0;
   for(int k=0;k<num;k++){
     copies=folderlist.get(k).copy+copies;
   }
   folderlist.add(new myFolder(672+132*(num%4),50+150*(num/4),0,"folder "+(num+1-copies)));
 }  
}


void keyReleased(){//check the position of the mouse overlapping or not
  if(M){
            boolean flag=false;
            int over_floder=0;
            for(int i=0;i<folderlist.size();i++){
                myFolder floder=folderlist.get(i);
                if(mouseX>=floder.x&&mouseX<=floder.x+100&&mouseY>=floder.y&&mouseY<=floder.y+100&&i!=floderMoved){
                   over_floder=i;
                   flag=true;
                   }
               }
            if(flag){//overlap with some other
               movefolderwhileoverlapping(over_floder);
            }else{//no overlap
              //check with between
              if((move_x+50)<1200){
                    println("compare the next position,move_x:"+move_x);
                    over_floder=checkanothertouchfolder(move_x+50,move_y);
                    if(over_floder!=-1){
                       println("someone next"+over_floder);
                       movefolderwhileoverlapping(over_floder-1);
                       return;
                    }else{
                       println("nothing next ");
                       over_floder=checkanothertouchfolder(move_x,move_y+55);
                    }
                       println("over_floder is :"+over_floder);
                    if(over_floder!=-1){
                       movefolderwhileoverlapping(over_floder);
                       return;
                    }else{
                       over_floder=checkanothertouchfolder(move_x+50,move_y+55);
                    }
                    if(over_floder!=-1){
                       movefolderwhileoverlapping(over_floder-1);
                       return;
                    }else{
                       movenewplace();
                       
                    }
              }else{
                    println("compare the front position,move_x:"+move_x);
                    over_floder=checkanothertouchfolder(move_x-50,move_y);
                    if(over_floder!=-1){
                       movefolderwhileoverlapping(over_floder);
                       return;
                    }else{
                       over_floder=checkanothertouchfolder(move_x,move_y+55);
                    }
                    if(over_floder!=-1){
                       movefolderwhileoverlapping(over_floder);
                       return;
                    }else{
                      over_floder=checkanothertouchfolder(move_x-50,move_y+55);
                    }
                    if(over_floder!=-1){
                       movefolderwhileoverlapping(over_floder-1);
                       return;
                    }else{
                       movenewplace();
                       
                    }
              }
              
            } 
    M=false;
  }
}


class myFolder{
  PImage floder;
  int x;
  int y;
  int copy;
  String name;
  myFolder(int x,int y,int copy,String name){
    this.x=x;
    this.y=y;
    this.copy=copy;
    this.name=name;
    floder=loadImage("floder.png");
  }
  void display(){
   image(floder,x,y,100,100); 
   textSize(16);
   fill(0,102,153);
   float width=textWidth(name);
   float x_p=(100-width)/2;
   text(name,x+x_p,y+115);
  }
}

