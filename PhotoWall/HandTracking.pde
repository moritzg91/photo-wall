Float[] calcHandPosn(PVector hand, PVector elbow, Float kinectDistFromWall) {
  Float[] diagonal = new Float[]{
                          hand.x - elbow.x,
                          hand.y - elbow.y,
                          hand.z - elbow.z
  };
  Float totalDist = kinectDistFromWall + hand.z;
  Float multFactor = totalDist/diagonal[2];
  return new Float[]{
               elbow.x + diagonal[0]*multFactor,
               elbow.y + diagonal[1]*multFactor
  };
}


