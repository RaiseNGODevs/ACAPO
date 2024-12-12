public class NewsletterSubscriptionFormController {

    public Contact contact	{get;set;}
    public Integer step	{get;set;}
    public Map<String, String> errorMap	{get;set;}
   	String mandatory = 'Este campo é obrigatório';

    public String firstName	{get;set;}
    public String lastName	{get;set;}
    public String email	{get;set;}
    
    public NewsletterSubscriptionFormController(){
        step = 1;
        errorMap = new Map<String, String>{
          'firstName' => '',
          'lastName' => '',
          'email' => ''
        };
    }
    
    public Boolean validateForm(){
        errorMap = new Map<String, String>{
          'firstName' => mandatory,
          'lastName' => mandatory,
          'email' => mandatory
        };
        firstName = firstName.trim();
        lastName = lastName.trim();
        email = email.trim();
        
        if(String.isNotBlank(firstName)){
            errorMap.put('firstName', '');
        }
        if(String.isNotBlank(lastName)){
            errorMap.put('lastName', '');
        }
        if(String.isNotBlank(email)){
            if(Pattern.matches('^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$', email))
                errorMap.put('email', 'Introduza um email válido');
            else
            	errorMap.put('email', '');
        }
        return !errorMap.values().contains(mandatory);
    }

    public void submit(){
        try{
            if(validateForm()){
                List<contact> existingContact = [SELECT id FROM Contact
                                                 WHERE (Email = :email OR npe01__HomeEmail__c = :email OR npe01__Preferred_Email__c = :email
                                                        OR npe01__WorkEmail__c = :email)];
                if(existingContact.size() > 0){
                    Contact ec = existingContact[0];
                    ec.FirstName = firstName;
                    ec.LastName = lastName;
                    ec.News_subscription__c = true;	
                    ec.News_subscription_date__c = Date.today();
                }else{
                    contact = new Contact();
                    contact.FirstName = firstName;
                    contact.LastName = lastName;
                    contact.Email = email;
                    contact.News_subscription__c = true;
                    contact.News_subscription_date__c = Date.today();
                    insert contact;
                }
                step = 2;
            }
        }catch(Exception e){
            errorMap.put('geral', 'Ocorreu um erro. Por favor contacte a organização.');
            sendErrorEmailNotification(JSON.serialize(this),'developer@raisengo.com');
        }
    }
    
    public static void sendErrorEmailNotification( String msg, String email ){
        String textBody = '';
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses( new List<String>{ email } );
        mail.setSubject( 'Erro Acapo - Newsletter Form' );
        textBody += 'Ocorreu o seguinte erro:\n' +
                    msg + '\n\n';
        mail.setPlainTextBody( textBody );
        if( !Test.isRunningTest() ) 
            Messaging.sendEmail( new Messaging.SingleEmailMessage[]{mail} );
    }
}