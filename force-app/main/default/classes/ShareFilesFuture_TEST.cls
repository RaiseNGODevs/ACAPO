@isTest
public class ShareFilesFuture_TEST {
	
    @testSetup
    static void setup() { 
        ContentWorkspace[] libraries = [SELECT Id FROM ContentWorkspace WHERE Name = 'Photos' LIMIT 1];
        ContentWorkspace library = !libraries.isEmpty() ? libraries[0] : insertContentWorkspace();
    }
    
    static public ContentWorkspace insertContentWorkspace() { 
        ContentWorkspace newContentWorkspace = new ContentWorkspace(Name = 'Photos');
        insert newContentWorkspace;
        return newContentWorkspace;
	}
                       
    @isTest
    static void testShareFilesTrigger() {
        List<ContentVersion> contentVersions = new List<ContentVersion>{
            new ContentVersion(Title = 'Photo', PathOnClient = 'Photo.jpg', VersionData = Blob.valueOf('Test data')),
            new ContentVersion(Title = 'Foto', PathOnClient = 'Foto.jpg', VersionData = Blob.valueOf('Test data')),
            new ContentVersion(Title = 'Document1', PathOnClient = 'Document1.pdf', VersionData = Blob.valueOf('Test data'))
        };
		
        Test.startTest();
        insert contentVersions;
        Test.stopTest();

        ContentDocument[] insertedDocs = [SELECT Id FROM ContentDocument WHERE Title = 'Photo' OR Title = 'Foto'];
        System.assertEquals(2, insertedDocs.size(), 'Two (only) ContentDocuments should be inserted');

        ContentWorkspace library = [SELECT Id FROM ContentWorkspace WHERE Name = 'Photos' LIMIT 1];
        ContentDocumentLink[] links = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :library.Id];
        System.assertEquals(2, links.size(), 'Two (only) ContentDocumentLinks should be created');
    }
}