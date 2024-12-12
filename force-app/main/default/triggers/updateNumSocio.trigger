trigger updateNumSocio on Contact (before insert, after insert, before update, after update) {
    
    Integer counter;
   
    String numEfetivo;
    
    List<Contact> listContatos = [SELECT N_mero_de_S_cio__c, Tipo_de_S_cio__c FROM Contact]; 
    
    List<Contact> contactsToUpdate = new List<Contact>();
    
    List<N_S_cio_Seria_o__c>  serie = [SELECT ID, ultimo_n_mero__c, Tipo_de_S_cio__c, Letra__c FROM N_S_cio_Seria_o__c];
    
    
    
    Map<Id,Contact> o = new Map<Id,Contact>();
    o = trigger.oldMap;


    for(Contact c : Trigger.new){
        Contact old = new Contact();
        System.debug(o);
        if(o != null){
            old = o.get(c.Id);
        }
        
        if (Trigger.isAfter && Trigger.isUpdate){
            
            
        
        if (!String.isBlank(old.N_mero_de_S_cio__c) && old.Tipo_de_S_cio__c != c.Tipo_de_S_cio__c){
            
            System.debug(old.N_mero_de_S_cio__c);
            
            Contact tempCont = new Contact(Id = c.Id);
            
            for(N_S_cio_Seria_o__c s: serie ){
                
                
                    if (s.Tipo_de_S_cio__c == c.Tipo_de_S_cio__c){
            		
            		counter = Integer.valueOf(s.ultimo_n_mero__c) +1;
            		numEfetivo = s.Letra__c +'-'+ String.valueOf(counter).leftPad(5, '0'); 
                    tempCont.N_mero_de_S_cio__c = numEfetivo;
                    contactsToUpdate.add(tempCont); 
           			s.ultimo_n_mero__c = counter;
                   
                       
                    update s;
                    
            
                    }}} 
            update  contactsToUpdate;
                
                }
        
        
        
        
            if(String.isBlank(c.N_mero_de_S_cio__c) && c.Data_de_admiss_o__c != null && c.Tipo_de_S_cio__c != null){
                     
                  
                    
                    for(N_S_cio_Seria_o__c s: serie ){
                
                
                    if (s.Tipo_de_S_cio__c == c.Tipo_de_S_cio__c){
            		
                    counter = Integer.valueOf(s.ultimo_n_mero__c) + 1;
            		numEfetivo = s.Letra__c +'-'+ String.valueOf(counter).leftPad(5, '0'); 
                    c.N_mero_de_S_cio__c= numEfetivo;
           			s.ultimo_n_mero__c = counter;
                    
                    update s;
            		
                }
                        
        	}
        }
         
    }
      
}