public class PreviewController {

    public Contact ma{get;set;}
    public String photoid{get;set;}
    public String url{get;set;}
    public String aux {get;set;}
    public List<Attachment> listAttachments {get; set;}
    public List<ContentVersion> listContents {get; set;}

    public PreviewController(ApexPages.StandardController stdController){
        
        List<String> fields = new List<String>();
        fields.add('Name');
        
        if(!Test.isRunningTest()){
            
            stdController.addFields(fields);
        }       
        this.ma = (Contact) stdController.getRecord();
   
        try{

         
          listAttachments = [select id from Attachment where parentID =: this.ma.id AND (name LIKE 'Photo%' OR name LIKE 'Foto%' OR name LIKE 'FOTO%' or name LIKE 'PHOTO%' OR name LIKE 'foto%' OR name LIKE 'photo%') LIMIT 1];
         System.debug('listAttach'+listAttachments);
            if(listAttachments.size()>0){
                System.debug('attach');
                this.photoid = listAttachments[0].id;
              this.url = '/servlet/servlet.FileDownload?file='+this.photoid;
            //this.url = 'https://c.cs14.content.force.com/servlet/servlet.FileDownload?file='+this.photoid;
            }else {
                listContents = [select id from ContentVersion where FirstPublishLocationId =: this.ma.id AND (Title LIKE 'Photo%' OR Title LIKE 'Foto%' OR Title LIKE 'FOTO%' or Title LIKE 'PHOTO%' OR Title LIKE 'foto%' OR Title LIKE 'photo%') LIMIT 1];
                 System.debug('listContents'+listContents);
                if(listContents.size()>0){
                    System.debug('content');
                      this.photoid = listContents[0].id;
              		  this.url = '/sfc/servlet.shepherd/version/download/'+this.photoid; 
                }
               
            }
         
            
            
        
        }catch(Exception e){
            
       
                this.url = '';
            
                       
        }  
   
    }
}