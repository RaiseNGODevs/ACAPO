/**********************************************************************************************************************
* Name               : ShareFilesTrigger																			  *
* Test Class		 : ShareFilesFuture_TEST																		  *
* Description        : Link contact photos to a common library between Saleforce users and Community users			  *					                                                                              *
* --------------------------------------------------------------------------------------------------------------------*
* VERSION    		AUTHOR          	DATE        		DESCRIPTION                                               *
* 1.0  				Luís Branquinho     20/06/2024			Initial version                                           *
**********************************************************************************************************************/
trigger ShareFilesTrigger on ContentDocument (after insert) {
	
    Set<Id> contentDocumentIds = new Set<Id>();
    
    for (ContentDocument doc : Trigger.New) {
        if(doc.Title!=null && (doc.Title.toLowerCase().startsWith('photo') || doc.Title.toLowerCase().startsWith('foto')))
        	contentDocumentIds.add(doc.Id);
    }
    
    if(!contentDocumentIds.isEmpty())
    	ShareFilesFuture.shareFiles(contentDocumentIds);
}