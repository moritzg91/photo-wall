/* --------------------------------------------------------------------------
 * SimpleOpenNI User Test
 * --------------------------------------------------------------------------
 * Processing Wrapper for the OpenNI/Kinect 2 library
 * http://code.google.com/p/simple-openni
 * --------------------------------------------------------------------------
 * prog:  Max Rheiner / Interaction Design / Zhdk / http://iad.zhdk.ch/
 * date:  12/12/2012 (m/d/y)
 * ----------------------------------------------------------------------------
 */

import SimpleOpenNI.*;
import ddf.minim.*;
import java.lang.*;
import java.awt.Frame;
import java.util.*;



SimpleOpenNI  context;
color[]       userClr = new color[]{ color(255,0,0),
                                     color(0,255,0),
                                     color(0,0,255),
                                     color(255,255,0),
                                     color(255,0,255),
                                     color(0,255,255)
                                   };
PVector com = new PVector();                                  
PVector com2d = new PVector(); 
int origTime = 0; //attempting to use this to determine if the hand is being held for more than 3 seconds in a quadrant

Boolean mailFlag = false;

Boolean mailSent = false;

Boolean recognizedPointing = false;

Float gKinectDistFromWall = 15.0*displayWidth/(12.0); // unit is INCHES

PVector gLeftHand, gRightHand, gRightSh, gLeftSh, gTorso, gRightHip, gLeftHip, gRightEl, gLeftEl;

Integer handTimer;
Integer handTimerThreshold = 3*30;

Integer previousQuadrant = 0;
Integer currentQuadrant = 0;

PFrame f;
PProjApplet picoProjectorApplet;

void setup()
{
  size(640,480);
  PFrame f = new PFrame();
  context = new SimpleOpenNI(this);
  if(context.isInit() == false)
  {
     println("Can't init SimpleOpenNI, maybe the camera is not connected!");
     exit();
     return;  
  }
 
  // enable depthMap generation
  context.enableDepth();
   
  // enable skeleton generation for all joints
  context.enableUser();
 
  background(200,0,0);
  
  stroke(0,0,255);
  strokeWeight(3);
  smooth();
  
  frameRate(30);
  
  setupTwitter();
  drawTwitter();
  
}

void draw()
{
  // update the cam
  context.update();
 
  // draw depthImageMap
  //image(context.depthImage(),0,0);
  image(context.userImage(),0,0);
 
  // draw the skeleton if it's available
  int[] userList = context.getUsers();
  for(int i=0;i<userList.length;i++)
  {
    if(context.isTrackingSkeleton(userList[i]))
    {
      stroke(userClr[ (userList[i] - 1) % userClr.length ] );
      drawSkeleton(userList[i]);
    }      
    
    // draw the center of mass
    if(context.getCoM(userList[i],com))
    {
      context.convertRealWorldToProjective(com,com2d);
      stroke(100,255,0);
      strokeWeight(1);
      beginShape(LINES);
        vertex(com2d.x,com2d.y - 5);
        vertex(com2d.x,com2d.y + 5);

        vertex(com2d.x - 5,com2d.y);
        vertex(com2d.x + 5,com2d.y);
      endShape();
     
      fill(0,255,100);
      text(Integer.toString(userList[i]),com2d.x,com2d.y);
    }
  }    
}

