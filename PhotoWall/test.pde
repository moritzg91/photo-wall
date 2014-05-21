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

Minim minim;
AudioPlayer song;

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

void setup()
{
  size(640,480);
 
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

  minim = new Minim(this);
  song = minim.loadFile("ding.mp3");  
  
  
  
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
  if (leftHand.y < leftSh.y || (rightHand.x < torso.x && rightHand.y < leftSh.y))
  {  
      fill(255, 0, 0);
      rect(40,40,40,40);
  }
  //recognizing TOP RIGHT picture
  else if (rightHand.y < rightSh.y || (leftHand.x > torso.x && leftHand.y < rightSh.y))
  {
    fill(255, 0, 0);
    rect(600,40,40,40);
  }
  //recognizing BOTTOM LEFT picture -- want between bottom of elbow and top of hip
  else if ((leftHand.y < leftHip.y && leftHand.y > leftEl.y) || (rightHand.x < torso.x && rightHand.y < leftHip.y && rightHand.y > leftEl.y))
  {
    fill(255, 0, 0);
    rect(40,400,40,40);
  }
  //recognizing BOTTOM RIGHT picture
  else if ((rightHand.y < rightHip.y && rightHand.y > rightEl.y) || (leftHand.x < torso.x && leftHand.y < rightHip.y && leftHand.y > rightEl.y))
  {
    fill(255, 0, 0);
    rect(600,400,40,40);
  }
}

boolean isHold(long newTime){
 if (origTime == 0)
 {
   origTime = newTime;
   return false;
 } else if (newTime > origTime+3)
 {
   origTime = 0;
   return true;
 } else
 {
   return false; 
 }
}

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

