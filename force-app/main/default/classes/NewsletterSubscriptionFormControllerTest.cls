@isTest
public class NewsletterSubscriptionFormControllerTest {

    @isTest
    public static void test(){
        NewsletterSubscriptionFormController controller = new NewsletterSubscriptionFormController();
        controller.submit();
        
        controller.firstName = 'teste';
        controller.lastName = 'teste';
        controller.email = 'teste@';
        controller.submit();
        
        controller.email = 'teste@teste.test';
        controller.submit();
        
        controller.submit();
    }
}