// draw the skeleton with the selected joints
void drawSkeleton(int userId)
{
  // to get the 3d joint data
   
  PVector leftHand = new PVector();
  PVector rightHand = new PVector();
  PVector rightSh = new PVector();
  PVector leftSh = new PVector();
  PVector torso = new PVector();
  PVector rightHip = new PVector();
  PVector leftHip = new PVector();
  PVector rightEl = new PVector();
  PVector leftEl = new PVector();
  
  
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_HAND,leftHand);
  context.convertRealWorldToProjective(leftHand, leftHand);
  
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HAND,rightHand);
  context.convertRealWorldToProjective(rightHand, rightHand);
  
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_SHOULDER,rightSh);
  context.convertRealWorldToProjective(rightSh, rightSh);
  
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_SHOULDER,leftSh);
  context.convertRealWorldToProjective(leftSh, leftSh);
  
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_TORSO,torso);
  context.convertRealWorldToProjective(torso, torso);
  
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HIP,rightHip);
  context.convertRealWorldToProjective(rightHip, rightHip);
  
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_HIP,leftHip);
  context.convertRealWorldToProjective(leftHip, leftHip);
  
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_ELBOW,rightEl);
  context.convertRealWorldToProjective(rightEl, rightEl);
  
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_ELBOW,leftEl);
  context.convertRealWorldToProjective(leftEl, leftEl);
  
  fill(0,0,255);
  ellipse(leftHand.x,leftHand.y, 30, 30);
  //println("left hand x: " +leftHand.x+"      left hand y: "+leftHand.y);
  
  fill(0,0,255);
  ellipse(rightHand.x,rightHand.y, 30, 30);
  //println("right hand x: " +rightHand.x+"      right hand y: "+rightHand.y);
  
  
  //recognizing TOP LEFT picture
  if (leftHand.y < leftSh.y + 40 || (rightHand.x < torso.x && rightHand.y < leftSh.y + 40))
  {  
      recognizedPointing = true;
    
      currentQuadrant = 1;
      if (currentQuadrant != previousQuadrant) {
        handTimer = 0;
        mailSent = false;
      }
      Contact recipient = new Contact("Anne Marie Piper","ampiper@u.northwestern.edu");
      
      fill(255, 0, 0);
      rect(40,40,40,40);
      
      checkSendMail(recipient);
      
      previousQuadrant = currentQuadrant;
  }
  //recognizing TOP RIGHT picture
  else if (rightHand.y < rightSh.y + 40 || (leftHand.x > torso.x && leftHand.y < rightSh.y + 40))
  {
    recognizedPointing = true;
    
    currentQuadrant = 2;
      if (currentQuadrant != previousQuadrant) {
        handTimer = 0;
        mailSent = false;
      }
      Contact recipient = new Contact("Moritz Gellner","moritzgellner2014@u.northwestern.edu");
      
    fill(255, 0, 0);
    rect(600,40,40,40);
    checkSendMail(recipient);
    previousQuadrant = currentQuadrant;
  }
  //recognizing BOTTOM LEFT picture -- want between bottom of elbow and top of hip
  else if ((leftHand.y < leftHip.y && leftHand.y > leftEl.y) || (rightHand.x < torso.x && rightHand.y < leftHip.y && rightHand.y > leftEl.y))
  {
    recognizedPointing = true;
    
    currentQuadrant = 3;
      if (currentQuadrant != previousQuadrant) {
        handTimer = 0;
        mailSent = false;
      }
      Contact recipient = new Contact("Robin Brewer","rnbrewer@u.northwestern.edu");
    fill(255, 0, 0);
    rect(40,400,40,40);
    checkSendMail(recipient);
    previousQuadrant = currentQuadrant;
  }
  //recognizing BOTTOM RIGHT picture
  else if ((rightHand.y < rightHip.y && rightHand.y > rightEl.y) || (leftHand.x < torso.x && leftHand.y < rightHip.y && leftHand.y > rightEl.y))
  {
    recognizedPointing = true;
    
    currentQuadrant = 4;
      if (currentQuadrant != previousQuadrant) {
        handTimer = 0;
        mailSent = false;
      }
      Contact recipient = new Contact("Carson Potter","cp3192@gmail.com");
    fill(255, 0, 0);
    rect(600,400,40,40);
    checkSendMail(recipient);
    previousQuadrant = currentQuadrant;
  } else {
    // assume people are right handed if no other info is present
    
    handTimer = 0;
    currentQuadrant = 0;
    previousQuadrant = 0;
    recognizedPointing = false;
  }
  
  gLeftHand = leftHand;
  gRightHand = rightHand;
  gRightSh = rightSh;
  gLeftSh = leftSh;
  gTorso = torso;
  gRightHip = rightHip;
  gLeftHip = leftHip;
  gRightEl = rightEl;
  gLeftEl = leftEl;
}

