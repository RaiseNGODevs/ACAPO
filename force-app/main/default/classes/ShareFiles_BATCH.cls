/**********************************************************************************************************************
* Name               : ShareFiles_BATCH																			      *
* Test Class		 : ShareFiles_BATCH_TEST																		  *
* Description        : Link contact photos to a common library between Saleforce users and Community users			  *					                                                                                 *
* --------------------------------------------------------------------------------------------------------------------*
* VERSION    		AUTHOR          	DATE        		DESCRIPTION                                               *
* 1.0  				Luís Branquinho     20/06/2024			Initial version                                           *
**********************************************************************************************************************/

public without sharing class ShareFiles_BATCH implements Database.Batchable<SObject>, Database.Stateful {

    private Set<Id> processedDocumentIds = new Set<Id>();

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Title FROM ContentDocument WHERE ' +
                       'Title LIKE \'PHOTO%\' OR ' +
                       'Title LIKE \'Photo%\' OR ' +
                       'Title LIKE \'photo%\' OR ' +
                       'Title LIKE \'FOTO%\' OR ' +
                       'Title LIKE \'Foto%\' OR ' +
                       'Title LIKE \'foto%\'';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<ContentDocument> scope) {
		
        system.debug('DEBUG Scope'+scope);
        
        // Get the ID of the "Photos" ContentWorkspace
        ContentWorkspace photosWorkspace = getPhotosWorkspace();
        if (photosWorkspace == null) {
            System.debug('No ContentWorkspace named "Photos" found.');
            return;
        }

        // Collect document IDs from the scope
        Set<Id> documentIds = new Set<Id>();
        for (ContentDocument doc : scope) {
            documentIds.add(doc.Id);
        }

        // Check for existing links
        List<ContentDocumentLink> ContentDocumentsLinksAlreadyLinked = [SELECT ContentDocumentId 
                                                                        FROM ContentDocumentLink 
                                                                        WHERE LinkedEntityId = :photosWorkspace.Id 
                                                                        AND ContentDocumentId IN :documentIds];

        // Put their ContentDocumentIds on a Set to evaluate later
		Set<Id> ContentDocumentsIdsAlreadyLinked = new Set<Id>();
        for (ContentDocumentLink cdl : ContentDocumentsLinksAlreadyLinked) {
            ContentDocumentsIdsAlreadyLinked.add(cdl.ContentDocumentId);
        }

        List<ContentDocumentLink> linksToInsert = new List<ContentDocumentLink>();

        for (ContentDocument doc : scope) {
            if (!processedDocumentIds.contains(doc.Id) && !ContentDocumentsIdsAlreadyLinked.contains(doc.Id)) {
                linksToInsert.add(new ContentDocumentLink(ContentDocumentId = doc.Id, LinkedEntityId = photosWorkspace.Id, ShareType = 'I', Visibility = 'AllUsers')); processedDocumentIds.add(doc.Id);
				/* Non compressed 
                ContentDocumentLink link = new ContentDocumentLink();
                link.ContentDocumentId = doc.Id;
                link.LinkedEntityId = photosWorkspace.Id;
                link.ShareType = 'I';
                link.Visibility = 'AllUsers';
                linksToInsert.add(link);
                processedDocumentIds.add(doc.Id);
				*/
            }
        }

        if (!linksToInsert.isEmpty()) {
            try {
                system.debug('linksToInsert'+linksToInsert);
                insert linksToInsert;
            } catch (DmlException e) {
                System.debug('Error inserting ContentDocumentLinks: ' + e.getMessage());
            }
        }
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('Batch job completed. Processed ' + processedDocumentIds.size() + ' ContentDocument records.');
    }

    private ContentWorkspace getPhotosWorkspace() {
        List<ContentWorkspace> workspaces = [SELECT Id FROM ContentWorkspace WHERE Name = 'Photos' LIMIT 1];
        if (!workspaces.isEmpty()) {
            return workspaces[0];
        }
        return null;
    }
}