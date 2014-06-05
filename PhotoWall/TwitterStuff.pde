// cb.setOAuthConsumerKey("ksGoSb7xjEzIfLxXv3spEkYOe");
//  cb.setOAuthConsumerSecret("gwFsQoJMvhESAcDsvFJoQDEeAxWQBr9Nz8eGhO1KO98Kvk6eeV");
//  cb.setOAuthAccessToken("101036965-NSE0kixW27LUz5zQpwuzVCWkrIojcJ4G9xH72Y1f");
//  cb.setOAuthAccessTokenSecret("okFjAbaBR0ZfBDNwMN5OaI2GSBkqj12kxlTElOayZfcQh");

import twitter4j.conf.*;
import twitter4j.*;
//import twitter4j.auth.*;
//import twitter4j.api.*;
import java.util.*;

Twitter twitter;
String searchString = "#portraitpigeon";
List<twitter4j.Status> tweets;
String[] possibleTweets = {"has been @_rnbrewer approved", " | having fun playing with demos", "for president"};


int currentTweet;

void setupTwitter()
{
    size(1600,900);

    ConfigurationBuilder cb = new ConfigurationBuilder();
    cb.setOAuthConsumerKey("ksGoSb7xjEzIfLxXv3spEkYOe");
    cb.setOAuthConsumerSecret("gwFsQoJMvhESAcDsvFJoQDEeAxWQBr9Nz8eGhO1KO98Kvk6eeV");
    cb.setOAuthAccessToken("101036965-NSE0kixW27LUz5zQpwuzVCWkrIojcJ4G9xH72Y1f");
    cb.setOAuthAccessTokenSecret("okFjAbaBR0ZfBDNwMN5OaI2GSBkqj12kxlTElOayZfcQh");

    TwitterFactory tf = new TwitterFactory(cb.build());

    twitter = tf.getInstance();

    getNewTweets();

    currentTweet = 0;

    thread("refreshTweets");
}

void drawTwitter()
{
    fill(0, 40);
    rect(0, 0, width, height);

    currentTweet = currentTweet + 1;

    if (currentTweet >= tweets.size())
    {
        currentTweet = 0;
    }

    twitter4j.Status status = tweets.get(currentTweet);

    fill(200);
    text("@"+status.getUser().getScreenName()+": "+status.getText(), random(width), random(height), width/2, height-100);

    delay(2500);
}

void getNewTweets()
{
    try 
    {
        Query query = new Query(searchString);

        QueryResult result = twitter.search(query);

        tweets = result.getTweets();
    } 
    catch (TwitterException te) 
    {
        System.out.println("Failed to search tweets: " + te.getMessage());
        System.exit(-1);
    } 
}

void refreshTweets()
{
    while (true)
    {
        getNewTweets();

        println("Updated Tweets"); 

        delay(30000);
    }
}

void tweet(String username)
{
  try
  {
    int idx = new Random().nextInt(possibleTweets.length);
    String random = (possibleTweets[idx]);
    
    twitter4j.Status status = twitter.updateStatus("@"+username+" #portraitpigeon "+random);
    System.out.println("Status updated to["+ status.getText()+ "].");
  } 
  catch (TwitterException te)
  {
    System.out.println("Error: "+ te.getMessage());
  }
}