void checkSendMail(Contact recipient) {
      if (!mailSent && handTimer > handTimerThreshold) { //make sure mail is only sent once
        mailSent = true;
        Contact sender = new Contact("Portrait Pigeon","robinbrewer10@gmail.com");
        
        if (mailFlag == true)
        {
        sendMail(recipient,sender,"You're Awesome","The end of the quarter is approaching. I thought you should know that you're awesome and keep up the great work!\n\n(Robin)");
        } else {
          if (recipient.email == "moritzgellner2014@u.northwestern.edu"){
            tweet("mogellner"); 
          } else if (recipient.email == "ampiper@u.northwestern.edu"){
            tweet("annemarie_piper");
          } else if (recipient.email == "rnbrewer@u.northwestern.edu"){
            tweet("_rnbrewer");
          } else {
            tweet("cpottamus");
          }
        }
        
        handTimer = 0;
      } else {
        handTimer += 1;
      }
}

//boolean isHold(long newTime){
// if (origTime == 0)
// {
//   origTime = newTime;
//   return false;
// } else if (newTime > origTime+3)
// {
//   origTime = 0;
//   return true;
// } else
// {
//   return false; 
// }
//}

// -----------------------------------------------------------------
// SimpleOpenNI events

void onNewUser(SimpleOpenNI curContext, int userId)
{
  
  
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");
  //song.play();
 
  curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
  song.close();
  minim.stop();
  //super.stop();
}

void onVisibleUser(SimpleOpenNI curContext, int userId)
{
  
  song.play();
  //println("onVisibleUser - userId: " + userId);
  
}

/*void stop()
{
  // the AudioPlayer you got from Minim.loadFile()
  song.close();
  minim.stop();
 
  // this calls the stop method that 
  // you are overriding by defining your own
  // it must be called so that your application 
  // can do all the cleanup it would normally do
 super.stop();
}*/

public class PFrame extends Frame {
    public PFrame() {
        setBounds(100,100,displayWidth,displayHeight);
        picoProjectorApplet = new PProjApplet();
        add(picoProjectorApplet);
        picoProjectorApplet.init();
        show();
    }
}

public class PProjApplet extends PApplet {
    public void setup() {
        background(255,255,255);
        frameRate(30);
        size(displayWidth, displayHeight);
        smooth();
    }

    public void draw() {
        background(255,255,255);
        if (gLeftHand != null && gRightHand != null) {
          // Float[] handPosn = calcHandPosn(gHand,gElbow,gKinectDistFromWall);
          // println("HAND POSN: " + gLeftHand.x*displayWidth/640 + ", " + gLeftHand.y*displayHeight/480);
          //fill(0,0,255);
          //ellipse(gLeftHand.x*displayWidth/640,gLeftHand.y*displayHeight/480, 80, 80);
          // draw translucent rect
          drawQuadrantRect(currentQuadrant);
          
          //fill(0,255,0);
          //ellipse(gRightHand.x*displayWidth/640,gRightHand.y*displayHeight/480, 80, 80);
        }
      }
      
    public void drawQuadrantRect(Integer quadrant) {
  
      if (quadrant == 1) { // top left
          if (gRightHand.x < gTorso.x && gRightHand.y < gLeftSh.y + 40) {
            fill(0,255,0,100);
          } else {
            fill(0,0,255,100);
          }
        rect(0,0,displayWidth/2,displayHeight/2);
      } else if (quadrant == 2) { // top right
          if (gRightHand.y < gRightSh.y + 40) {
            fill(0,255,0,100);
          } else {
            fill(0,0,255,100);
          }
        rect(displayWidth/2,0,displayWidth/2,displayHeight/2);
      } else if (quadrant == 3) { // bottom left 
          if (gRightHand.x < gTorso.x && gRightHand.y < gLeftHip.y && gRightHand.y > gLeftEl.y) {
            fill(0,255,0,100);
          } else {
            fill(0,0,255,100);
          }
        rect(0,displayHeight/2,displayWidth/2,displayHeight/2);
      } else if (quadrant == 4) { // bottom right
          if (gRightHand.y < gRightHip.y && gRightHand.y > gRightEl.y) {
            fill(0,255,0,100);
          } else {
            fill(0,0,255,100);
          }
        rect(displayWidth/2,displayHeight/2,displayWidth/2,displayHeight/2);
      }
} 
}
