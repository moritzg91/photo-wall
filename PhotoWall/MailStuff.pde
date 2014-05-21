// Daniel Shiffman               
// http://www.shiffman.net       

// Example functions that check mail (pop3) and send mail (smtp)
// You can also do imap, but that's not included here
import javax.mail.*;
import ddf.minim.*;
import java.util.Properties;

Minim minim;
AudioPlayer song;

// A function to send mail
void sendMail(Contact recipient,Contact sender,String subject, String body) {
  // Create a session
  String host="smtp.gmail.com";
  Properties props=new Properties();

  // SMTP Session
  props.put("mail.transport.protocol", "smtp");
  props.put("mail.smtp.host", host);
  props.put("mail.smtp.port", "25");
  props.put("mail.smtp.auth", "true");
  // We need TTLS, which gmail requires
  props.put("mail.smtp.starttls.enable","true");

  // Create a session
  Session session = Session.getDefaultInstance(props, new Auth());

  try
  {
    // Make a new message
    MimeMessage message = new MimeMessage(session);

    // Who is this message from
    message.setFrom(new InternetAddress(sender.email, sender.name));

    // Who is this message to (we could do fancier things like make a list or add CC's)
    message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipient.email, false));

    // Subject and body
    message.setSubject(subject);
    message.setText(body);

    // We can do more here, set the date, the headers, etc.
    Transport.send(message);
    println("Mail sent!");
    minim = new Minim(this);
    song = minim.loadFile("ding.mp3");
    song.play();
  }
  catch(Exception e)
  {
    e.printStackTrace();
  }

}


