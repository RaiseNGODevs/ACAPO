/**********************************************************************************************************************
* Name               : ShareFilesFuture																				  *
* Test Class		 : ShareFilesFuture_TEST																		  *
* Description        : Helper to Link contact photos to a common library between Saleforce users and Community users  *					                                                                                  *
* --------------------------------------------------------------------------------------------------------------------*
* VERSION    		AUTHOR          	DATE        		DESCRIPTION                                               *
* 1.0  				Luís Branquinho     20/06/2024			Initial version                                           *
**********************************************************************************************************************/
public class ShareFilesFuture {
    
    @future(callout=false)
    public static void shareFiles(Set<Id> contentDocumentIds) {
        
        ContentWorkspace[] libraries = [SELECT Id FROM ContentWorkspace WHERE Name = 'Photos' LIMIT 1];
        
        if(libraries.size()>0)
            for (Id docid : contentDocumentIds) {
                ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
                contentDocumentLink.ContentDocumentId = docid;
                contentDocumentLink.LinkedEntityId = libraries[0].Id;
                contentDocumentLink.ShareType = 'I';
                contentDocumentLink.Visibility = 'AllUsers';
                insert contentDocumentLink;
            }
    }
}