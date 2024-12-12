public class EtiquetasPDFController {

    public List<Contact> contactList {get;set;}
    public Boolean showPDF {get;set;}
    
    public String marginTop {get;set;}
    public String marginBottom {get;set;}
    public String marginLeft {get;set;}
    public String marginRight {get;set;}
    public String etiquetaWidth {get;set;}
    public String etiquetaHeight {get;set;}
    
    public EtiquetasPDFController(ApexPages.StandardController stdController){
        Set<Id> contactIds = new Set<Id>();
        Id campaignId = stdController.getId();
        List<CampaignMember> campaignMemberList = [SELECT id, ContactId 
                              FROM CampaignMember WHERE CampaignId =: campaignId];
        for(CampaignMember cm : campaignMemberList){
            contactIds.add(cm.ContactId);
        }
        contactList = [SELECT id, Name, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Localidade__c
                       FROM Contact WHERE id IN :contactIds];
        
        showPDF = false;
        marginTop = '1';
        marginBottom = '1';
        marginLeft = '0.5';
        marginRight = '0.5';
        etiquetaWidth = '9.73';
        etiquetaHeight = '3.11';
    }
    
    public void generatePDF(){
        showPDF = true;
        marginTop = marginTop.replace(',', '.');
        marginBottom = marginBottom.replace(',', '.');
        marginLeft = marginLeft.replace(',', '.');
        marginRight = marginRight.replace(',', '.');
        etiquetaWidth = etiquetaWidth.replace(',', '.');
        etiquetaHeight = etiquetaHeight.replace(',', '.');
    }
}