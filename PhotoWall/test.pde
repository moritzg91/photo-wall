Boolean mailSent = false;

void setup()
{
  size(640,480);
  
  if (!mailSent) { //make sure mail is only sent once
    mailSent = true;
    Contact recipient = new Contact("Moritz Gellner","moritzgellner2014@u.northwestern.edu");
    Contact sender = new Contact("Moritz Gellner","moritz.gellner@gmail.com");
    sendMail(recipient,sender,"Test Message","This is a test!");
  }
